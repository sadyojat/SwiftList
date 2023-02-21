//
//  PhotosViewController.swift
//  SwiftList
//
//  Created by Alok Irde on 2/20/23.
//

import Combine
import UIKit
import OrderedCollections

class PhotosViewController: UIViewController {

    typealias TypeErasedPhotoFeedPublisher = AnyPublisher<OrderedDictionary<PhotoVM.ID, PhotoVM>, Never>
    typealias TypeErasedNotificationPublisher = AnyPublisher<Notification, Never>

    private var cancellables = Set<AnyCancellable>()

    private var photoFeed: PhotoFeed { PhotoFeed.shared }

    private var feedPublisher: TypeErasedPhotoFeedPublisher {
        PhotoFeed.shared.$photoViewModels.eraseToAnyPublisher()
    }

    private var togglePhotoFavoritePublisher: TypeErasedNotificationPublisher {
        NotificationCenter.default.publisher(for: Notification.Name.TogglePhotoFavoriteStatus).eraseToAnyPublisher()
    }

    private let networkInteractor = NetworkInteractor()

    private let imageCache = ImageCache.shared

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        return tv
    }()

    private lazy var dataSource: UITableViewDiffableDataSource<PhotoVM.ID, PhotoVM.ID> = {
        let ds = UITableViewDiffableDataSource<PhotoVM.ID, PhotoVM.ID>(tableView: tableView) {
            tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PhotoCell
            let item = self.photoFeed.photoViewModels[itemIdentifier]
            cell.configure(with: item)

            // MARK: Example of using async/ await swift concurrency to download images
            // TODO: Uncomment following lines to see behavior with async/await concurrency
            /*
            if let item = item, item.thumbnailImage == nil {
                self.downloadImageWithConcurrency(for: item, identifier: itemIdentifier)
            }
            */

            // MARK: Example of using combine to async download an image and reconfigure items in diffable data source
            // TODO: Uncomment following lines to see behavior with combine type erased publisher.
            if let item = item, item.thumbnailImage == nil {
                self.downloadImageWithCombine(for: item, identifier: itemIdentifier)
            }
            return cell
        }
        return ds
    }()


    /// Download image asynchronously using swift concurrency patterns
    /// - Parameters:
    ///   - item: Item view model instance
    ///   - identifier: item identifier
    private func downloadImageWithConcurrency(for item: PhotoVM, identifier: PhotoVM.ID) {
        if item.thumbnailImage == nil {
            Task { [weak self] in
                guard let self = self else { return }
                let image = await self.imageCache.image(for: item.thumbnailUrl)
                if identifier == item.id, let img = image, img != item.thumbnailImage {
                    var updatedSnapshot = self.dataSource.snapshot()
                    item.thumbnailImage = img
                    updatedSnapshot.reconfigureItems([identifier])
                    await MainActor.run(body: {
                        self.dataSource.apply(updatedSnapshot)
                    })
                }
            }
        }
    }

    /// Download image asynchronously using combine
    /// - Parameters:
    ///   - item: Item view model instance
    ///   - identifier: item identifier
    private func downloadImageWithCombine(for item: PhotoVM, identifier: PhotoVM.ID) {
        if item.thumbnailImage == nil, let thumbnailUrl = URL(string: item.thumbnailUrl) {
            URLSession.shared
                .dataTaskPublisher(for: thumbnailUrl)
                .eraseToAnyPublisher()
                .sink { [weak self] _ in
                    guard let self = self else { return }
                    var updatedSnapshot = self.dataSource.snapshot()
                    updatedSnapshot.reconfigureItems([identifier])
                    DispatchQueue.main.async {
                        self.dataSource.apply(updatedSnapshot)
                    }
                } receiveValue: { [weak self] (data: Data, response: URLResponse) in
                    guard let image = UIImage(data: data) else { return }
                    item.thumbnailImage = image
                    guard let self = self else { return }
                    self.imageCache.setImage(image, for: item.thumbnailUrl, cost: data.count)
                }
                .store(in: &self.cancellables)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PhotoCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // Do any additional setup after loading the view.
        setupSubscriptions()

        Task {
            await photoFeed.load()
        }
    }

    func setupSubscriptions() {
        feedPublisher
            .sink { [weak self] photoViewModels in
                guard let self = self else { return }
                var snapshot = self.dataSource.snapshot()

                if !snapshot.sectionIdentifiers.contains(0) {
                    snapshot.appendSections([0])
                }

                var appends = [PhotoVM.ID]()
                var reconfigures = [PhotoVM.ID]()

                photoViewModels.forEach { (key: PhotoVM.ID, value: PhotoVM) in
                    if snapshot.indexOfItem(key) == nil {
                        appends.append(key)
                    } else {
                        reconfigures.append(key)
                    }
                }
                snapshot.appendItems(appends)
                snapshot.reconfigureItems(reconfigures)

                DispatchQueue.main.async {
                    self.dataSource.apply(snapshot, animatingDifferences: true) {
                        self.navigationItem.title = "Photos : \(snapshot.itemIdentifiers.count)"
                    }
                }
            }
            .store(in: &cancellables)

        togglePhotoFavoritePublisher
            .sink { notification in
                if let itemIdentifier = notification.object as? PhotoVM.ID {
                    var updateSnapshot = self.dataSource.snapshot()
                    updateSnapshot.reconfigureItems([itemIdentifier])
                    DispatchQueue.main.async {
                        self.dataSource.apply(updateSnapshot)
                    }
                }
            }
            .store(in: &cancellables)
    }
}

extension PhotosViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = PhotosDetailViewController()
        let (_, value) = photoFeed.photoViewModels.elements[indexPath.row]
        detailVC.configure(with: value.id)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
