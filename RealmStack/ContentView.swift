import RealmSwift
import SwiftUI

struct ContentView: View {

    var body: some View {
        TabView {
            SwiftUIView()
                .tabItem {
                    Image(systemName: "swift")
                    Text("SwiftUI")
                }

            UIKitViewRepresentable()
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("UIKit")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
