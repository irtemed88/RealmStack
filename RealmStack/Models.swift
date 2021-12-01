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

class Stop: Object {

    // The unique ID of the Route. `primaryKey: true` declares the
    // _id member as the primary key to the realm.
    @Persisted(primaryKey: true) var _id: String = UUID().uuidString

    @Persisted var city: String

    @Persisted var street: String
}


