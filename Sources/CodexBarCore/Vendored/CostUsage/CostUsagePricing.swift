import Foundation

enum CostUsagePricing {
    struct CodexPricing: Sendable {
        let inputCostPerToken: Double
        let outputCostPerToken: Double
        let cacheReadInputCostPerToken: Double
    }

    struct ClaudePricing: Sendable {
        let inputCostPerToken: Double
        let outputCostPerToken: Double
        let cacheCreationInputCostPerToken: Double
        let cacheReadInputCostPerToken: Double

        let thresholdTokens: Int?
        let inputCostPerTokenAboveThreshold: Double?
        let outputCostPerTokenAboveThreshold: Double?
        let cacheCreationInputCostPerTokenAboveThreshold: Double?
        let cacheReadInputCostPerTokenAboveThreshold: Double?
    }

    struct GeminiPricing: Sendable {
        let inputCostPerToken: Double
        let outputCostPerToken: Double
        let cacheReadInputCostPerToken: Double
    }

    private static let codex: [String: CodexPricing] = [
        "gpt-5": CodexPricing(
            inputCostPerToken: 1.25e-6,
            outputCostPerToken: 1e-5,
            cacheReadInputCostPerToken: 1.25e-7),
        "gpt-5-codex": CodexPricing(
            inputCostPerToken: 1.25e-6,
            outputCostPerToken: 1e-5,
            cacheReadInputCostPerToken: 1.25e-7),
        "gpt-5.1": CodexPricing(
            inputCostPerToken: 1.25e-6,
            outputCostPerToken: 1e-5,
            cacheReadInputCostPerToken: 1.25e-7),
        "gpt-5.2": CodexPricing(
            inputCostPerToken: 1.75e-6,
            outputCostPerToken: 1.4e-5,
            cacheReadInputCostPerToken: 1.75e-7),
        "gpt-5.2-codex": CodexPricing(
            inputCostPerToken: 1.75e-6,
            outputCostPerToken: 1.4e-5,
            cacheReadInputCostPerToken: 1.75e-7),
        "gpt-5.3": CodexPricing(
            inputCostPerToken: 1.75e-6,
            outputCostPerToken: 1.4e-5,
            cacheReadInputCostPerToken: 1.75e-7),
        "gpt-5.3-codex": CodexPricing(
            inputCostPerToken: 1.75e-6,
            outputCostPerToken: 1.4e-5,
            cacheReadInputCostPerToken: 1.75e-7),
    ]

