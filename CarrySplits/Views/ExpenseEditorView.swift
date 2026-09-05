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
    @FocusState private var titleIsFocused: Bool

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
                            .submitLabel(.next)
                            .focused($titleIsFocused)
                            .accessibilityIdentifier("expense.title")
                            .accessibilityLabel("Expense name")

                        HStack(spacing: 10) {
                            Text(split.currencyCode)
                                .foregroundStyle(.secondary)
                                .accessibilityHidden(true)
                            TextField(amountPlaceholder(for: split), text: $amountText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .accessibilityIdentifier("expense.amount")
                                .accessibilityLabel("Amount in \(split.currencyCode)")
                        }

                        DatePicker("Date", selection: $expenseDate, displayedComponents: .date)
                            .accessibilityIdentifier("expense.date")
                    }

                    Section("Paid By") {
                        Picker("Payer", selection: $payerID) {
                            ForEach(split.participants.sorted(by: { $0.sortOrder < $1.sortOrder })) { participant in
                                Text(participant.name)
                                    .tag(Optional(participant.id))
                            }
                        }
                        .accessibilityIdentifier("expense.payer")
                    }

                    Section("Split") {
                        Picker("Method", selection: $splitMethod) {
                            Text("Equal").tag(SplitMethod.equal)
                            Text("Exact").tag(SplitMethod.exact)
                        }
                        .pickerStyle(.segmented)
                        .accessibilityIdentifier("expense.splitMethod")
                        .accessibilityHint("Choose equal shares or enter exact amounts")
                    }

                    Section("Split Between") {
                        ForEach(split.participants.sorted(by: { $0.sortOrder < $1.sortOrder })) { participant in
                            Toggle(
                                participant.name,
                                isOn: participantSelectionBinding(for: participant.id)
                            )
                            .accessibilityIdentifier("expense.participant.\(participant.id.uuidString)")
                        }
                    }

                    if splitMethod == .exact {
                        Section {
                            ForEach(
                                split.participants
                                    .filter { selectedParticipantIDs.contains($0.id) }
                                    .sorted(by: { $0.sortOrder < $1.sortOrder })
                            ) { participant in
                                ExactAmountRow(
                                    participantName: participant.name,
                                    currencyCode: split.currencyCode,
                                    placeholder: amountPlaceholder(for: split),
                                    text: exactAmountBinding(for: participant.id),
                                    accessibilityIdentifier: "expense.exact.\(participant.id.uuidString)"
                                )
                            }
                        } header: {
                            Text("Exact Amounts")
                        } footer: {
                            Text(exactAllocationStatus(for: split))
                        }
                    }

                    if expenseID != nil {
                        Section {
                            Button("Delete Expense", role: .destructive) {
                                showingDeleteConfirmation = true
                            }
                            .accessibilityIdentifier("expense.delete")
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
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
                        .disabled(!canSave(split: split))
                        .accessibilityIdentifier("expense.save")
                    }
                }
                .task {
                    if expenseID == nil {
                        titleIsFocused = true
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

    private func canSave(split: SplitSession) -> Bool {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let amount = parseDecimal(amountText),
              MoneyMath.minorUnits(amount, scale: split.currencyFractionDigits) > 0,
              let payerID,
              split.participants.contains(where: { $0.id == payerID }),
              !selectedParticipantIDs.isEmpty else {
            return false
        }

        if splitMethod == .exact {
            let totalUnits = MoneyMath.minorUnits(amount, scale: split.currencyFractionDigits)
            var allocatedUnits: Int64 = 0

            for participantID in selectedParticipantIDs {
                guard let exactAmount = parseDecimal(exactAmountText[participantID, default: ""]),
                      exactAmount >= .zero else {
                    return false
                }
                allocatedUnits += MoneyMath.minorUnits(exactAmount, scale: split.currencyFractionDigits)
            }

            return allocatedUnits == totalUnits
        }

        return true
    }

    private func exactAllocationStatus(for split: SplitSession) -> String {
        guard let amount = parseDecimal(amountText), amount >= .zero else {
            return "Enter the expense total, then assign an amount to each selected person."
        }

        let totalUnits = MoneyMath.minorUnits(amount, scale: split.currencyFractionDigits)
        let allocatedUnits = selectedParticipantIDs.reduce(Int64(0)) { partial, participantID in
            guard let value = parseDecimal(exactAmountText[participantID, default: ""]) else {
                return partial
            }
            return partial + MoneyMath.minorUnits(value, scale: split.currencyFractionDigits)
        }
        let difference = totalUnits - allocatedUnits

        if difference == 0, totalUnits > 0 {
            return "Exact amounts match the expense total."
        }

        let absoluteDifference = difference < 0 ? -difference : difference
        let formattedDifference = CurrencyFormatter.string(
            from: MoneyMath.decimal(fromMinorUnits: absoluteDifference, scale: split.currencyFractionDigits),
            currencyCode: split.currencyCode
        )

        return difference >= 0
            ? "\(formattedDifference) remaining."
            : "\(formattedDifference) over the expense total."
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

private struct ExactAmountRow: View {
    let participantName: String
    let currencyCode: String
    let placeholder: String
    @Binding var text: String
    let accessibilityIdentifier: String

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 10) {
                Text(participantName)
                Spacer(minLength: 8)
                currencyField
                    .frame(minWidth: 110, idealWidth: 130, maxWidth: 160)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(participantName)
                currencyField
            }
        }
    }

    private var currencyField: some View {
        HStack(spacing: 6) {
            Text(currencyCode)
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            TextField(placeholder, text: $text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .accessibilityIdentifier(accessibilityIdentifier)
                .accessibilityLabel("Exact amount for \(participantName) in \(currencyCode)")
        }
    }
}
