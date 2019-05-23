//
//  ImageCell.swift
//  ImageSaver
//
//  Created by Ali Jaber on 5/21/19.
//  Copyright © 2019 Ali Jaber. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func fillCellWithImage(image:UIImage)  {
        imageView.image = image
    }

}
