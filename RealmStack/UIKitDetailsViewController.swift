import Foundation
import RealmSwift
import UIKit
import Combine


class UIKitDetailsViewController: UIViewController {

    struct Item: Hashable {
        let index: Int
        let stop: Stop
        let selectedStopID: String
    }

    let realm = try! Realm()
    let route: Route
    var stopsObserver: Any?
    var selectionObserver: Any?

    lazy var interactor = RouteInteractor(route: route)

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

    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, Item> = {
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
            UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(addStop)),
            UIBarButtonItem(image: UIImage(systemName: "text.insert"), style: .plain, target: self, action: #selector(bumpFirstStopCount))

        ], animated: false)

        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.dataSource = dataSource
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        stopsObserver = route.stops.observe { [weak self] change in
            guard let self = self else { return }

            switch change {
            case .initial(let stops):
                self.dataSource.apply(self.createStopsSnapshot(withStops: stops, selectedStopID: self.route.selectedStopID))
            case .update(let stops, _, _, _):
                self.dataSource.apply(self.createStopsSnapshot(withStops: stops, selectedStopID: self.route.selectedStopID))
            case .error(let error):
                print("\(error)")
            }
        }

        selectionObserver = route.observe(\.selectedStopID) { [weak self] route, change in
            guard let self = self else { return }
            let snapshot = self.createStopsSnapshot(withStops: route.stops, selectedStopID: self.route.selectedStopID)
            self.dataSource.apply(snapshot)
        }
    }

    // MARK: - Collection View

    private func createDataSource(withCollectionView collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, Item> {
        UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! StopCollectionCell
            cell.update(withStop: item.stop, index: item.index, selectedStopID: item.selectedStopID)
            return cell
        }
    }

    private func createStopsSnapshot(withStops stops: List<Stop>, selectedStopID: String) -> NSDiffableDataSourceSnapshot<Int, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        snapshot.appendSections([0])
        let items = Array(stops).enumerated().map { index, stop in
            Item(index: index, stop: stop, selectedStopID: self.route.selectedStopID)
        }
        snapshot.appendItems(items, toSection: 0)
        return snapshot
    }

    // MARK: - Realm

    @objc private func addStop() {
        interactor.addStop()
    }

    @objc private func bumpFirstStopCount() {

        // Get first stop, generate primitive, attempt to insert as new item to show deduplication\
        guard let first = route.stops.first.flatMap(StopPrimitive.init) else {
            return
        }
        interactor.insert(first)

    }

    @objc private func deleteStop(_ stop: Stop) {
        interactor.deleteStop(stop)
    }

    @objc private func shuffleStops() {
        interactor.shuffle()
    }
}

extension UIKitDetailsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let stop = route.stops[indexPath.row]
        interactor.selectStop(stop)
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

    func update(withStop stop: Stop, index: Int, selectedStopID: String) {
        var content = defaultContentConfiguration()
        content.text = "\(index).   \(stop.street)\n\(stop.city)"
        content.secondaryText = "\(stop.count) Package(s)"
        content.textProperties.numberOfLines = 1

        if selectedStopID == stop._id {
            content.image =  UIImage(systemName: "star")
        }
        contentConfiguration = content
    }
}
