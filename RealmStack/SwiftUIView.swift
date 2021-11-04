import RealmSwift
import SwiftUI


struct SwiftUIView: View {
    @ObservedResults(
        Route.self,
        sortDescriptor: SortDescriptor(keyPath: "timestamp", ascending: true)
    ) var routes

    var body: some View {
        NavigationView {
            List {
                ForEach(routes) { route in
                    NavigationLink {
                        SwiftUIDetailsView(route: route)
                    } label: {
                        Text(route.timestamp, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: $routes.remove)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Route()
            newItem.timestamp = Date()
            $routes.append(newItem)
        }
    }
}

let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
