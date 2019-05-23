//
//  Models.swift
//  ImageSaver
//
//  Created by Ali Jaber on 5/20/19.
//  Copyright © 2019 Ali Jaber. All rights reserved.
//

import Foundation
import UIKit
enum ImageError: Error {
    case missing(APIKeys)
}

struct Image {
    let id: Int
    let urlString: String
    let description: String
    let title:String
    
    init(with json: [String:Any]) throws {
        guard let id = json[APIKeys.Id.rawValue] as? Int else {
            throw ImageError.missing(.Id)
        }
        self.id = id
        guard let urlStr = json[APIKeys.link.rawValue] as? String else {
            throw ImageError.missing(.link)
        }
        self.urlString = urlStr
        
        guard let descript = json[APIKeys.description.rawValue] as? String else {
            throw ImageError.missing(.description)
        }
        self.description = descript
        guard let title = json[APIKeys.title.rawValue] as? String else {
            throw ImageError.missing(.title)
        }
       self.title = title
    }
}

struct ImageStored {
    var image:UIImage
    var imageId:Int
    init(image:UIImage, imageId:Int) {
        self.image = image
        self.imageId = imageId
    }
}
