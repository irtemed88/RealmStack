import SwiftUI
import RealmSwift


//class DetailsViewModel {
//
//    lazy var interactor = RouteInteractor(route: route)
//
//}
struct SwiftUIDetailsView: View {
    @ObservedRealmObject var route: Route
    let interactor: RouteInteractor

    init(route: Route) {
        self.route = route
        self.interactor = RouteInteractor(route: route)
    }

    var body: some View {

        List {
            ForEach(Array(route.stops.enumerated()), id: \.element.self._id) { offset, item in
                Button {
                    interactor.selectStop(item)
                } label: {
                    StopCellView(viewModel: StopCellView.ViewModel(index: offset, stop: item, route: route))
                }
            }
            .onMove(perform: interactor.moveStops)
            .onDelete(perform: interactor.deleteStops)
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
