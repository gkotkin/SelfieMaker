//  SelfieCollectionCell.swift
//  SelfieMaker
//
//  Created by Gennady Kotkin

import UIKit

class SelfieCollectionCell : UICollectionViewCell {
    static let reuseId: String = "SelfieCollectionCell"
    private var imageUrl: URL?
    private var loaderWorkItem: DispatchWorkItem?

    @IBOutlet weak var imageView: UIImageView!

    func updateWith(localImageUrl url:URL) {
        self.imageUrl = url

        self.loaderWorkItem = DispatchWorkItem {
            let image = UIImage(contentsOfFile: url.path)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if self.imageUrl == url {
                    self.imageView.image = image
                }
            }
        }

        DispatchQueue.global().async(execute: self.loaderWorkItem!)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.loaderWorkItem?.cancel()
        self.loaderWorkItem = nil
    }
}
