//
//  ImagesRepository.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 28/08/2024.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseStorage

class ImagesRepository: ObservableObject {
    private let storage = Storage.storage()
    private let storageRef = Storage.storage().reference()
    private var imageCache = [String: Image]()
    
    func getImage(name: String, completion: @escaping (Image?) -> Void) {
        if let cachedImage = imageCache[name] {
            completion(cachedImage)
            return
        }
        
        let imageRef = storageRef.child(name)
        
        imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                completion(nil)
            } else {
                // If image data is downloaded successfully, create SwiftUI Image
                if let imageData = data, let uiImage = UIImage(data: imageData) {
                    let image = Image(uiImage: uiImage)
                    self.imageCache[name] = image
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        let storageRef = Storage.storage().reference().child("wish_images/\(UUID().uuidString).jpg")
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    storageRef.downloadURL { url, error in
                        if let error = error {
                            completion(.failure(error))
                        } else if let url = url {
                            completion(.success(url.absoluteString)) // 返回图片的 URL
                        }
                    }
                }
            }
        }
    }
}
