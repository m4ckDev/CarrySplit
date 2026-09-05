import Foundation

struct CurrencyOption: Identifiable, Hashable {
    let code: String
    let name: String
    let fractionDigits: Int

    var id: String { code }

    var displayName: String {
        "\(code) — \(name)"
    }
}

enum CurrencyCatalog {
    static let supported: [CurrencyOption] = [
        CurrencyOption(code: "USD", name: "US Dollar", fractionDigits: 2),
        CurrencyOption(code: "JPY", name: "Japanese Yen", fractionDigits: 0),
        CurrencyOption(code: "EUR", name: "Euro", fractionDigits: 2),
        CurrencyOption(code: "GBP", name: "British Pound", fractionDigits: 2),
        CurrencyOption(code: "CAD", name: "Canadian Dollar", fractionDigits: 2),
        CurrencyOption(code: "AUD", name: "Australian Dollar", fractionDigits: 2)
    ]

    static let defaultOption = supported[0]

    static func option(for code: String) -> CurrencyOption? {
        supported.first { $0.code == code.uppercased() }
    }
}
