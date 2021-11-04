import SwiftUI
import RealmSwift


struct SwiftUIDetailsView: View {
    @ObservedRealmObject var route: Route
    
    var body: some View {

        List {
            ForEach(Array(route.stops.enumerated()), id: \.element.self) { offset, item in
                StopCellView(viewModel: StopCellView.ViewModel(index: offset, stop: item))
                    .transition(.opacity)
            }
            .onMove(perform: $route.stops.move)
            .onDelete(perform: $route.stops.remove)
        }
        .toolbar {
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
    }

    // MARK: - IBActions

    private func addItem() {
        withAnimation {

            // Construct Object
            let newItem = Stop()
            newItem.street = UUID().uuidString
            newItem.city = UUID().uuidString
            $route.stops.append(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            $route.stops.remove(atOffsets: offsets)
        }
    }

    private func moveItems(source: IndexSet, to destination: Int) {
        $route.stops.move(fromOffsets: source, toOffset: destination)
    }
}
