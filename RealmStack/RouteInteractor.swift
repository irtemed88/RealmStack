//
//  RouteInteractor.swift
//  RealmStack
//
//  Created by loaner on 12/1/21.
//

import Foundation
import RealmSwift

/// Manages the sequence of actions required to mutate models
struct RouteInteractor {

    let route: Route

    private let queue = DispatchQueue(label: "com.route.interactor", qos: .userInitiated)

    func selectStop(id: String) {
        let routeID = route._id

        queue.async {
            guard let realm = try? Realm(),
                  let route = realm.object(ofType: Route.self, forPrimaryKey: routeID),
                  let stop = realm.object(ofType: Stop.self, forPrimaryKey: id) else {
                      return
                  }

            do {
                try realm.write {
                    route.selectedStopID = stop._id
                }
            } catch {
                print("Error: \(error)")
            }

        }
    }
    func selectStop(_ stop: Stop) {
        selectStop(id: stop._id)
    }

    func addStop() {

        // TODO: - Potential for deduplicate checking/updates. Insert vs append.

        do {
            try Realm().write {
                // Construct Object
                let stop = Stop()
                stop.street = UUID().uuidString
                stop.city = UUID().uuidString
                route.stops.append(stop)
            }
        } catch {
            print(error)
        }

    }

    func deleteStop(_ stop: Stop) {
        let routeID = route._id
        let stopID = stop._id

        queue.async {
            guard let realm = try? Realm(),
                  let route = realm.object(ofType: Route.self, forPrimaryKey: routeID),
                  let stop = realm.object(ofType: Stop.self, forPrimaryKey: stopID) else {
                      return
                  }

            do {
                try realm.write({
                    if let stopIndex = route.stops.index(of: stop) {

                        // Update Selected Stop is being deleted, adjust selection to adjacent neighbor
                        if route.selectedStopID == stop._id {
                            let stops = Array(route.stops)
                            route.selectedStopID = stops[safeIndex: stopIndex + 1]?._id ?? stops[safeIndex: stopIndex - 1]?._id ?? ""
                        }
                        route.stops.remove(at: stopIndex)
                    }
                })
            } catch {
                print("Error: \(error)")
            }

        }
    }

    func deleteStops(at indexSet: IndexSet) {
        let routeID = route._id
        let stopIDsToDelete = indexSet.map { route.stops[$0]._id }

        queue.async {
            guard let realm = try? Realm(),
                  let route = realm.object(ofType: Route.self, forPrimaryKey: routeID) else {
                      return
                  }

            let stops = stopIDsToDelete.compactMap { realm.object(ofType: Stop.self, forPrimaryKey: $0) }
            let indexSetToRemove = IndexSet(stops.compactMap { route.stops.index(of: $0) })

            do {
                try realm.write {

                    // If Selected Stop is being deleted, adjust selection to adjacent neighbor
                    if stopIDsToDelete.contains(route.selectedStopID),
                       let firstIndex = route.stops.firstIndex(where: { $0._id == route.selectedStopID }){
                        let stops = Array(route.stops)
                        let newID = stops[safeIndex: firstIndex + 1]?._id ?? stops[safeIndex: firstIndex - 1]?._id ?? ""
                        route.selectedStopID = newID
                    }

                    route.stops.remove(atOffsets: indexSetToRemove)
                }
            } catch {
                print(error)
            }
        }
    }

    func moveStops(fromOffsets offsets: IndexSet, toOffset destination: Int) {
        let id = route._id
        queue.async {
            do {
                let realm = try Realm()
                let route = realm.object(ofType: Route.self, forPrimaryKey: id)
                try realm.write {
                    route?.stops.move(fromOffsets: offsets, toOffset: destination)
                }
            } catch {
                print("Error: \(error)")
            }

        }
    }


    func shuffle() {
        let id = route._id
        queue.async {
            do {
                let realm = try Realm()
                let route = realm.object(ofType: Route.self, forPrimaryKey: id)
                try realm.write {
                    route?.stops.shuffle()
                }
            } catch {
                print("Error: \(error)")
            }

        }
    }
}
