import RealmSwift
import SwiftUI


struct ContentView: View {
    @ObservedResults(
        Route.self,
        sortDescriptor: SortDescriptor(keyPath: "timestamp", ascending: true)
    ) var routes

    var body: some View {
        NavigationView {
            List {
                ForEach(routes) { route in
                    NavigationLink {
                        ContentDetailsView(route: route)
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
//        withAnimation {
            let newItem = Route()
            newItem.timestamp = Date()
            $routes.append(newItem)
//        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
