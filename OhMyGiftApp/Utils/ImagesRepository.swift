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
    
    
    func uploadImage(folder: String, image: UIImage, completion: @escaping (_ imageURL: String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        let imageRef = storageRef.child(folder).child(UUID().uuidString + ".jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            guard error == nil else {
                print("Error uploading image: \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                    return
                }
                completion(imageRef.fullPath)
            }
        }
    }
}
