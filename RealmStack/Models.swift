import Foundation
import RealmSwift

class Route: Object, ObjectKeyIdentifiable {
    // The unique ID of the Route. `primaryKey: true` declares the
    // _id member as the primary key to the realm.
    @Persisted(primaryKey: true) var _id: String = UUID().uuidString
    @Persisted var timestamp: Date

    // Create relationships by pointing an Object field to another Class
    @Persisted var stops: List<Stop>
}

class Stop: Object, Identifiable {
    @Persisted var id: String = UUID().uuidString

    @Persisted var city: String

    @Persisted var street: String

    /// Is this item in focus
    @Persisted var isSelected: Bool

    @Persisted(originProperty: "stops") private var routes: LinkingObjects<Route>

    /// Property is ok to add here since we know a stop will only ever have one route. This getter cannot be queried via Realm.
    var route: Route {
        routes.first!
    }
}