    private static let claude: [String: ClaudePricing] = [
        "claude-haiku-4-5-20251001": ClaudePricing(
            inputCostPerToken: 1e-6,
            outputCostPerToken: 5e-6,
            cacheCreationInputCostPerToken: 1.25e-6,
            cacheReadInputCostPerToken: 1e-7,
            thresholdTokens: nil,
            inputCostPerTokenAboveThreshold: nil,
            outputCostPerTokenAboveThreshold: nil,
            cacheCreationInputCostPerTokenAboveThreshold: nil,
            cacheReadInputCostPerTokenAboveThreshold: nil),
        "claude-haiku-4-5": ClaudePricing(
            inputCostPerToken: 1e-6,
            outputCostPerToken: 5e-6,
            cacheCreationInputCostPerToken: 1.25e-6,
            cacheReadInputCostPerToken: 1e-7,
            thresholdTokens: nil,
            inputCostPerTokenAboveThreshold: nil,
            outputCostPerTokenAboveThreshold: nil,
            cacheCreationInputCostPerTokenAboveThreshold: nil,
            cacheReadInputCostPerTokenAboveThreshold: nil),
        "claude-opus-4-5-20251101": ClaudePricing(
            inputCostPerToken: 5e-6,
            outputCostPerToken: 2.5e-5,
            cacheCreationInputCostPerToken: 6.25e-6,
            cacheReadInputCostPerToken: 5e-7,
            thresholdTokens: nil,
            inputCostPerTokenAboveThreshold: nil,
            outputCostPerTokenAboveThreshold: nil,
            cacheCreationInputCostPerTokenAboveThreshold: nil,
            cacheReadInputCostPerTokenAboveThreshold: nil),
        "claude-opus-4-5": ClaudePricing(
            inputCostPerToken: 5e-6,
            outputCostPerToken: 2.5e-5,
            cacheCreationInputCostPerToken: 6.25e-6,
            cacheReadInputCostPerToken: 5e-7,
            thresholdTokens: nil,
            inputCostPerTokenAboveThreshold: nil,
            outputCostPerTokenAboveThreshold: nil,
            cacheCreationInputCostPerTokenAboveThreshold: nil,
            cacheReadInputCostPerTokenAboveThreshold: nil),
        "claude-opus-4-6-20260205": ClaudePricing(
            inputCostPerToken: 5e-6,
            outputCostPerToken: 2.5e-5,
            cacheCreationInputCostPerToken: 6.25e-6,
            cacheReadInputCostPerToken: 5e-7,
            thresholdTokens: nil,
            inputCostPerTokenAboveThreshold: nil,
            outputCostPerTokenAboveThreshold: nil,
            cacheCreationInputCostPerTokenAboveThreshold: nil,
            cacheReadInputCostPerTokenAboveThreshold: nil),
        "claude-opus-4-6": ClaudePricing(
            inputCostPerToken: 5e-6,
            outputCostPerToken: 2.5e-5,
            cacheCreationInputCostPerToken: 6.25e-6,
            cacheReadInputCostPerToken: 5e-7,
            thresholdTokens: nil,
            inputCostPerTokenAboveThreshold: nil,
            outputCostPerTokenAboveThreshold: nil,
            cacheCreationInputCostPerTokenAboveThreshold: nil,
            cacheReadInputCostPerTokenAboveThreshold: nil),
        "claude-sonnet-4-5": ClaudePricing(
            inputCostPerToken: 3e-6,
            outputCostPerToken: 1.5e-5,
            cacheCreationInputCostPerToken: 3.75e-6,
            cacheReadInputCostPerToken: 3e-7,
            thresholdTokens: 200_000,
            inputCostPerTokenAboveThreshold: 6e-6,
            outputCostPerTokenAboveThreshold: 2.25e-5,
            cacheCreationInputCostPerTokenAboveThreshold: 7.5e-6,
            cacheReadInputCostPerTokenAboveThreshold: 6e-7),
        "claude-sonnet-4-5-20250929": ClaudePricing(
            inputCostPerToken: 3e-6,
            outputCostPerToken: 1.5e-5,
            cacheCreationInputCostPerToken: 3.75e-6,
            cacheReadInputCostPerToken: 3e-7,
            thresholdTokens: 200_000,
            inputCostPerTokenAboveThreshold: 6e-6,
            outputCostPerTokenAboveThreshold: 2.25e-5,
            cacheCreationInputCostPerTokenAboveThreshold: 7.5e-6,
            cacheReadInputCostPerTokenAboveThreshold: 6e-7),
        "claude-opus-4-20250514": ClaudePricing(
            inputCostPerToken: 1.5e-5,
            outputCostPerToken: 7.5e-5,
            cacheCreationInputCostPerToken: 1.875e-5,
            cacheReadInputCostPerToken: 1.5e-6,
            thresholdTokens: nil,
            inputCostPerTokenAboveThreshold: nil,
            outputCostPerTokenAboveThreshold: nil,
            cacheCreationInputCostPerTokenAboveThreshold: nil,
            cacheReadInputCostPerTokenAboveThreshold: nil),
        "claude-opus-4-1": ClaudePricing(
            inputCostPerToken: 1.5e-5,
            outputCostPerToken: 7.5e-5,
            cacheCreationInputCostPerToken: 1.875e-5,
            cacheReadInputCostPerToken: 1.5e-6,
            thresholdTokens: nil,
            inputCostPerTokenAboveThreshold: nil,
            outputCostPerTokenAboveThreshold: nil,
            cacheCreationInputCostPerTokenAboveThreshold: nil,
            cacheReadInputCostPerTokenAboveThreshold: nil),
        "claude-sonnet-4-20250514": ClaudePricing(
            inputCostPerToken: 3e-6,
            outputCostPerToken: 1.5e-5,
            cacheCreationInputCostPerToken: 3.75e-6,
            cacheReadInputCostPerToken: 3e-7,
            thresholdTokens: 200_000,
            inputCostPerTokenAboveThreshold: 6e-6,
            outputCostPerTokenAboveThreshold: 2.25e-5,
            cacheCreationInputCostPerTokenAboveThreshold: 7.5e-6,
            cacheReadInputCostPerTokenAboveThreshold: 6e-7),
    ]

