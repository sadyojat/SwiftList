//
//  ViewController.swift
//  SwiftList
//
//  Created by Alok Irde on 2/19/23.
//

import Combine
import UIKit

class PostViewController: UIViewController {

    private var cancellables = Set<AnyCancellable>()

    private var postFeed = PostFeed.shared

    private let networkInteractor = NetworkInteractor()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private lazy var dataSource: UITableViewDiffableDataSource<Int, Post> = {
        let ds = UITableViewDiffableDataSource<Int, Post>(tableView: tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.text = "\(itemIdentifier.title)"
            config.secondaryText = "\(itemIdentifier.body)"
            config.image = UIImage(systemName: "arrow.down")
            cell.contentConfiguration = config
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        return ds
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        navigationItem.title = "Posts : \(postFeed.posts.count)"

        postFeed.$posts.sink { [weak self] _ in
            guard let self = self else { return }
            self.navigationItem.title = "\(self.postFeed.posts.count)"
        } receiveValue: { [weak self] posts in
            guard let self = self else { return }
            var snapshot = self.dataSource.snapshot()
            if !snapshot.sectionIdentifiers.contains(0) {
                snapshot.appendSections([0])
            }
            var appends = [Post]()
            var reconfigures = [Post]()
            posts.forEach { post in
                if snapshot.indexOfItem(post) == nil {
                    appends.append(post)
                } else {
                    reconfigures.append(post)
                }
            }
            snapshot.appendItems(appends)
            snapshot.reconfigureItems(reconfigures)
            self.dataSource.apply(snapshot, animatingDifferences: true) {
                self.navigationItem.title = "Posts : \(self.postFeed.posts.count)"
            }
        }
        .store(in: &cancellables)

        Task { [weak self] in
            guard let self = self else { return }
            self.postFeed.posts = (try? await self.networkInteractor.fetch(.posts) as? [Post]) ?? []
        }
    }
}

