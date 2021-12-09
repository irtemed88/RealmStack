import SwiftUI
import RealmSwift


struct SwiftUIDetailsView: View {

    @ObservedRealmObject
    var route: Route

    var body: some View {

        List {
            ForEach(Array(route.stops.enumerated()), id: \.element.self) { offset, item in
                Button {
                    selectItem(item)
                } label: {
                    StopCellView(viewModel: StopCellView.ViewModel(index: offset, stop: item))
                }
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
            newItem.isSelected = false
            $route.stops.append(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            $route.stops.remove(atOffsets: offsets)
        }
    }

    private func selectItem(_ stop: Stop) {

        withAnimation {
            guard let thawed = route.thaw() else {
                return
            }

            try? thawed.realm?.write({
                // Clear Currently Selected
                thawed.stops.forEach { stop in
                    if stop.isSelected {
                        stop.thaw()?.isSelected = false
                    }
                }

                // Select New
                stop.thaw()?.isSelected = true
            })
        }
    }

    private func moveItems(source: IndexSet, to destination: Int) {
        $route.stops.move(fromOffsets: source, toOffset: destination)
    }
}
