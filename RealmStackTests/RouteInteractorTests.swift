//
//  RouteInteractorTests.swift
//  RealmStackTests
//
//  Created by loaner on 12/2/21.
//

import XCTest
@testable import RealmStack
import RealmSwift

class RouteInteractorTests: XCTestCase {

    var token: NotificationToken?

    /// Creates Route in Ephemeral realm isntance
    func makeRoute(numberOfStops: UInt = 0) throws -> Route {
        let randomID = UUID().uuidString
        let url = URL.cache.appendingPathComponent(randomID)
        let realm = try Realm(fileURL: url)

        // Create Route
        let route = Route()
        route.timestamp = Date()

        // Create Stops
        let stops: [Stop] = (0 ..< numberOfStops).map { _ in
            let stop = Stop()
            stop.street = UUID().uuidString
            stop.city = UUID().uuidString
            return stop
        }

        try realm.write {
            realm.add(route)
            route.stops.append(objectsIn: stops)
        }

        return route
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        token = nil
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        token = nil
    }


    func testAdd() throws {

        let route = try makeRoute()
        let expectations = self.expectation(description: "Add should add stop to route")

        // Observe Route
        token = route.observe { change in
            switch change {
            case .change:
                XCTAssertEqual(route.stops.count, 1)
                expectations.fulfill()
            case .error(let error):
                XCTFail(error.description)
            case .deleted:
                XCTFail()
            }
        }
        XCTAssertEqual(route.stops.count, 0)
        RouteInteractor(route: route).addStop()

        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testDelete() throws {
        let route = try makeRoute(numberOfStops: 3)
        let expectations = self.expectation(description: "Stop Should be removed")

        XCTAssertEqual(route.stops.count, 3)
        let firstID = route.stops.first?._id

        // Ensure First ID is in list
        XCTAssertNotNil(route.stops.first(where: { $0._id == firstID }))

        // Observe Route
        token = route.observe { change in
            switch change {
            case .change:

                // Expect Stop to be removed
                XCTAssertEqual(route.stops.count, 2)
                XCTAssertNil(route.stops.first(where: { $0._id == firstID }))

                expectations.fulfill()
            case .error(let error):
                XCTFail(error.description)
            case .deleted:
                XCTFail()
            }
        }

        let first = try XCTUnwrap(route.stops.first)
        RouteInteractor(route: route).deleteStop(first)

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testReorder() throws {
        let route = try makeRoute(numberOfStops: 5)
        let expectations = self.expectation(description: "Stop Should be reordered")
        let initialIDs = Array(route.stops.map { $0._id})
        let shuffledIDs = Array(initialIDs.shuffled())

        XCTAssertNotEqual(initialIDs, shuffledIDs)

        // Observe Route
        token = route.observe { change in
            switch change {
            case .change:

                // Expect Stops to follow provided identifier order
                let changedIDs = Array(route.stops.map { $0._id})
                XCTAssertEqual(changedIDs, shuffledIDs)

                expectations.fulfill()
            case .error(let error):
                XCTFail(error.description)
            case .deleted:
                XCTFail()
            }
        }

        RouteInteractor(route: route).applyOrder(orderedIdentifiers: shuffledIDs)
        waitForExpectations(timeout: 2.0, handler: nil)
    }

    /// Validate Deduplication
    func testSeveralQueuedInsertActions() throws {
        let route = try makeRoute(numberOfStops: 1)
        let expectations = self.expectation(description: "Stop Should be reordered")

        let stop = try XCTUnwrap(route.stops.first)
        let primitive = stop.primitive
        let interactor = RouteInteractor(route: route)

        // Observe Route
        token = stop.observe { change in
            print(change)
            switch change {
            case .change:
                // Expect sequence to update stop count to 4
                XCTAssertEqual(route.stops.first?.count, 4)
                expectations.fulfill()
            case .error(let error):
                XCTFail(error.description)
            case .deleted:
                XCTFail()
            }
        }

        /// Insert 3 Times serially rather than as an array to verify the queue ensures actions
        /// are taken sequentially resulting in expected deduplication application
        (1 ... 3).forEach { _ in
            interactor.insert(primitive)
        }
        waitForExpectations(timeout: 2.0, handler: nil)

    }

}

extension URL {
    /// Cache Directory (May be purged if necessary)
    static var cache: URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

