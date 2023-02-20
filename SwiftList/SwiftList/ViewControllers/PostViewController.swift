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
        tv.delegate = self
        return tv
    }()

    private lazy var dataSource: UITableViewDiffableDataSource<Int, Post.ID> = {
        let ds = UITableViewDiffableDataSource<Int, Post.ID>(tableView: tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PostCell
            cell.configure(with: self.postFeed.posts.first(where: {$0.id == itemIdentifier}) )
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

        navigationItem.title = "Posts : \(postFeed.posts.count)"

        setupSubscriptions()

        Task { [weak self] in
            guard let self = self else { return }
            self.postFeed.posts = (try? await self.networkInteractor.fetch(.posts) as? [Post]) ?? []
        }
    }
}

extension PostViewController /* Pub-Sub setup */{
    func setupSubscriptions() {
        postFeed.$posts
            .receive(on: RunLoop.main)
            .sink { [weak self] posts in
                guard let self = self else { return }
                var snapshot = self.dataSource.snapshot()
                if !snapshot.sectionIdentifiers.contains(0) {
                    snapshot.appendSections([0])
                }
                var appends = [Post.ID]()
                var reconfigures = [Post.ID]()
                posts.forEach { post in
                    if snapshot.indexOfItem(post.id) == nil {
                        appends.append(post.id)
                    } else {
                        reconfigures.append(post.id)
                    }
                }
                snapshot.appendItems(appends)
                snapshot.reconfigureItems(reconfigures)
                self.dataSource.apply(snapshot, animatingDifferences: true) {
                    self.navigationItem.title = "Posts : \(self.postFeed.posts.count)"
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
            if let item = snapshot.itemIdentifiers.first (where: { $0 == self.postFeed.posts[indexPath.row].id }) {
                snapshot.deleteItems([item])
                self.dataSource.apply(snapshot)
            }
            self.postFeed.posts.remove(at: indexPath.row)
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")

        let favoriteAction = UIContextualAction(style: .normal, title: "Favorite") { [weak self] _, _, completion in
            guard let self = self else { return }
            self.postFeed.posts[indexPath.row].isFavorite = true
            completion(true)
        }
        favoriteAction.backgroundColor = .systemBlue
        favoriteAction.image = UIImage(systemName: "heart")

        let unFavoriteAction = UIContextualAction(style: .normal, title: "Unfavorite") { [weak self] _, _, completion in
            guard let self = self else { return }
            self.postFeed.posts[indexPath.row].isFavorite = false
            completion(true)
        }
        unFavoriteAction.backgroundColor = .systemGray2
        unFavoriteAction.image = UIImage(systemName: "heart.slash")

        var actions = [deleteAction]

        if postFeed.posts[indexPath.row].isFavorite == true {
            actions.append(unFavoriteAction)
        } else {
            actions.append(favoriteAction)
        }

        return UISwipeActionsConfiguration(actions: actions)

    }
}
