import SwiftUI

struct SplitsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "No Splits Yet",
                systemImage: "person.2",
                description: Text("Create a split to start carrying shared balances forward.")
            )
            .navigationTitle("Carry Splits")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Split creation flow will be implemented next.
                    } label: {
                        Label("New Split", systemImage: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    SplitsView()
}
