import SwiftUI
import RealmSwift

struct SwiftUIDetailsView: View {
    @ObservedRealmObject var route: Route
    @ObservedResults(
        Stop.self,
        keyPaths: ["isSelected"] // Providing a keyPath will cause updates to fire _only_ when that prop chagnes
    ) var selectedStops

    init(route: Route) {
        self.route = route

        // Set the filter in `init` since it relies on `route` which can't be referenced until init.
        // Subquery allows us to filter the inverse relationship and only return Stops that are a part of this route.
        // For more info on Subqueries, see: https://academy.realm.io/posts/nspredicate-cheatsheet/.
        _selectedStops.filter = NSPredicate(format: "isSelected == true AND SUBQUERY(routes, $route, $route._id == %@).@count > 0", route._id)
    }

    var body: some View {
        // Demonstrates this is working by returning all selected stops with a selected flag. Without the subquery above,
        // this will show selected stops for all routes.
        let selectedStopIds = selectedStops.map { $0.street.prefix(10) }.joined(separator: ", ")
        return VStack {
            Text("Selected Stops: \(selectedStopIds)")
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
