import SwiftUI

struct CreateSplitView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SplitsViewModel

    @State private var name = ""
    @State private var selectedCurrency = CurrencyCatalog.defaultOption
    @State private var errorMessage: String?
    @FocusState private var nameIsFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("Split") {
                    TextField("Trip, dinner, house...", text: $name)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                        .focused($nameIsFocused)
                        .accessibilityIdentifier("createSplit.name")
                        .accessibilityLabel("Split name")
                        .onSubmit {
                            if canCreate {
                                createSplit()
                            }
                        }
                }

                Section("Currency") {
                    Picker("Currency", selection: $selectedCurrency) {
                        ForEach(CurrencyCatalog.supported) { option in
                            Text(option.displayName)
                                .tag(option)
                        }
                    }
                    .accessibilityIdentifier("createSplit.currency")
                    .accessibilityHint("Sets the currency used for every expense in this split")
                }

                Section {
                    Text("Carry Splits keeps every expense in one currency for a clean, predictable settlement.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New Split")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createSplit()
                    }
                    .disabled(!canCreate)
                    .accessibilityIdentifier("createSplit.create")
                }
            }
            .task {
                nameIsFocused = true
            }
            .alert("Couldn’t Create Split", isPresented: errorBinding) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
        }
    }

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )
    }

    private func createSplit() {
        do {
            try viewModel.createSplit(name: name, currency: selectedCurrency)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
