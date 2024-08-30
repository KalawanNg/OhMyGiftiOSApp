//
//  UserProfileRepository.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 27/08/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class ChatUserRepository: ObservableObject {
    private var db = Firestore.firestore()
    private var storage = Storage.storage()

    // 创建或更新用户个人资料
    func createOrUpdateProfile(chatUser: ChatUser, completion: @escaping (_ chatUser: ChatUser?, _ error: Error?) -> Void) {
        do {
            let _ = try db.collection("users").document(chatUser.uid).setData([
                "uid": chatUser.uid,
                "email": chatUser.email,
                "profileImageUrl": chatUser.profileImageUrl
            ], merge: true)
            completion(chatUser, nil)
        } catch let error {
            print("Error writing user profile to Firestore: \(error)")
            completion(nil, error)
        }
    }

    // 编辑用户个人资料，并上传新的头像
    func editProfile(chatUser: ChatUser, image: UIImage?, completion: @escaping (_ error: Error?) -> Void) {
        if let image = image {
            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                completion(NSError(domain: "com.yourdomain.app", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image"]))
                return
            }
            
            let storageRef = storage.reference(withPath: "profiles/\(chatUser.uid)/profile.jpg")
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    completion(error)
                    return
                }
                
                storageRef.downloadURL { url, error in
                    if let error = error {
                        completion(error)
                        return
                    }
                    
                    guard let downloadURL = url else {
                        completion(NSError(domain: "com.yourdomain.app", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve download URL"]))
                        return
                    }

                    var updatedUser = chatUser
                    updatedUser.profileImageUrl = downloadURL.absoluteString
                    
                    self.createOrUpdateProfile(chatUser: updatedUser) { chatUser, error in
                        completion(error)  // 这里只返回 error
                    }
                }
            }
        } else {
            createOrUpdateProfile(chatUser: chatUser) { chatUser, error in
                completion(error)  // 只返回 error
            }
        }
    }

    // 获取用户个人资料
//    func fetchProfile(userId: String, completion: @escaping (_ chatUser: ChatUser?, _ error: Error?) -> Void) {
//        db.collection("users").document(userId).getDocument { snapshot, error in
//            if let error = error {
//                completion(nil, error)
//                return
//            }
//            
//            guard let data = snapshot?.data() else {
//                completion(nil, NSError(domain: "com.yourdomain.app", code: -1, userInfo: [NSLocalizedDescriptionKey: "Profile not found"]))
//                return
//            }
//            
//            let chatUser = ChatUser(data: data)
//            completion(chatUser, nil)
//        }
//    }
    func fetchProfile(userId: String, completion: @escaping (_ profile: ChatUser?, _ error: Error?) -> Void) {
            db.collection("users").document(userId).getDocument { document, error in
                if let error = error {
                    print("Error fetching profile: \(error)")
                    completion(nil, error)
                    return
                }
                
                guard let data = document?.data() else {
                    print("No data found for userId: \(userId)")
                    completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Profile not found"]))
                    return
                }
                
                let profile = ChatUser(data: data)
                completion(profile, nil)
            }
        }
}
