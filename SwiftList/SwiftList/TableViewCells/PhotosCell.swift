//
//  PhotosCell.swift
//  SwiftList
//
//  Created by Alok Irde on 2/20/23.
//

import UIKit

class PhotoCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    lazy var text = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .title3)
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    lazy var thumbnail = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 50)
        ])
        return imageView
    }()

    lazy var heartImage = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(systemName: "heart.fill")
        imageView.tintColor = .systemRed
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        return imageView
    }()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .disclosureIndicator

        contentView.addSubview(text)
        contentView.addSubview(thumbnail)
        contentView.addSubview(heartImage)

        let margin: CGFloat = 10
        NSLayoutConstraint.activate([
            thumbnail.leadingAnchor.constraint(equalTo: contentView.readableContentGuide.leadingAnchor),
            thumbnail.trailingAnchor.constraint(equalTo: text.leadingAnchor, constant: -margin),
            thumbnail.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnail.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: margin),
            thumbnail.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -margin),
            text.trailingAnchor.constraint(equalTo: heartImage.leadingAnchor, constant: -margin),
            heartImage.trailingAnchor.constraint(equalTo: contentView.readableContentGuide.trailingAnchor),
            heartImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            text.topAnchor.constraint(greaterThanOrEqualTo: contentView.readableContentGuide.topAnchor, constant: margin),
            text.bottomAnchor.constraint(lessThanOrEqualTo: contentView.readableContentGuide.bottomAnchor, constant: -margin)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: PhotoVM?) {
        text.text = viewModel?.title
        thumbnail.image = viewModel?.thumbnailImage
        heartImage.layer.opacity = (viewModel?.isFavorite ?? false) ? 1 : 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
