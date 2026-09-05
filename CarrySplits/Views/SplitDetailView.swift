import SwiftUI

struct SplitDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let splitID: UUID
    @ObservedObject var viewModel: SplitsViewModel

    @State private var showingAddParticipant = false
    @State private var showingEditSplit = false
    @State private var showingManageParticipants = false
    @State private var showingDeleteSplitConfirmation = false
    @State private var expenseEditorContext: ExpenseEditorContext?
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let split = viewModel.split(withID: splitID) {
                List {
                    if split.isArchived {
                        Section {
                            Label(
                                "This split is archived. Restore it to add or edit expenses.",
                                systemImage: "archivebox"
                            )
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        }
                    }

                    balanceSection(split: split)
                    expenseSection(split: split)
                    actionSection(split: split)
                }
                .accessibilityIdentifier("split.detail")
                .navigationTitle(split.name)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        managementMenu(split: split)
                    }
                }
                .sheet(isPresented: $showingAddParticipant) {
                    AddParticipantView(splitID: splitID, viewModel: viewModel)
                }
                .sheet(isPresented: $showingEditSplit) {
                    EditSplitView(splitID: splitID, viewModel: viewModel)
                }
                .sheet(isPresented: $showingManageParticipants) {
                    ManageParticipantsView(splitID: splitID, viewModel: viewModel)
                }
                .sheet(item: $expenseEditorContext) { context in
                    ExpenseEditorView(
                        splitID: splitID,
                        expenseID: context.expenseID,
                        viewModel: viewModel
                    )
                }
                .confirmationDialog(
                    "Delete \(split.name)?",
                    isPresented: $showingDeleteSplitConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Delete Split", role: .destructive) {
                        deleteSplit()
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("This permanently removes the split, its people, expenses, allocations, and completed settlement records from this iPhone.")
                }
                .alert("Couldn’t Update Split", isPresented: errorBinding) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage ?? "Unknown error")
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

    private func managementMenu(split: SplitSession) -> some View {
        Menu {
            if !split.isArchived {
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

                Button {
                    showingManageParticipants = true
                } label: {
                    Label("Manage People", systemImage: "person.2")
                }

                Divider()
            }

            Button {
                showingEditSplit = true
            } label: {
                Label("Rename Split", systemImage: "pencil")
            }

            Button {
                toggleArchive(split: split)
            } label: {
                Label(
                    split.isArchived ? "Restore Split" : "Archive Split",
                    systemImage: split.isArchived ? "arrow.uturn.backward.circle" : "archivebox"
                )
            }

            Divider()

            Button(role: .destructive) {
                showingDeleteSplitConfirmation = true
            } label: {
                Label("Delete Split", systemImage: "trash")
            }
        } label: {
            Label("Split Actions", systemImage: "ellipsis.circle")
        }
        .accessibilityIdentifier("split.actions")
        .accessibilityHint("Shows actions for this split")
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

                    if !split.isArchived {
                        Button("Add Person") {
                            showingAddParticipant = true
                        }
                        .padding(.top, 4)
                        .accessibilityIdentifier("split.addPerson")
                    }
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
                        guard !split.isArchived else { return }
                        expenseEditorContext = ExpenseEditorContext(expenseID: expense.id)
                    } label: {
                        ExpenseRow(
                            expense: expense,
                            payerName: viewModel.participantName(for: expense.payerID, in: splitID),
                            formattedAmount: viewModel.formattedAmount(expense.amount, in: splitID)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(split.isArchived)
                    .accessibilityIdentifier("expense.row.\(expense.id.uuidString)")
                    .accessibilityHint(split.isArchived ? "Restore this split to edit expenses" : "Opens this expense for editing")
                }
            }
        }
    }

    @ViewBuilder
    private func actionSection(split: SplitSession) -> some View {
        if !split.isArchived {
            Section {
                Button {
                    expenseEditorContext = ExpenseEditorContext(expenseID: nil)
                } label: {
                    Label("Add Expense", systemImage: "plus.circle")
                }
                .disabled(split.participants.isEmpty)
                .accessibilityIdentifier("split.addExpense")
                .accessibilityHint("Opens the expense entry form")

                NavigationLink {
                    SettleUpView(splitID: splitID, viewModel: viewModel)
                } label: {
                    Label("Settle Up", systemImage: "arrow.left.arrow.right")
                }
                .disabled(split.expenses.isEmpty)
                .accessibilityIdentifier("split.settleUp")
                .accessibilityHint("Shows the remaining payments needed to bring balances to zero")
            }
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )
    }

    private func toggleArchive(split: SplitSession) {
        do {
            try viewModel.setSplitArchived(splitID, archived: !split.isArchived)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deleteSplit() {
        do {
            try viewModel.deleteSplit(splitID)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
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
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                statusSymbol
                participantDetails
                Spacer(minLength: 8)
                amountText
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    statusSymbol
                    participantDetails
                }
                amountText
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(participant.name), \(statusText), \(formattedAmount)")
    }

    private var statusSymbol: some View {
        Image(systemName: statusIcon)
            .frame(width: 22)
            .accessibilityHidden(true)
    }

    private var participantDetails: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(participant.name)
                .font(.body.weight(.medium))
            Text(statusText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var amountText: some View {
        Text(formattedAmount)
            .font(.body.monospacedDigit())
            .fontWeight(.semibold)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
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
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(expense.title), \(formattedAmount), paid by \(payerName), \(splitMethodText), \(expense.expenseDate.formatted(date: .abbreviated, time: .omitted))"
        )
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(expense.title)
                .font(.body.weight(.medium))

            Text("Paid by \(payerName) · \(splitMethodText)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(expense.expenseDate, format: .dateTime.month(.abbreviated).day())
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var amount: some View {
        Text(formattedAmount)
            .font(.body.monospacedDigit())
            .fontWeight(.semibold)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }

    private var splitMethodText: String {
        expense.splitMethod == .equal ? "equal split" : "exact split"
    }
}
