import Foundation
import RealmSwift
import UIKit
import SwiftUI

struct UIKitViewRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = UIKitViewController()
        let nav = UINavigationController(rootViewController: vc)
        return nav
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {

    }
}

class UIKitViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let realm = try! Realm()

    var routesObserver: Any?
    lazy var routes: Results<Route> = {
        realm.objects(Route.self).sorted(byKeyPath: "timestamp")
    }()

    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.setRightBarButtonItems([
            UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(addRoute))

        ], animated: false)

        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        routesObserver = routes.observe { [weak self] changes in
            guard let self = self else { return }

            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self.tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                self.tableView.performBatchUpdates {
                    self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                } completion: { _ in }

            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    }

    @objc private func addRoute() {
        try! realm.write {
            let newItem = Route()
            newItem.timestamp = Date()
            realm.add(newItem)
        }
    }

    @objc private func deleteRoute(_ route: Route) {
        try! realm.write {
            realm.delete(route)
        }
    }

    // MARK: - TableViewDataSource / Delegate
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            deleteRoute(routes[indexPath.row])
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIKitDetailsViewController(route: routes[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        routes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let route = routes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = itemFormatter.string(from: route.timestamp)
        return cell
    }
}


