import SwiftUI

struct SplitsView: View {
    @StateObject private var viewModel = SplitsViewModel()
    @State private var showingCreateSplit = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.splits.isEmpty {
                    ContentUnavailableView(
                        "No Splits Yet",
                        systemImage: "person.2",
                        description: Text("Create a split, add people, then start carrying shared balances forward.")
                    )
                } else {
                    List(viewModel.splits) { split in
                        NavigationLink {
                            SplitDetailView(splitID: split.id, viewModel: viewModel)
                        } label: {
                            SplitRow(split: split)
                        }
                    }
                    .listStyle(.plain)
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
        }
    }
}

private struct SplitRow: View {
    let split: SplitSession

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(split.name)
                .font(.headline)

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

#Preview {
    SplitsView()
}
