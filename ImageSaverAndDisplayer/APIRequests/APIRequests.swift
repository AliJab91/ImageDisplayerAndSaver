//
//  APIRequests.swift
//  ImageSaver
//
//  Created by Ali Jaber on 5/20/19.
//  Copyright © 2019 Ali Jaber. All rights reserved.
//

import Alamofire
/// Generating Errors
enum ResponseError: Error {
    case serverError
    case clientError
    case unknown
    case error(Error)
}

enum URLStrings: String {
    case imageURL = "http://test.inmobiles.net/testapi/api/Initialization/SelectAllImages"
}

class  APIRequest {
    
    /// Builds a get request
    /// - Parameters:
    ///     - urlString: String of URL
    ///     - parameters: Optional parameters dictionary of type [String: Any]
    
    private static func getRequest(urlString: URLStrings, parameters: Parameters?, headers: HTTPHeaders?, completion: @escaping (Swift.Result<Alamofire.Result<Any>, ResponseError>) -> Void) {
        
         Alamofire.request(urlString.rawValue, method: .get, parameters: parameters, headers: nil).responseJSON { (response) in
            guard let statusCode = response.response?.statusCode else {
                completion(.failure(.unknown))
                return
            }
            if statusCode >= 500 { completion(.failure(.serverError)) }
            if statusCode < 500, statusCode >= 400 { completion(.failure(.clientError)) }
            if let error = response.error {
                completion(.failure(.error(error)))
                return
            }
            if statusCode == 200 {
                completion(.success(response.result))
            }
        }
    }
    
    /// Getting images from the server
    static func getImages(completion: @escaping (Swift.Result<[Image], ResponseError>) -> Void) {
        getRequest(urlString: .imageURL, parameters: nil, headers: nil) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                if let imageData = data.value as? [[String: Any]] {
                    var imgs = [Image]()
                    imageData.forEach({ (dictionary) in
                        do {
                            let img = try Image(with: dictionary)
                            imgs.append(img)
                        } catch let error { completion(.failure(.error(error))) }
                    })
                    completion(.success(imgs))
                } else {
                    completion(.success([]))
                }
            }
        }
    }
}
