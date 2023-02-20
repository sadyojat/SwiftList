//
//  PostCell.swift
//  SwiftList
//
//  Created by Alok Irde on 2/19/23.
//

import UIKit

class PostCell: UITableViewCell {

    private lazy var text = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .title3)
        label.numberOfLines = 0
        return label
    }()

    private lazy var secondaryText = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption1)
        label.numberOfLines = 0
        return label
    }()

    private lazy var heartImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "heart.fill")
        imageView.tintColor = .systemRed
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        return imageView
    }()

    private lazy var verticalStack = {
        let stackView = UIStackView(arrangedSubviews: [text, secondaryText])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .leading
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var horizontalStack = {
        let stackView = UIStackView(arrangedSubviews: [verticalStack, heartImageView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(horizontalStack)
        accessoryType = .disclosureIndicator
        NSLayoutConstraint.activate([
            horizontalStack.leadingAnchor.constraint(equalTo: contentView.readableContentGuide.leadingAnchor),
            horizontalStack.trailingAnchor.constraint(equalTo: contentView.readableContentGuide.trailingAnchor),
            horizontalStack.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 10.0),
            horizontalStack.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -10.0)
        ])
    }

    func configure(with post: Post?) {
        if post?.isFavorite == true {
            print("**** Favorite : \(post?.id)")
        }
        text.text = post?.title ?? ""
        secondaryText.text = post?.body ?? ""
        heartImageView.layer.opacity = (post?.isFavorite == true) ? 1 : 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
