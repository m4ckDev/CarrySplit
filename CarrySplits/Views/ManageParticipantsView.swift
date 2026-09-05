import SwiftUI

struct ManageParticipantsView: View {
    @Environment(\.dismiss) private var dismiss

    let splitID: UUID
    @ObservedObject var viewModel: SplitsViewModel

    @State private var selectedParticipantID: UUID?
    @State private var renameText = ""
    @State private var participantPendingDeletion: ParticipantEntry?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if let split = viewModel.split(withID: splitID) {
                    List {
                        ForEach(split.participants.sorted(by: { $0.sortOrder < $1.sortOrder })) { participant in
                            Button {
                                selectedParticipantID = participant.id
                                renameText = participant.name
                            } label: {
                                HStack {
                                    Text(participant.name)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Image(systemName: "pencil")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    participantPendingDeletion = participant
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                } else {
                    ContentUnavailableView("Split Not Found", systemImage: "exclamationmark.triangle")
                }
            }
            .navigationTitle("Manage People")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Rename Person", isPresented: renameAlertBinding) {
                TextField("Name", text: $renameText)
                Button("Cancel", role: .cancel) {
                    selectedParticipantID = nil
                }
                Button("Save") {
                    renameSelectedParticipant()
                }
            } message: {
                Text("Changing a name keeps all existing expense and settlement history intact.")
            }
            .confirmationDialog(
                "Delete this person?",
                isPresented: deleteConfirmationBinding,
                titleVisibility: .visible
            ) {
                Button("Delete Person", role: .destructive) {
                    deletePendingParticipant()
                }
                Button("Cancel", role: .cancel) {
                    participantPendingDeletion = nil
                }
            } message: {
                Text("A person can only be deleted if they are not referenced by an expense or completed settlement.")
            }
            .alert("Couldn’t Update Person", isPresented: errorBinding) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
        }
    }

    private var renameAlertBinding: Binding<Bool> {
        Binding(
            get: { selectedParticipantID != nil },
            set: { if !$0 { selectedParticipantID = nil } }
        )
    }

    private var deleteConfirmationBinding: Binding<Bool> {
        Binding(
            get: { participantPendingDeletion != nil },
            set: { if !$0 { participantPendingDeletion = nil } }
        )
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )
    }

    private func renameSelectedParticipant() {
        guard let selectedParticipantID else { return }

        do {
            try viewModel.renameParticipant(selectedParticipantID, in: splitID, to: renameText)
            self.selectedParticipantID = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deletePendingParticipant() {
        guard let participant = participantPendingDeletion else { return }

        do {
            try viewModel.deleteParticipant(participant.id, from: splitID)
            participantPendingDeletion = nil
        } catch {
            errorMessage = error.localizedDescription
            participantPendingDeletion = nil
        }
    }
}