    private static let gemini: [String: GeminiPricing] = [
        "gemini-1.5-flash": GeminiPricing(
            inputCostPerToken: 7.5e-8, // $0.075 / 1M
            outputCostPerToken: 3e-7, // $0.30 / 1M
            cacheReadInputCostPerToken: 1.875e-8), // $0.01875 / 1M
        "gemini-1.5-flash-8b": GeminiPricing(
            inputCostPerToken: 3.75e-8, // $0.0375 / 1M
            outputCostPerToken: 1.5e-7, // $0.15 / 1M
            cacheReadInputCostPerToken: 1e-8),
        "gemini-1.5-pro": GeminiPricing(
            inputCostPerToken: 1.25e-6, // $1.25 / 1M
            outputCostPerToken: 5e-6, // $5.00 / 1M
            cacheReadInputCostPerToken: 3.125e-7), // $0.3125 / 1M
        "gemini-2.0-flash": GeminiPricing(
            inputCostPerToken: 1e-7, // $0.10 / 1M
            outputCostPerToken: 4e-7, // $0.40 / 1M
            cacheReadInputCostPerToken: 2.5e-8),
        "gemini-2.0-flash-lite": GeminiPricing(
            inputCostPerToken: 7.5e-8,
            outputCostPerToken: 3e-7,
            cacheReadInputCostPerToken: 1.875e-8),
        "gemini-2.0-pro": GeminiPricing(
            inputCostPerToken: 1.25e-6,
            outputCostPerToken: 5e-6,
            cacheReadInputCostPerToken: 3.125e-7),
    ]

    static func normalizeCodexModel(_ raw: String) -> String {
        var trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("openai/") {
            trimmed = String(trimmed.dropFirst("openai/".count))
        }
        if let codexRange = trimmed.range(of: "-codex") {
            let base = String(trimmed[..<codexRange.lowerBound])
            if self.codex[base] != nil { return base }
        }
        return trimmed
    }

    static func normalizeClaudeModel(_ raw: String) -> String {
        var trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("anthropic.") {
            trimmed = String(trimmed.dropFirst("anthropic.".count))
        }

        if let lastDot = trimmed.lastIndex(of: "."),
           trimmed.contains("claude-")
        {
            let tail = String(trimmed[trimmed.index(after: lastDot)...])
            if tail.hasPrefix("claude-") {
                trimmed = tail
            }
        }

        if let vRange = trimmed.range(of: #"-v\d+:\d+$"#, options: .regularExpression) {
            trimmed.removeSubrange(vRange)
        }

        if let baseRange = trimmed.range(of: #"-\d{8}$"#, options: .regularExpression) {
            let base = String(trimmed[..<baseRange.lowerBound])
            if self.claude[base] != nil {
                return base
            }
        }

        return trimmed
    }

