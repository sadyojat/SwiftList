//
//  PhotosDetailViewController.swift
//  SwiftList
//
//  Created by Alok Irde on 2/20/23.
//

import OrderedCollections
import UIKit

extension Notification.Name {
    static let TogglePhotoFavoriteStatus = Notification.Name("TogglePhotoFavoriteStatus")
}

class PhotosDetailViewController: UIViewController {

    private var sharedPhotoViewModels: OrderedDictionary<PhotoVM.ID, PhotoVM> {
        PhotoFeed.shared.photoViewModels
    }

    private lazy var photoView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "arrow.down")
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 300)
        ])
        return imageView
    }()

    private lazy var heartView = {
        let button = UIButton.systemButton(
            with: UIImage(systemName: "heart.fill")!,
            target: self,
            action: #selector(markAsUnfavorite)
        )
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var brokenheartView = {
        let button = UIButton.systemButton(
            with: UIImage(systemName: "heart")!,
            target: self,
            action: #selector(markAsFavorite)
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var verticalStack = {
        let stackView = UIStackView(arrangedSubviews: [photoView, heartView, brokenheartView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        return stackView
    }()

    @objc func markAsUnfavorite(_ sender: Any) {
        viewModel.isFavorite = false
        heartView.isHidden = true
        brokenheartView.isHidden = false
        NotificationCenter.default.post(name: Notification.Name.TogglePhotoFavoriteStatus, object: viewModel.id)
    }

    @objc func markAsFavorite(_ sender: Any) {
        viewModel.isFavorite = true
        brokenheartView.isHidden = true
        heartView.isHidden = false
        NotificationCenter.default.post(name: Notification.Name.TogglePhotoFavoriteStatus, object: viewModel.id)
    }

    private var viewModel: PhotoVM!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(verticalStack)
        NSLayoutConstraint.activate([
            verticalStack.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            verticalStack.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor),
            verticalStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func configure(with identifier: PhotoVM.ID) {
        self.viewModel = sharedPhotoViewModels[identifier]
        if viewModel.isFavorite {
            brokenheartView.isHidden = true
            heartView.isHidden = false
        } else {
            heartView.isHidden = true
            brokenheartView.isHidden = false
        }

        if let image = viewModel.image {
            photoView.image = image
        } else {
            Task {
                viewModel.image = await ImageCache.shared.image(for: viewModel.url)
                await MainActor.run(body: {
                    photoView.image = viewModel.image
                })
            }
        }
    }
}
