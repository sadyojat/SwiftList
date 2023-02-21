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

    func configure(with viewModel: PhotoVM?) {
        var config = self.defaultContentConfiguration()
        config.text = viewModel?.title
        config.image = viewModel?.thumbnailImage
        self.contentConfiguration = config
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
