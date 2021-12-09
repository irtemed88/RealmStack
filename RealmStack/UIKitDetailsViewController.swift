import Foundation
import RealmSwift
import UIKit


class UIKitDetailsViewController: UIViewController, UICollectionViewDelegate {
    let realm = try! Realm()
    let route: Route
    var stopsObserver: Any?

    private lazy var layout: UICollectionViewCompositionalLayout = {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.trailingSwipeActionsConfigurationProvider = { indexPath in
            let action = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
                let stop = self.route.stops[indexPath.row]
                self.deleteStop(stop)
                completion(true)
            }
            action.image = UIImage(systemName: "trash")
            action.backgroundColor = .systemRed
            return UISwipeActionsConfiguration(actions: [action])
        }
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }()

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(StopCollectionCell.self, forCellWithReuseIdentifier: "cell")
        cv.delegate = self
        return cv
    }()

    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, Stop> = {
        createDataSource(withCollectionView: collectionView)
    }()

    // MARK: - Lifecycle

    init(route: Route) {
        self.route = route
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.setRightBarButtonItems([
            UIBarButtonItem(image: UIImage(systemName: "shuffle"), style: .plain, target: self, action: #selector(shuffleStops)),
            UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(addStop))
        ], animated: false)

        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.dataSource = dataSource
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        stopsObserver = route.stops.observe { [weak self] change in
            guard let self = self else { return }

            switch change {
            case .initial(let stops):
                self.dataSource.apply(self.createStopsSnapshot(withStops: stops))

            case .update(let stops, _, _, _):
                self.dataSource.apply(self.createStopsSnapshot(withStops: stops))

            case .error(let error):
                print("\(error)")
            }
        }
    }

    // MARK: - Collection View

    private func createDataSource(withCollectionView collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, Stop> {
        UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! StopCollectionCell
            cell.update(withStop: itemIdentifier)
            return cell
        }
    }

    private func createStopsSnapshot(withStops stops: List<Stop>) -> NSDiffableDataSourceSnapshot<Int, Stop> {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Stop>()
        snapshot.appendSections([0])
        snapshot.appendItems(Array(stops), toSection: 0)
        return snapshot
    }

    // MARK: - Realm

    @objc private func addStop() {
        try! realm.write {
            // Construct Object
            let stop = Stop()
            stop.street = UUID().uuidString
            stop.city = UUID().uuidString
            route.stops.append(stop)
        }
    }

    @objc private func deleteStop(_ stop: Stop) {
        try! realm.write {
            realm.delete(stop)
        }
    }

    @objc private func shuffleStops() {
        try! realm.write({
            route.stops.shuffle()
        })
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // Unselect All Stops
        try! realm.write({

            // Clear Currently Selected
            route.stops.forEach { stop in
                if stop.isSelected {
                    stop.isSelected = false
                }
            }

            // Apply New Selection
            self.route.stops[indexPath.row].isSelected = true
        })

        // Unighlight the row, retaining special cell behavior
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}


class StopCollectionCell: UICollectionViewListCell {
    lazy var label: UILabel = {
        let l = UILabel(frame: bounds)
        l.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        l.textColor = .label
        contentView.addSubview(l)
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(withStop stop: Stop) {
        var content = defaultContentConfiguration()
        let text = "\(stop.street)\n\(stop.city)"
        content.image = stop.isSelected ? UIImage(systemName: "star") : nil
        content.text = text
        content.textProperties.numberOfLines = 1
        contentConfiguration = content
    }
}
