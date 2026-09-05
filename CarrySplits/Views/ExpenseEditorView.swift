import SwiftUI

struct ExpenseEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let splitID: UUID
    let expenseID: UUID?
    @ObservedObject var viewModel: SplitsViewModel

    @State private var title: String
    @State private var amountText: String
    @State private var payerID: UUID?
    @State private var splitMethod: SplitMethod
    @State private var selectedParticipantIDs: Set<UUID>
    @State private var exactAmountText: [UUID: String]
    @State private var expenseDate: Date
    @State private var showingDeleteConfirmation = false
    @State private var errorMessage: String?

    init(splitID: UUID, expenseID: UUID? = nil, viewModel: SplitsViewModel) {
        self.splitID = splitID
        self.expenseID = expenseID
        self.viewModel = viewModel

        let split = viewModel.split(withID: splitID)
        let existingExpense = expenseID.flatMap { viewModel.expense(withID: $0, in: splitID) }
        let defaultParticipantIDs = split?.participants.map(\.id) ?? []
        let selectedIDs = existingExpense?.allocations.map(\.participantID) ?? defaultParticipantIDs
        let exactValues = existingExpense.map { expense in
            Dictionary(uniqueKeysWithValues: expense.allocations.map { allocation in
                (allocation.participantID, NSDecimalNumber(decimal: allocation.amount).stringValue)
            })
        } ?? [:]

        _title = State(initialValue: existingExpense?.title ?? "")
        _amountText = State(
            initialValue: existingExpense.map { NSDecimalNumber(decimal: $0.amount).stringValue } ?? ""
        )
        _payerID = State(initialValue: existingExpense?.payerID ?? split?.participants.first?.id)
        _splitMethod = State(initialValue: existingExpense?.splitMethod ?? .equal)
        _selectedParticipantIDs = State(initialValue: Set(selectedIDs))
        _exactAmountText = State(initialValue: exactValues)
        _expenseDate = State(initialValue: existingExpense?.expenseDate ?? .now)
    }

    var body: some View {
        NavigationStack {
            if let split = viewModel.split(withID: splitID) {
                Form {
                    Section("Expense") {
                        TextField("What was it?", text: $title)
                            .textInputAutocapitalization(.sentences)

                        HStack {
                            Text(split.currencyCode)
                                .foregroundStyle(.secondary)
                            TextField(amountPlaceholder(for: split), text: $amountText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }

                        DatePicker("Date", selection: $expenseDate, displayedComponents: .date)
                    }

                    Section("Paid By") {
                        Picker("Payer", selection: $payerID) {
                            ForEach(split.participants) { participant in
                                Text(participant.name)
                                    .tag(Optional(participant.id))
                            }
                        }
                    }

                    Section("Split") {
                        Picker("Method", selection: $splitMethod) {
                            Text("Equal").tag(SplitMethod.equal)
                            Text("Exact").tag(SplitMethod.exact)
                        }
                        .pickerStyle(.segmented)
                    }

                    Section("Split Between") {
                        ForEach(split.participants.sorted(by: { $0.sortOrder < $1.sortOrder })) { participant in
                            Toggle(
                                participant.name,
                                isOn: participantSelectionBinding(for: participant.id)
                            )
                        }
                    }

                    if splitMethod == .exact {
                        Section("Exact Amounts") {
                            ForEach(
                                split.participants
                                    .filter { selectedParticipantIDs.contains($0.id) }
                                    .sorted(by: { $0.sortOrder < $1.sortOrder })
                            ) { participant in
                                HStack {
                                    Text(participant.name)
                                    Spacer()
                                    Text(split.currencyCode)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    TextField(
                                        amountPlaceholder(for: split),
                                        text: exactAmountBinding(for: participant.id)
                                    )
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: 110)
                                }
                            }

                            Text("Exact amounts must add up to the expense total.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if expenseID != nil {
                        Section {
                            Button("Delete Expense", role: .destructive) {
                                showingDeleteConfirmation = true
                            }
                        }
                    }
                }
                .navigationTitle(expenseID == nil ? "Add Expense" : "Edit Expense")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            save(split: split)
                        }
                    }
                }
                .confirmationDialog(
                    "Delete this expense?",
                    isPresented: $showingDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Delete Expense", role: .destructive) {
                        deleteExpense()
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Balances and the current settlement plan will be recalculated immediately.")
                }
                .alert("Couldn’t Update Expense", isPresented: errorBinding) {
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

    private func participantSelectionBinding(for participantID: UUID) -> Binding<Bool> {
        Binding(
            get: { selectedParticipantIDs.contains(participantID) },
            set: { isSelected in
                if isSelected {
                    selectedParticipantIDs.insert(participantID)
                } else {
                    selectedParticipantIDs.remove(participantID)
                    exactAmountText.removeValue(forKey: participantID)
                }
            }
        )
    }

    private func exactAmountBinding(for participantID: UUID) -> Binding<String> {
        Binding(
            get: { exactAmountText[participantID, default: ""] },
            set: { exactAmountText[participantID] = $0 }
        )
    }

    private func save(split: SplitSession) {
        guard let amount = parseDecimal(amountText), amount > .zero else {
            errorMessage = SplitUIError.invalidAmount.localizedDescription
            return
        }

        guard let payerID else {
            errorMessage = SplitUIError.invalidPayer.localizedDescription
            return
        }

        let orderedParticipantIDs = split.participants
            .filter { selectedParticipantIDs.contains($0.id) }
            .sorted(by: { $0.sortOrder < $1.sortOrder })
            .map(\.id)

        var exactAmounts: [UUID: Decimal] = [:]
        if splitMethod == .exact {
            for participantID in orderedParticipantIDs {
                guard let value = parseDecimal(exactAmountText[participantID, default: ""]) else {
                    errorMessage = "Enter an exact amount for every selected person."
                    return
                }
                exactAmounts[participantID] = value
            }
        }

        do {
            try viewModel.saveExpense(
                to: splitID,
                expenseID: expenseID,
                title: title,
                amount: amount,
                payerID: payerID,
                splitMethod: splitMethod,
                participantIDs: orderedParticipantIDs,
                exactAmounts: exactAmounts,
                expenseDate: expenseDate
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deleteExpense() {
        guard let expenseID else { return }

        do {
            try viewModel.deleteExpense(expenseID, from: splitID)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func parseDecimal(_ value: String) -> Decimal? {
        let normalized = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        return Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX"))
    }

    private func amountPlaceholder(for split: SplitSession) -> String {
        split.currencyFractionDigits == 0 ? "0" : "0.00"
    }
}
