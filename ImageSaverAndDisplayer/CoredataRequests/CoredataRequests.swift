//
//  CoredataRequests.swift
//  ImageSaver
//
//  Created by Ali Jaber on 5/21/19.
//  Copyright © 2019 Ali Jaber. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

struct ImageSaveError: Error {
    var image: Image
}

extension AppDelegate {
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}

class CoredataRequests {
    /// getting image from url using kingfisher
    private static func imageFromUrl(_ urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        ImageDownloader.default.downloadImage(with: url, options: nil, progressBlock: nil) { (result) in
            switch result {
            case .failure(let error):
                completion(nil)
            case .success(let response):
                completion(response.image)
            }
        }
    }
    
    static func saveImages(_ images:[Image], completion: @escaping ([ImageSaveError]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var errors = [ImageSaveError]()
        for image in images {
            dispatchGroup.enter()
            saveImage(image) { (error) in
                if let error = error {
                    errors.append(error)
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(errors)
        }
    }
    
    /// save image locally
    private static func saveImage(_ image: Image, completion: @escaping (ImageSaveError?) -> Void) {
        let context = AppDelegate.shared.persistentContainer.viewContext
        let newImage = NSEntityDescription.insertNewObject(forEntityName: CoreDataKeys.Images.rawValue, into: context)
        
        DispatchQueue.main.async {
            imageFromUrl(image.urlString) { (optionalImage) in
                guard let image_ = optionalImage else {
                    completion(.init(image: image))
                    return
                }
                newImage.setValue(image_.pngData(), forKey: CoreDataKeys.img.rawValue)
                newImage.setValue(image.id, forKey: CoreDataKeys.image_id.rawValue)
                newImage.setValue(image.title, forKey: CoreDataKeys.image_title.rawValue)
                newImage.setValue(image.description, forKey: CoreDataKeys.image_descript.rawValue)
                newImage.setValue(image.urlString, forKey: CoreDataKeys.image_urlString.rawValue)
                do {
                    try context.save()
                    completion(nil)
                } catch {
                    completion(.init(image: image))
                }
            }
        }
    }
    
    /// Fetching all images
    static func getAllImages () -> [ImageStored] {
        let context = AppDelegate.shared.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:CoreDataKeys.Images.rawValue)
        do {
            let fetchedResults = try context.fetch(request)
            if let images = fetchedResults as? [NSManagedObject]{
                var array = [ImageStored]()
                for image in images {
                    if let imageId = image.value(forKey: CoreDataKeys.image_id.rawValue) as? Int {
                        if let imgData = (image.value(forKey: CoreDataKeys.img.rawValue) as? Data)  {
                            let imgStored = ImageStored(image: UIImage(data: imgData)!, imageId: imageId)
                            array.append(imgStored)
                        }
                    }
                }
                return array
            }
        }catch {
            print("could not fetch")
        }
        return []
    }
    
    /// Check if image is in database
    static func checkIfImageIsStored(_ imageId: Int, completion:@escaping(Bool) ->Void) {
        let context = AppDelegate.shared.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataKeys.Images.rawValue)
        request.predicate = NSPredicate(format: "\(CoreDataKeys.image_id.rawValue) = %d", imageId)
        request.returnsObjectsAsFaults = false
        do {
            let fetchData = try! context.fetch(request)
            if let image = fetchData as? [NSManagedObject] {
                if image.isEmpty {
                    completion(false)
                    return
                }else {
                    completion(true)
                    return
                }
            }
        }catch {
            completion(false)
        }
    }
}
