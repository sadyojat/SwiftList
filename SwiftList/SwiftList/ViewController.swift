//
//  ViewController.swift
//  SwiftList
//
//  Created by Alok Irde on 2/19/23.
//

import UIKit

struct Element: Hashable {
    let id = UUID()
    let value: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        hasher.combine(id.uuidString)
    }
}

class ViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private lazy var dataSource: UITableViewDiffableDataSource<Int, Element> = {
        let ds = UITableViewDiffableDataSource<Int, Element>(tableView: tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.text = "\(itemIdentifier.value)"
            cell.contentConfiguration = config
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
        loadData()
    }


    func loadData() {
        var snapshot = dataSource.snapshot()
        if !snapshot.sectionIdentifiers.contains(0) {
            snapshot.appendSections([0])
        }

        let list = {
            var list = [Element]()
            for i in 1024...1124 {
                let e = Element(value: Int.random(in: 0..<i))
                list.append(e)
            }
            return list
        }()

        snapshot.appendItems(list)
        dataSource.apply(snapshot)
    }

}

