//
//  PhotosViewController.swift
//  SwiftList
//
//  Created by Alok Irde on 2/20/23.
//

import Combine
import UIKit

class PhotosViewController: UIViewController {

    private var cancellables = Set<AnyCancellable>()

    private var photoFeed: PhotoFeed { PhotoFeed.shared }

    private var feedPublisher = PhotoFeed.shared.$photoViewModels

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

            if item?.thumbnailImage == nil {
                Task { [weak self] in
                    guard let self = self, let item = item else { return }
                    let image = await self.imageCache.image(for: item.thumbnailUrl)
                    if itemIdentifier == item.id, let img = image, img != item.thumbnailImage {
                        var updatedSnapshot = self.dataSource.snapshot()
                        item.thumbnailImage = img
                        updatedSnapshot.reconfigureItems([itemIdentifier])
                        await MainActor.run(body: {
                            self.dataSource.apply(updatedSnapshot)
                        })
                    }
                }
            }
            return cell
        }
        return ds
    }()

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
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photoViewModels in
                print("** Received \(photoViewModels.count)**")
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
                self.dataSource.apply(snapshot, animatingDifferences: true) {
                    self.navigationItem.title = "Photos : \(snapshot.itemIdentifiers.count)"
                }
            }
            .store(in: &cancellables)
    }
}


extension PhotosViewController: UITableViewDelegate {

}
