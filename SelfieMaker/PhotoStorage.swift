//  PhotoStorage.swift
//  SelfieMaker
//
//  Created by Gennady Kotkin

import Foundation

class PhotoStorage {
    private let photoFolderUrl: URL

    private var fileUrls: [URL]

    init() {
        fileUrls = []

        let fm = FileManager.default
        let paths = fm.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        self.photoFolderUrl = documentsDirectory.appendingPathComponent("photos", isDirectory: true)

        if !fm.fileExists(atPath: self.photoFolderUrl.absoluteString) {
            do {
                try fm.createDirectory(at: self.photoFolderUrl, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                print(error.localizedDescription)
            }
        }

        self.updateFileList()
    }

    private func pathForFileNamed(name: String) -> String {
        self.photoFolderUrl.appendingPathComponent(name, isDirectory: false).absoluteString
    }

    var numberOfPhotos: Int {
        fileUrls.count
    }

    func fileUrl(atIndex idx: Int) -> URL {
        fileUrls[idx]
    }

    func updateFileList() {
        let fm = FileManager.default
        do {
            let items = try fm.contentsOfDirectory(at: self.photoFolderUrl, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
            fileUrls = items.sorted(by: { (a, b) -> Bool in
                a.absoluteString > b.absoluteString
            })
        } catch {
            print(error.localizedDescription)
        }
    }

    func createFile(withData data:Data, name:String) -> Int {
        let url = self.photoFolderUrl.appendingPathComponent(name)
        do {
            try data.write(to: url, options: .atomic)
            self.updateFileList()
            return self.fileUrls.firstIndex(of: url) ?? 0
        }
        catch {
            print(error.localizedDescription)
        }
        return 0
    }
}
