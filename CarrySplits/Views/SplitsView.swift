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
    }
}

private struct SplitRow: View {
    let split: SplitSession

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 8) {
                Text(split.name)
                    .font(.headline)

                if split.isArchived {
                    Text("Archived")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 8) {
                Label("\(split.participants.count)", systemImage: "person.2")
                Text("•")
                Text(split.currencyCode)
                Text("•")
                Text(expenseLabel)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    private var expenseLabel: String {
        let count = split.expenses.count
        return count == 1 ? "1 expense" : "\(count) expenses"
    }
}
