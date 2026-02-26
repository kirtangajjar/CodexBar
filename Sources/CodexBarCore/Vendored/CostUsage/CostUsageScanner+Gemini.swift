import Foundation

extension CostUsageScanner {
    // MARK: - Gemini

    private static func defaultGeminiTmpRoot() -> URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".gemini/tmp", isDirectory: true)
    }

    struct GeminiParseResult: Sendable {
        let days: [String: [String: [Int]]]
        let parsedBytes: Int64
    }

    static func parseGeminiFile(
        fileURL: URL,
        range: CostUsageDayRange) -> GeminiParseResult
    {
        var days: [String: [String: [Int]]] = [:]

        guard let data = try? Data(contentsOf: fileURL),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let startTime = json["startTime"] as? String,
              let dayKey = Self.dayKeyFromParsedISO(startTime),
              let messages = json["messages"] as? [[String: Any]]
        else {
            return GeminiParseResult(days: [:], parsedBytes: 0)
        }

        func add(dayKey: String, model: String, input: Int, cached: Int, output: Int) {
            guard CostUsageDayRange.isInRange(dayKey: dayKey, since: range.scanSinceKey, until: range.scanUntilKey)
            else { return }
            let normModel = CostUsagePricing.normalizeGeminiModel(model)

            var dayModels = days[dayKey] ?? [:]
            var packed = dayModels[normModel] ?? [0, 0, 0]
            packed[0] = (packed[safe: 0] ?? 0) + input
            packed[1] = (packed[safe: 1] ?? 0) + cached
            packed[2] = (packed[safe: 2] ?? 0) + output
            dayModels[normModel] = packed
            days[dayKey] = dayModels
        }

        for msg in messages {
            guard let type = msg["type"] as? String, type == "gemini",
                  let model = msg["model"] as? String,
                  let tokens = msg["tokens"] as? [String: Any]
            else { continue }

            func toInt(_ v: Any?) -> Int {
                if let n = v as? NSNumber { return n.intValue }
                return 0
            }

            let input = toInt(tokens["input"])
            let output = toInt(tokens["output"])
            let cached = toInt(tokens["cached"])

            if input == 0 && output == 0 && cached == 0 { continue }

            add(dayKey: dayKey, model: model, input: input, cached: cached, output: output)
        }

        return GeminiParseResult(days: days, parsedBytes: Int64(data.count))
    }

    private static func scanGeminiFile(
        fileURL: URL,
        range: CostUsageDayRange,
        cache: inout CostUsageCache)
    {
        let path = fileURL.path
        let attrs = (try? FileManager.default.attributesOfItem(atPath: path)) ?? [:]
        let mtime = (attrs[.modificationDate] as? Date)?.timeIntervalSince1970 ?? 0
        let size = (attrs[.size] as? NSNumber)?.int64Value ?? 0
        let mtimeMs = Int64(mtime * 1000)

        if let cached = cache.files[path],
           cached.mtimeUnixMs == mtimeMs,
           cached.size == size
        {
            return
        }

        if let cached = cache.files[path] {
            Self.applyFileDays(cache: &cache, fileDays: cached.days, sign: -1)
        }

        let parsed = Self.parseGeminiFile(fileURL: fileURL, range: range)
        let usage = Self.makeFileUsage(
            mtimeUnixMs: mtimeMs,
            size: size,
            days: parsed.days,
            parsedBytes: parsed.parsedBytes)
        cache.files[path] = usage
        Self.applyFileDays(cache: &cache, fileDays: usage.days, sign: 1)
    }

    static func loadGeminiDaily(range: CostUsageDayRange, now: Date, options: Options) -> CostUsageDailyReport {
        var cache = CostUsageCacheIO.load(provider: .gemini, cacheRoot: options.cacheRoot)
        let nowMs = Int64(now.timeIntervalSince1970 * 1000)

        let refreshMs = Int64(max(0, options.refreshMinIntervalSeconds) * 1000)
        let shouldRefresh = refreshMs == 0 || cache.lastScanUnixMs == 0 || nowMs - cache.lastScanUnixMs > refreshMs

        if shouldRefresh {
            if options.forceRescan {
                cache = CostUsageCache()
            }

            let root = options.geminiTmpRoot ?? self.defaultGeminiTmpRoot()
            let keys: [URLResourceKey] = [.isRegularFileKey, .contentModificationDateKey, .fileSizeKey]
            guard let enumerator = FileManager.default.enumerator(
                at: root,
                includingPropertiesForKeys: keys,
                options: [.skipsHiddenFiles, .skipsPackageDescendants])
            else {
                return CostUsageDailyReport(data: [], summary: nil)
            }

            var filesInScan: Set<String> = []
            for case let url as URL in enumerator {
                guard url.lastPathComponent.hasPrefix("session-"),
                      url.pathExtension.lowercased() == "json"
                else { continue }
                
                filesInScan.insert(url.path)
                Self.scanGeminiFile(fileURL: url, range: range, cache: &cache)
            }

            for key in cache.files.keys where !filesInScan.contains(key) {
                if let old = cache.files[key] {
                    Self.applyFileDays(cache: &cache, fileDays: old.days, sign: -1)
                }
                cache.files.removeValue(forKey: key)
            }

            Self.pruneDays(cache: &cache, sinceKey: range.scanSinceKey, untilKey: range.scanUntilKey)
            cache.lastScanUnixMs = nowMs
            CostUsageCacheIO.save(provider: .gemini, cache: cache, cacheRoot: options.cacheRoot)
        }

        return Self.buildGeminiReportFromCache(cache: cache, range: range)
    }

    private static func buildGeminiReportFromCache(
        cache: CostUsageCache,
        range: CostUsageDayRange) -> CostUsageDailyReport
    {
        var entries: [CostUsageDailyReport.Entry] = []
        var totalInput = 0
        var totalOutput = 0
        var totalTokens = 0
        var totalCacheRead = 0
        var totalCost: Double = 0
        var totalSavings: Double = 0
        var costSeen = false

        let dayKeys = cache.days.keys.sorted().filter {
            CostUsageDayRange.isInRange(dayKey: $0, since: range.sinceKey, until: range.untilKey)
        }

        for day in dayKeys {
            guard let models = cache.days[day] else { continue }
            let modelNames = models.keys.sorted()

            var dayInput = 0
            var dayOutput = 0
            var dayCacheRead = 0

            var breakdown: [CostUsageDailyReport.ModelBreakdown] = []
            var dayCost: Double = 0
            var daySavings: Double = 0
            var dayCostSeen = false

            for model in modelNames {
                let packed = models[model] ?? [0, 0, 0]
                let input = packed[safe: 0] ?? 0
                let cached = packed[safe: 1] ?? 0
                let output = packed[safe: 2] ?? 0

                dayInput += input
                dayCacheRead += cached
                dayOutput += output

                let cost = CostUsagePricing.geminiCostUSD(
                    model: model,
                    inputTokens: input,
                    cachedInputTokens: cached,
                    outputTokens: output)
                let savings = CostUsagePricing.geminiSavingsUSD(
                    model: model,
                    cachedInputTokens: cached)
                
                breakdown.append(CostUsageDailyReport.ModelBreakdown(
                    modelName: model,
                    costUSD: cost,
                    savingsUSD: savings))
                
                if let cost {
                    dayCost += cost
                    dayCostSeen = true
                }
                if let savings {
                    daySavings += savings
                }
            }

            breakdown.sort { lhs, rhs in (rhs.costUSD ?? -1) < (lhs.costUSD ?? -1) }
            let top = Array(breakdown.prefix(3))

            let dayTotal = dayInput + dayOutput
            let entryCost = dayCostSeen ? dayCost : nil
            entries.append(CostUsageDailyReport.Entry(
                date: day,
                inputTokens: dayInput,
                outputTokens: dayOutput,
                cacheReadTokens: dayCacheRead,
                totalTokens: dayTotal,
                costUSD: entryCost,
                savingsUSD: daySavings > 0 ? daySavings : nil,
                modelsUsed: modelNames,
                modelBreakdowns: top))

            totalInput += dayInput
            totalOutput += dayOutput
            totalCacheRead += dayCacheRead
            totalTokens += dayTotal
            if let entryCost {
                totalCost += entryCost
                costSeen = true
            }
            totalSavings += daySavings
        }

        let summary: CostUsageDailyReport.Summary? = entries.isEmpty
            ? nil
            : CostUsageDailyReport.Summary(
                totalInputTokens: totalInput,
                totalOutputTokens: totalOutput,
                cacheReadTokens: totalCacheRead,
                totalTokens: totalTokens,
                totalCostUSD: costSeen ? totalCost : nil,
                totalSavingsUSD: totalSavings > 0 ? totalSavings : nil)

        return CostUsageDailyReport(data: entries, summary: summary)
    }
}
