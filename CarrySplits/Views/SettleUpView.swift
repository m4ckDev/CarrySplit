import SwiftUI

struct SettleUpView: View {
    let splitID: UUID
    @ObservedObject var viewModel: SplitsViewModel

    @State private var errorMessage: String?
    @State private var successFeedbackTrigger = 0

    var body: some View {
        Group {
            if let split = viewModel.split(withID: splitID) {
                let plan = (try? viewModel.settlementPlan(for: splitID)) ?? []
                let shareText = SettlementSummaryService.summary(for: split, plan: plan)

                List {
                    if plan.isEmpty {
                        Section {
                            ContentUnavailableView(
                                split.expenses.isEmpty ? "Nothing to Settle" : "All Settled",
                                systemImage: split.expenses.isEmpty ? "tray" : "checkmark.circle",
                                description: Text(
                                    split.expenses.isEmpty
                                        ? "Add an expense first."
                                        : "Every balance is currently at zero."
                                )
                            )
                        }
                    } else {
                        Section {
                            Label(
                                paymentCountText(plan.count),
                                systemImage: "arrow.left.arrow.right"
                            )
                            .font(.subheadline.weight(.medium))
                            .accessibilityLabel(paymentCountAccessibilityText(plan.count))
                        }

                        Section("Payments") {
                            ForEach(Array(plan.enumerated()), id: \.offset) { _, transfer in
                                SettlementRow(
                                    fromName: viewModel.participantName(
                                        for: transfer.fromParticipantID,
                                        in: splitID
                                    ),
                                    toName: viewModel.participantName(
                                        for: transfer.toParticipantID,
                                        in: splitID
                                    ),
                                    formattedAmount: viewModel.formattedAmount(
                                        transfer.amount,
                                        in: splitID
                                    ),
                                    onMarkPaid: {
                                        markPaid(transfer)
                                    }
                                )
                            }
                        }

                        Section {
                            Text("Only mark a payment paid after the money has actually changed hands. The remaining plan updates immediately.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if !split.settlementPayments.isEmpty {
                        Section("Completed") {
                            ForEach(split.settlementPayments.sorted(by: { $0.settledAt > $1.settledAt })) { payment in
                                CompletedSettlementRow(
                                    fromName: viewModel.participantName(
                                        for: payment.fromParticipantID,
                                        in: splitID
                                    ),
                                    toName: viewModel.participantName(
                                        for: payment.toParticipantID,
                                        in: splitID
                                    ),
                                    formattedAmount: viewModel.formattedAmount(payment.amount, in: splitID),
                                    settledAt: payment.settledAt
                                )
                            }
                        }
                    }
                }
                .navigationTitle("Settle Up")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if !split.expenses.isEmpty {
                        ToolbarItem(placement: .topBarTrailing) {
                            ShareLink(
                                item: shareText,
                                subject: Text("Carry Splits — \(split.name)"),
                                message: Text("Current settlement plan")
                            ) {
                                Label("Share Settlement", systemImage: "square.and.arrow.up")
                            }
                            .accessibilityIdentifier("settlement.share")
                            .accessibilityHint("Opens the iOS share sheet with this settlement summary")
                        }
                    }
                }
                .sensoryFeedback(.success, trigger: successFeedbackTrigger)
                .alert("Couldn’t Record Payment", isPresented: errorBinding) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage ?? "Unknown error")
                }
            } else {
                ContentUnavailableView("Split Not Found", systemImage: "exclamationmark.triangle")
            }
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )
    }

    private func markPaid(_ transfer: SettlementTransfer) {
        do {
            try viewModel.markSettlementPaid(transfer, in: splitID)
            successFeedbackTrigger += 1
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func paymentCountText(_ count: Int) -> String {
        count == 1 ? "1 payment to settle" : "\(count) payments to settle"
    }

    private func paymentCountAccessibilityText(_ count: Int) -> String {
        count == 1 ? "One payment remains to settle" : "\(count) payments remain to settle"
    }
}

private struct SettlementRow: View {
    let fromName: String
    let toName: String
    let formattedAmount: String
    let onMarkPaid: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    paymentDescription
                    Spacer(minLength: 8)
                    amountText
                }

                VStack(alignment: .leading, spacing: 8) {
                    paymentDescription
                    amountText
                }
            }

            Button(action: onMarkPaid) {
                Label("Mark Paid", systemImage: "checkmark.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("settlement.markPaid")
            .accessibilityLabel("Mark \(fromName)'s payment to \(toName) of \(formattedAmount) paid")
            .accessibilityHint("Records this real-world payment and recalculates the remaining settlement plan")
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .contain)
    }

    private var paymentDescription: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(fromName) pays \(toName)")
                .font(.body.weight(.semibold))
            Text("One transfer")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var amountText: some View {
        Text(formattedAmount)
            .font(.title3.monospacedDigit())
            .fontWeight(.semibold)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .accessibilityHidden(true)
    }
}

private struct CompletedSettlementRow: View {
    let fromName: String
    let toName: String
    let formattedAmount: String
    let settledAt: Date

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                details
                Spacer(minLength: 8)
                amount
            }

            VStack(alignment: .leading, spacing: 8) {
                details
                amount
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "Paid: \(fromName) to \(toName), \(formattedAmount), on \(settledAt.formatted(date: .abbreviated, time: .omitted))"
        )
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("\(fromName) → \(toName)")
                .font(.body.weight(.medium))
            Text(settledAt, format: .dateTime.month(.abbreviated).day())
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var amount: some View {
        Text(formattedAmount)
            .font(.body.monospacedDigit())
            .fontWeight(.medium)
            .lineLimit(1)
    }
}
