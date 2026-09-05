import Foundation

enum MoneyMath {
    static let supportedCurrencyScales = 0...6

    static func validateScale(_ scale: Int) throws {
        guard supportedCurrencyScales.contains(scale) else {
            throw SettlementEngineError.invalidCurrencyScale(scale)
        }
    }

    static func rounded(_ value: Decimal, scale: Int) -> Decimal {
        var input = value
        var output = Decimal()
        NSDecimalRound(&output, &input, scale, .plain)
        return output
    }

    static func minorUnits(_ value: Decimal, scale: Int) -> Int64 {
        let normalized = rounded(value, scale: scale)
        let scaled = normalized * scaleFactor(scale)
        return NSDecimalNumber(decimal: scaled).int64Value
    }

    static func decimal(fromMinorUnits units: Int64, scale: Int) -> Decimal {
        NSDecimalNumber(value: units).decimalValue / scaleFactor(scale)
    }

    static func sum(_ values: some Sequence<Decimal>) -> Decimal {
        values.reduce(Decimal.zero, +)
    }

    private static func scaleFactor(_ scale: Int) -> Decimal {
        guard scale > 0 else { return Decimal(1) }

        var result = Decimal(1)
        for _ in 0..<scale {
            result *= Decimal(10)
        }
        return result
    }
}
