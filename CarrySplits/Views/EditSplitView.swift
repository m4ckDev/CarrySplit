import SwiftUI

struct EditSplitView: View {
    @Environment(\.dismiss) private var dismiss

    let splitID: UUID
    @ObservedObject var viewModel: SplitsViewModel

    @State private var name: String
    @State private var errorMessage: String?
    @FocusState private var nameIsFocused: Bool

    init(splitID: UUID, viewModel: SplitsViewModel) {
        self.splitID = splitID
        self.viewModel = viewModel
        _name = State(initialValue: viewModel.split(withID: splitID)?.name ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Split Name") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                        .focused($nameIsFocused)
                        .accessibilityIdentifier("editSplit.name")
                        .onSubmit {
                            if canSave {
                                save()
                            }
                        }
                }
            }
            .navigationTitle("Edit Split")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!canSave)
                    .accessibilityIdentifier("editSplit.save")
                }
            }
            .task {
                nameIsFocused = true
            }
            .alert("Couldn’t Rename Split", isPresented: errorBinding) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
        }
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )
    }

    private func save() {
        do {
            try viewModel.renameSplit(splitID, to: name)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
