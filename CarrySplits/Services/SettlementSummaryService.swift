import Foundation

enum SettlementSummaryService {
    static func summary(
        for split: SplitSession,
        plan: [SettlementTransfer],
        locale: Locale = .current
    ) -> String {
        let namesByID = Dictionary(
            uniqueKeysWithValues: split.participants.map { ($0.id, $0.name) }
        )

        var lines = ["Carry Splits — \(split.name)", ""]

        if split.expenses.isEmpty {
            lines.append("Nothing to settle yet.")
        } else if plan.isEmpty {
            lines.append("All settled.")
        } else {
            for transfer in plan {
                let fromName = namesByID[transfer.fromParticipantID] ?? "Unknown"
                let toName = namesByID[transfer.toParticipantID] ?? "Unknown"
                let amount = CurrencyFormatter.string(
                    from: transfer.amount,
                    currencyCode: split.currencyCode,
                    locale: locale
                )

                lines.append("\(fromName) → \(toName): \(amount)")
            }
        }

        lines.append("")
        lines.append("Settlement plan from Carry Splits.")

        return lines.joined(separator: "\n")
    }
}
