import RealmSwift
import SwiftUI
import UIKit


@main
struct RealmStackApp: SwiftUI.App {

    init() {
        // Added to make iterating model during testing easier. Nothing special here.
        let config = Realm.Configuration(schemaVersion: 4)

        // Use this configuration when opening realms
        Realm.Configuration.defaultConfiguration = config
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
