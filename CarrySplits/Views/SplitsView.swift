import SwiftData
import SwiftUI

struct SplitsView: View {
    @Environment(\.modelContext) private var modelContext

    @StateObject private var viewModel = SplitsViewModel()
    @State private var showingCreateSplit = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.splits.isEmpty {
                    emptyState
                } else {
                    splitList
                }
            }
            .navigationTitle("Carry Splits")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCreateSplit = true
                    } label: {
                        Label("New Split", systemImage: "plus")
                    }
                    .accessibilityIdentifier("splits.new")
                    .accessibilityHint("Creates a new shared-expense split")
                }
            }
            .sheet(isPresented: $showingCreateSplit) {
                CreateSplitView(viewModel: viewModel)
            }
            .task {
                viewModel.configure(modelContext: modelContext)
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if let persistenceError = viewModel.persistenceErrorMessage {
            ContentUnavailableView(
                "Couldn’t Load Splits",
                systemImage: "externaldrive.badge.exclamationmark",
                description: Text(persistenceError)
            )
        } else {
            ContentUnavailableView(
                "No Splits Yet",
                systemImage: "person.2",
                description: Text("Create a split, add people, then start carrying shared balances forward.")
            )
            .accessibilityIdentifier("splits.empty")
        }
    }

    private var splitList: some View {
        List {
            if !viewModel.activeSplits.isEmpty {
                Section("Active") {
                    ForEach(viewModel.activeSplits) { split in
                        splitLink(split)
                    }
                }
            }

            if !viewModel.archivedSplits.isEmpty {
                Section("Archived") {
                    ForEach(viewModel.archivedSplits) { split in
                        splitLink(split)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .accessibilityIdentifier("splits.list")
        .refreshable {
            try? viewModel.reloadFromPersistence()
        }
    }

    private func splitLink(_ split: SplitSession) -> some View {
        NavigationLink {
            SplitDetailView(splitID: split.id, viewModel: viewModel)
        } label: {
            SplitRow(split: split)
        }
        .accessibilityIdentifier("split.row.\(split.id.uuidString)")
        .accessibilityHint(split.isArchived ? "Opens this archived split" : "Opens this split")
    }
}

private struct SplitRow: View {
    let split: SplitSession

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    title
                    if split.isArchived {
                        archivedLabel
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    title
                    if split.isArchived {
                        archivedLabel
                    }
                }
            }

            Text(metadataText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 5)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
    }

    private var title: some View {
        Text(split.name)
            .font(.headline)
    }

    private var archivedLabel: some View {
        Text("Archived")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.secondary)
    }

    private var metadataText: String {
        "\(participantLabel) · \(split.currencyCode) · \(expenseLabel)"
    }

    private var accessibilitySummary: String {
        let archiveStatus = split.isArchived ? ", archived" : ""
        return "\(split.name)\(archiveStatus), \(participantLabel), currency \(split.currencyCode), \(expenseLabel)"
    }

    private var participantLabel: String {
        let count = split.participants.count
        return count == 1 ? "1 person" : "\(count) people"
    }

    private var expenseLabel: String {
        let count = split.expenses.count
        return count == 1 ? "1 expense" : "\(count) expenses"
    }
}
