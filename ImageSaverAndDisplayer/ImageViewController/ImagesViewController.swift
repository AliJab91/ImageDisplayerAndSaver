//
//  ImagesViewController.swift
//  ImageSaver
//
//  Created by Ali Jaber on 5/20/19.
//  Copyright © 2019 Ali Jaber. All rights reserved.
//

import UIKit
import SVProgressHUD

class ImagesViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var storedImages : [ImageStored] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        getImages()
        // Do any additional setup after loading the view.
    }
    
    
    func getImages()  {
        SVProgressHUD.show()
        APIRequest.getImages { [weak self] (result) in
            guard let self = self else { return }
            SVProgressHUD.dismiss()
            switch result {
            case .failure(let error):
                self.showAlert(title: "Error", body: error.localizedDescription)
            case .success(let images):
                var imagesToSave = [Image]()
                for image in images {
                    CoredataRequests.checkIfImageIsStored(image.id, completion: { (available) in
                        if available {
                        }else {
                            imagesToSave.append(image)
                        }
                    })
                }
                if !imagesToSave.isEmpty{
                    CoredataRequests.saveImages(imagesToSave, completion: { (error) in
                        print(error)
                        if error.isEmpty {
                            self.showAlert(title: "", body: "Images successfully saved")
                        } else {
                            self.showAlert(title: "Error", body: "\(error.count) images failed to save")
                        }
                        self.storedImages = CoredataRequests.getAllImages()
                        self.collectionView.reloadData()
                    })
                }
            }
        }
                        self.storedImages = CoredataRequests.getAllImages()
                        self.collectionView.reloadData()
    }
    
    private func setUpCollectionView()  {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "cell")
    }
    
}

extension ImagesViewController:UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width / 2 - 50, height: self.view.frame.size.height / 4)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 25, left: 30, bottom: 10, right: 30)
    }
}

extension ImagesViewController:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storedImages.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ImageCell
        let image = storedImages[indexPath.row]
        cell?.fillCellWithImage(image: image.image)
        
        return cell!
}
}

