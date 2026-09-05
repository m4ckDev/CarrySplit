import SwiftUI

struct AddParticipantView: View {
    @Environment(\.dismiss) private var dismiss
    let splitID: UUID
    @ObservedObject var viewModel: SplitsViewModel

    @State private var name = ""
    @State private var errorMessage: String?
    @FocusState private var nameIsFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("Person") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                        .focused($nameIsFocused)
                        .accessibilityIdentifier("addPerson.name")
                        .accessibilityLabel("Person name")
                        .onSubmit {
                            if canAdd {
                                addParticipant()
                            }
                        }
                }

                Section {
                    Text("Only a name is needed. Carry Splits does not require an account, email address, or phone number.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Add Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addParticipant()
                    }
                    .disabled(!canAdd)
                    .accessibilityIdentifier("addPerson.add")
                }
            }
            .task {
                nameIsFocused = true
            }
            .alert("Couldn’t Add Person", isPresented: errorBinding) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
        }
    }

    private var canAdd: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )
    }

    private func addParticipant() {
        do {
            try viewModel.addParticipant(name: name, to: splitID)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
