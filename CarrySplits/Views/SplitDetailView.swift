import SwiftUI

struct SplitDetailView: View {
    let splitID: UUID
    @ObservedObject var viewModel: SplitsViewModel

    @State private var showingAddParticipant = false
    @State private var expenseEditorContext: ExpenseEditorContext?

    var body: some View {
        Group {
            if let split = viewModel.split(withID: splitID) {
                List {
                    balanceSection(split: split)
                    expenseSection(split: split)
                    actionSection(split: split)
                }
                .navigationTitle(split.name)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                showingAddParticipant = true
                            } label: {
                                Label("Add Person", systemImage: "person.badge.plus")
                            }

                            Button {
                                expenseEditorContext = ExpenseEditorContext(expenseID: nil)
                            } label: {
                                Label("Add Expense", systemImage: "plus.circle")
                            }
                            .disabled(split.participants.isEmpty)
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingAddParticipant) {
                    AddParticipantView(splitID: splitID, viewModel: viewModel)
                }
                .sheet(item: $expenseEditorContext) { context in
                    ExpenseEditorView(
                        splitID: splitID,
                        expenseID: context.expenseID,
                        viewModel: viewModel
                    )
                }
            } else {
                ContentUnavailableView(
                    "Split Not Found",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Return to Carry Splits and choose another split.")
                )
            }
        }
    }

    @ViewBuilder
    private func balanceSection(split: SplitSession) -> some View {
        Section("Balances") {
            if split.participants.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Add people to begin")
                        .font(.headline)
                    Text("Names stay on this device. No accounts or invitations are required.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Button("Add Person") {
                        showingAddParticipant = true
                    }
                    .padding(.top, 4)
                }
                .padding(.vertical, 4)
            } else {
                let balances = (try? viewModel.balances(for: splitID)) ?? []
                let balancesByID = Dictionary(uniqueKeysWithValues: balances.map { ($0.participantID, $0.amount) })

                ForEach(split.participants.sorted(by: { $0.sortOrder < $1.sortOrder })) { participant in
                    BalanceRow(
                        participant: participant,
                        amount: balancesByID[participant.id] ?? .zero,
                        formattedAmount: viewModel.formattedAmount(
                            absoluteValue(balancesByID[participant.id] ?? .zero),
                            in: splitID
                        )
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func expenseSection(split: SplitSession) -> some View {
        Section("Expenses") {
            if split.expenses.isEmpty {
                Text(split.participants.isEmpty ? "Add people before entering an expense." : "No expenses yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(split.expenses.sorted(by: { $0.expenseDate > $1.expenseDate })) { expense in
                    Button {
                        expenseEditorContext = ExpenseEditorContext(expenseID: expense.id)
                    } label: {
                        ExpenseRow(
                            expense: expense,
                            payerName: viewModel.participantName(for: expense.payerID, in: splitID),
                            formattedAmount: viewModel.formattedAmount(expense.amount, in: splitID)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Opens this expense for editing")
                }
            }
        }
    }

    @ViewBuilder
    private func actionSection(split: SplitSession) -> some View {
        Section {
            Button {
                expenseEditorContext = ExpenseEditorContext(expenseID: nil)
            } label: {
                Label("Add Expense", systemImage: "plus.circle")
            }
            .disabled(split.participants.isEmpty)

            NavigationLink {
                SettleUpView(splitID: splitID, viewModel: viewModel)
            } label: {
                Label("Settle Up", systemImage: "arrow.left.arrow.right")
            }
            .disabled(split.expenses.isEmpty)
        }
    }

    private func absoluteValue(_ value: Decimal) -> Decimal {
        value < .zero ? -value : value
    }
}

private struct ExpenseEditorContext: Identifiable {
    let id = UUID()
    let expenseID: UUID?
}

private struct BalanceRow: View {
    let participant: ParticipantEntry
    let amount: Decimal
    let formattedAmount: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: statusIcon)
                .frame(width: 22)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(participant.name)
                    .font(.body.weight(.medium))
                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(formattedAmount)
                .font(.body.monospacedDigit())
                .fontWeight(.semibold)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(participant.name), \(statusText), \(formattedAmount)")
    }

    private var statusText: String {
        if amount > .zero { return "Gets back" }
        if amount < .zero { return "Owes" }
        return "Even"
    }

    private var statusIcon: String {
        if amount > .zero { return "arrow.down.left.circle" }
        if amount < .zero { return "arrow.up.right.circle" }
        return "checkmark.circle"
    }
}

private struct ExpenseRow: View {
    let expense: ExpenseEntry
    let payerName: String
    let formattedAmount: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.body.weight(.medium))

                Text("Paid by \(payerName) • \(expense.splitMethod == .equal ? "Equal" : "Exact")")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(expense.expenseDate, format: .dateTime.month(.abbreviated).day())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(formattedAmount)
                .font(.body.monospacedDigit())
                .fontWeight(.semibold)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}
