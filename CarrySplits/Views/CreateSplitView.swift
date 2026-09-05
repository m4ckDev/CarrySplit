import SwiftUI

struct CreateSplitView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SplitsViewModel

    @State private var name = ""
    @State private var selectedCurrency = CurrencyCatalog.defaultOption
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Split") {
                    TextField("Trip, dinner, house...", text: $name)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                }

                Section("Currency") {
                    Picker("Currency", selection: $selectedCurrency) {
                        ForEach(CurrencyCatalog.supported) { option in
                            Text(option.displayName)
                                .tag(option)
                        }
                    }
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
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Couldn’t Create Split", isPresented: errorBinding) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
        }
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
