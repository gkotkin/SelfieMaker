//  PhotoPreviewViewController.swift
//  SelfieMaker
//
//  Created by Gennady Kotkin

import UIKit

class PhotoPreviewViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    var imageUrl: URL? {
        didSet {
            if self.isViewLoaded {
                self.updateImageWithUrl(self.imageUrl)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateImageWithUrl(self.imageUrl)
    }

    func updateImageWithUrl(_ newUrl: URL?) {
        guard let url = newUrl else { return }
        let image = UIImage(contentsOfFile: url.path)
        self.imageView.image = image
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        self.imageView
    }
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func shareTapped(_ sender: Any) {
        guard let image = self.imageView.image else { return }
        guard let barButton = sender as? UIBarButtonItem else { return }
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        if UIDevice.current.userInterfaceIdiom == .pad {
            vc.popoverPresentationController?.barButtonItem = barButton
        }
        self.present(vc, animated: true)
    }
}
