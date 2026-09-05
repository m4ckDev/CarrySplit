import SwiftUI

struct SettleUpView: View {
    let splitID: UUID
    @ObservedObject var viewModel: SplitsViewModel

    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let split = viewModel.split(withID: splitID) {
                let plan = (try? viewModel.settlementPlan(for: splitID)) ?? []

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
                            Text("Mark a payment paid only after the money has actually changed hands. Carry Splits will recalculate the remaining plan immediately.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if !split.settlementPayments.isEmpty {
                        Section("Completed") {
                            ForEach(split.settlementPayments.sorted(by: { $0.settledAt > $1.settledAt })) { payment in
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("\(viewModel.participantName(for: payment.fromParticipantID, in: splitID)) → \(viewModel.participantName(for: payment.toParticipantID, in: splitID))")
                                            .font(.body.weight(.medium))
                                        Text(payment.settledAt, format: .dateTime.month(.abbreviated).day())
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Text(viewModel.formattedAmount(payment.amount, in: splitID))
                                        .font(.body.monospacedDigit())
                                }
                                .accessibilityElement(children: .combine)
                            }
                        }
                    }
                }
                .navigationTitle("Settle Up")
                .navigationBarTitleDisplayMode(.inline)
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
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct SettlementRow: View {
    let fromName: String
    let toName: String
    let formattedAmount: String
    let onMarkPaid: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(fromName) pays \(toName)")
                        .font(.body.weight(.semibold))
                    Text("One payment")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(formattedAmount)
                    .font(.title3.monospacedDigit())
                    .fontWeight(.semibold)
            }

            Button("Mark Paid", action: onMarkPaid)
                .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .contain)
    }
}