    static func normalizeGeminiModel(_ raw: String) -> String {
        var trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.hasPrefix("google/") {
            trimmed = String(trimmed.dropFirst("google/".count))
        }
        // User examples: gemini-3-flash-preview, gemini-3.1-pro-preview
        if trimmed.contains("flash") {
            if trimmed.contains("pro") { return "gemini-1.5-pro" }
            return "gemini-1.5-flash"
        }
        if trimmed.contains("pro") {
            return "gemini-1.5-pro"
        }
        return trimmed
    }

    static func codexCostUSD(model: String, inputTokens: Int, cachedInputTokens: Int, outputTokens: Int) -> Double? {
        let key = self.normalizeCodexModel(model)
        guard let pricing = self.codex[key] else { return nil }
        let cached = min(max(0, cachedInputTokens), max(0, inputTokens))
        let nonCached = max(0, inputTokens - cached)
        return Double(nonCached) * pricing.inputCostPerToken
            + Double(cached) * pricing.cacheReadInputCostPerToken
            + Double(max(0, outputTokens)) * pricing.outputCostPerToken
    }

    static func geminiCostUSD(model: String, inputTokens: Int, cachedInputTokens: Int, outputTokens: Int) -> Double? {
        let key = self.normalizeGeminiModel(model)
        guard let pricing = self.getGeminiPricing(key) else { return nil }
        let cached = min(max(0, cachedInputTokens), max(0, inputTokens))
        let nonCached = max(0, inputTokens - cached)
        return Double(nonCached) * pricing.inputCostPerToken
            + Double(cached) * pricing.cacheReadInputCostPerToken
            + Double(max(0, outputTokens)) * pricing.outputCostPerToken
    }

    static func geminiSavingsUSD(model: String, cachedInputTokens: Int) -> Double? {
        let key = self.normalizeGeminiModel(model)
        guard let pricing = self.getGeminiPricing(key) else { return nil }
        // Savings = what it WOULD have cost (input rate) - what it ACTUALLY cost (cache rate)
        let rateDelta = pricing.inputCostPerToken - pricing.cacheReadInputCostPerToken
        return Double(max(0, cachedInputTokens)) * rateDelta
    }

    private static func getGeminiPricing(_ key: String) -> GeminiPricing? {
        if let p = self.gemini[key] { return p }
        if key.contains("pro") { return self.gemini["gemini-1.5-pro"] }
        if key.contains("flash") { return self.gemini["gemini-1.5-flash"] }
        return nil
    }

    static func claudeCostUSD(
        model: String,
        inputTokens: Int,
        cacheReadInputTokens: Int,
        cacheCreationInputTokens: Int,
        outputTokens: Int) -> Double?
    {
        let key = self.normalizeClaudeModel(model)
        guard let pricing = self.claude[key] else { return nil }

        func tiered(_ tokens: Int, base: Double, above: Double?, threshold: Int?) -> Double {
            guard let threshold, let above else { return Double(tokens) * base }
            let below = min(tokens, threshold)
            let over = max(tokens - threshold, 0)
            return Double(below) * base + Double(over) * above
        }

        return tiered(
            max(0, inputTokens),
            base: pricing.inputCostPerToken,
            above: pricing.inputCostPerTokenAboveThreshold,
            threshold: pricing.thresholdTokens)
            + tiered(
                max(0, cacheReadInputTokens),
                base: pricing.cacheReadInputCostPerToken,
                above: pricing.cacheReadInputCostPerTokenAboveThreshold,
                threshold: pricing.thresholdTokens)
            + tiered(
                max(0, cacheCreationInputTokens),
                base: pricing.cacheCreationInputCostPerToken,
                above: pricing.cacheCreationInputCostPerTokenAboveThreshold,
                threshold: pricing.thresholdTokens)
            + tiered(
                max(0, outputTokens),
                base: pricing.outputCostPerToken,
                above: pricing.outputCostPerTokenAboveThreshold,
                threshold: pricing.thresholdTokens)
    }
}
