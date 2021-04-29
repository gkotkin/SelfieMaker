//  SelfieListViewController.swift
//  SelfieMaker
//
//  Created by Gennady Kotkin

import UIKit

class SelfieListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    private let photosInRow = 3

    private var photoStorage: PhotoStorage?

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var takeSelfieButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoStorage = PhotoStorage()

        self.collectionView.register(UINib(nibName: SelfieCollectionCell.reuseId, bundle: nil), forCellWithReuseIdentifier: SelfieCollectionCell.reuseId)
    }

    @IBAction func takeSelfieTapped(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = false
        pickerController.mediaTypes = ["public.image"]
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            pickerController.sourceType = .camera
            if UIImagePickerController.isCameraDeviceAvailable(.front) {
                pickerController.cameraDevice = .front
            }
        } else {
            pickerController.sourceType = .photoLibrary
        }

        self.navigationController?.present(pickerController, animated: true, completion: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                          didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        let millisecondsSinseRefence = Date().timeIntervalSinceReferenceDate * 1000.0
        let name = String(format: "%.0f", millisecondsSinseRefence)
        let newIdx = self.photoStorage?.createFile(withData: image.jpegData(compressionQuality: 0.8)!, name: name)
        self.collectionView.reloadData()
        picker.dismiss(animated: true) {
            guard let idx = newIdx else { return }
            self.showPhoto(atIndex: idx)
        }
    }

    func showPhoto(atIndex idx: Int) {
        self.performSegue(withIdentifier: "showDetails", sender: idx)
    }
    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let c = self.photoStorage?.numberOfPhotos ?? 0
        return c
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SelfieCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: SelfieCollectionCell.reuseId, for: indexPath) as! SelfieCollectionCell
        guard let url = self.photoStorage?.fileUrl(atIndex: indexPath.item) else {return cell}
        cell.updateWith(localImageUrl: url)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize.zero }

        let sectionInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right
        let contentInsets = collectionView.contentInset.left + collectionView.contentInset.right
        let spaces = flowLayout.minimumInteritemSpacing * (CGFloat(self.photosInRow) - 1.0)

        let w = (collectionView.bounds.size.width - sectionInsets - contentInsets - spaces) / CGFloat(self.photosInRow)
        return CGSize(width: w, height: w)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.showPhoto(atIndex: indexPath.item)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            guard let idx = sender as? Int else { return }
            guard let previewVC = segue.destination as? PhotoPreviewViewController else { return }
            let url = self.photoStorage?.fileUrl(atIndex: idx)
            previewVC.imageUrl = url
        }
    }
}

