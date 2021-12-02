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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: bumpFirstItemCount) {
                    Label("Bump First Count", systemImage: "text.insert")
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
            interactor.addStop()
        }
    }

    private func bumpFirstItemCount() {
        withAnimation {
            // Get first stop, generate primitive, attempt to insert as new item to show deduplication\
            guard let first = route.stops.first.flatMap(StopPrimitive.init) else {
                return
            }
            interactor.insert(first)
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
