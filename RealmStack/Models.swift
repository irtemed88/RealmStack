import Foundation
import RealmSwift

class Route: Object, ObjectKeyIdentifiable {
    // The unique ID of the Route. `primaryKey: true` declares the
    // _id member as the primary key to the realm.
    @Persisted(primaryKey: true) var _id: String = UUID().uuidString
    @Persisted var timestamp: Date

    // Create relationships by pointing an Object field to another Class
    @Persisted var stops: List<Stop>

    // Defaults to invalid id
    @Persisted @objc dynamic var selectedStopID: String = ""
}

class Stop: Object {

    // The unique ID of the Route. `primaryKey: true` declares the
    // _id member as the primary key to the realm.
    @Persisted(primaryKey: true) var _id: String = UUID().uuidString

    @Persisted var city: String

    @Persisted var street: String

    @Persisted var count: Int = 1
}

struct StopPrimitive {
    let street: String
    let city: String

    func isEqual(to stop: Stop) -> Bool {

        // Compare whatever makes a primitive the same as Stop
        return street == stop.street &&
            city == stop.city
    }

}

extension StopPrimitive {
    init(_ stop: Stop) {
        self.init(street: stop.street, city: stop.city)
    }
}

extension Stop {
    func apply(_ primitive: StopPrimitive) {
        street = primitive.street
        city = primitive.city
    }
}

