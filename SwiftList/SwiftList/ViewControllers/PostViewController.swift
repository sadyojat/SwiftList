//
//  ViewController.swift
//  SwiftList
//
//  Created by Alok Irde on 2/19/23.
//

import Combine
import OrderedCollections
import UIKit

class PostViewController: UIViewController {

    typealias TypeErasedPostFeedPublisher = AnyPublisher<OrderedDictionary<Post.ID, Post>, Never>

    private var cancellables = Set<AnyCancellable>()

    private var postFeed = PostFeed.shared

    private let networkInteractor = NetworkInteractor()

    private var postFeedPublisher: TypeErasedPostFeedPublisher {
        postFeed.$postMap.eraseToAnyPublisher()
    }

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        return tv
    }()

    private lazy var dataSource: UITableViewDiffableDataSource<Int, Post.ID> = {
        let ds = UITableViewDiffableDataSource<Int, Post.ID>(tableView: tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PostCell
            cell.configure(with: self.postFeed.postMap[itemIdentifier] )
            return cell
        }
        return ds
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(PostCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        navigationItem.title = "Posts : \(postFeed.postMap.count)"

        setupSubscriptions()

        Task { [weak self] in
            guard let self = self else { return }
            if let posts = (try? await self.networkInteractor.fetch(.posts) as? [Post]),
               posts.count > 0 {
                for post in posts {
                    self.postFeed.postMap[post.id] = post
                }
            }
        }
    }
}

extension PostViewController /* Pub-Sub setup */{
    func setupSubscriptions() {

        postFeedPublisher
            .sink { [weak self] mappedPosts in
                guard let self = self else { return }
                var snapshot = self.dataSource.snapshot()

                if !snapshot.sectionIdentifiers.contains(0) {
                    snapshot.appendSections([0])
                }

                var appends = [Post.ID]()
                var reconfigures = [Post.ID]()

                mappedPosts.forEach { mappedPost in
                    if snapshot.indexOfItem(mappedPost.key) == nil {
                        appends.append(mappedPost.key)
                    } else {
                        reconfigures.append(mappedPost.key)
                    }
                }

                snapshot.appendItems(appends)
                snapshot.reconfigureItems(reconfigures)

                DispatchQueue.main.async {
                    self.dataSource.apply(snapshot, animatingDifferences: true) {
                        self.navigationItem.title = "Posts : \(String(describing: self.postFeed.postMap.count))"
                    }
                }
            }
            .store(in: &cancellables)
    }
}

extension PostViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self = self else { return }
            var snapshot = self.dataSource.snapshot()
            let itemIdentifier = snapshot.itemIdentifiers[indexPath.row]
            snapshot.deleteItems([itemIdentifier])
            self.dataSource.apply(snapshot)
            self.postFeed.postMap[itemIdentifier] = nil
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")

        let key = self.postFeed.postMap.elements[indexPath.row].key
        let favoriteAction = UIContextualAction(style: .normal, title: "Favorite") { [weak self] _, _, completion in
            guard let self = self else { return }
            self.postFeed.postMap[key]?.isFavorite = true
            completion(true)
        }
        favoriteAction.backgroundColor = .systemBlue
        favoriteAction.image = UIImage(systemName: "heart")

        let unFavoriteAction = UIContextualAction(style: .normal, title: "Unfavorite") { [weak self] _, _, completion in
            guard let self = self else { return }
            self.postFeed.postMap[key]?.isFavorite = false
            completion(true)
        }
        unFavoriteAction.backgroundColor = .systemGray2
        unFavoriteAction.image = UIImage(systemName: "heart.slash")

        var actions = [deleteAction]

        if self.postFeed.postMap[key]?.isFavorite == true {
            actions.append(unFavoriteAction)
        } else {
            actions.append(favoriteAction)
        }

        return UISwipeActionsConfiguration(actions: actions)

    }
}
