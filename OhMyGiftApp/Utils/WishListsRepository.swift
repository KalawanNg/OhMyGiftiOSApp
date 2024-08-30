//
//  WishlistRepository.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 25/08/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class WishListsRepository: ObservableObject {
    private var db = Firestore.firestore()
    
    func reloadWishlist(wishlistId: String, completion: @escaping (_ wishlist: WishListModel?, _ error: Error?) -> Void) {
        
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
                print("Error: No user is currently logged in.")
                return
            } 
        
        //let dispatchGroup = DispatchGroup()
        db.collection("wishlists").document(wishlistId).getDocument { document, error in
            guard error == nil else {
                print("error getting wishlists", error ?? "")
                return
            }
                
            if let document = document {
                if let dateString = document["dateCreated"] as? String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                    if let date = dateFormatter.date(from: dateString) {
                        var wishlist = WishListModel(
                            wishlistId: document.documentID as String,
                            userId: document["userId"] as? String ?? "",
                            wishlistName: document["wishlistName"] as? String ?? "",
                            imageName: document["imageName"] as? String ?? "",
                            wishlistDescription: document["wishlistDescription"] as? String ?? nil,
                            //  categories: document["categories"] as? [Category] ?? nil,
                            dateCreated: date
                        )
                        
                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    func addWishlist(wishlist: NewWishListModel,newWishListImages: [UIImage?],completion: @escaping (_ wishlist: NewWishListModel?, _ error: Error?) -> Void) {
        
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
                print("Error: No user is currently logged in.")
                return
            }
        
        let collectionRef = db.collection("wishlists")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateString = dateFormatter.string(from: Date())
        
        if let image = wishlist.imageName, let imageData = image.jpegData(compressionQuality: 0.8) {
            let storageRef = Storage.storage().reference().child("wishlist_images").child("\(UUID().uuidString).jpg")
            
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                guard metadata != nil else {
                    completion(nil, error)
                    return
                }
                
                self.addWishListToFirestore(wishlist: wishlist, imageUrl: storageRef.fullPath, dateString: dateString,newWishListImages: newWishListImages, completion: completion)
            }
        } else {
            self.addWishListToFirestore(wishlist: wishlist, imageUrl: nil, dateString: dateString, newWishListImages: newWishListImages, completion: completion)
        }
    }
    
    func addWishlistReferenceToUser(wishlistId: String, userId: String) {
        let userDocRef = db.collection("users").document(userId)
        
        userDocRef.updateData([
            "wishlists": FieldValue.arrayUnion([wishlistId])
        ]) { error in
            if let error = error {
                print("Error adding wishlist reference to user: \(error)")
            } else {
                print("Successfully added wishlist reference to user.")
            }
        }
    }
    
            
    func addWishListToFirestore(wishlist: NewWishListModel, imageUrl: String?, dateString: String, newWishListImages: [UIImage?], completion: @escaping (_ wishlist: NewWishListModel?, _ error: Error?) -> Void) {

        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            print("Error: No user is currently logged in.")
            return
        }

        let data: [String: Any] = [
            "userId": userId,  // 确保wishlist关联到当前用户
            "wishlistName": wishlist.wishlistName,
            "imageName": imageUrl ?? "",
            "wishlistDescription": wishlist.wishlistDescription ?? "",
            "dateCreated": dateString
        ]
        
        // 直接使用闭包中的 documentReference 变量
            db.collection("wishlists").addDocument(data: data) { error in
                if let error = error {
                    completion(nil, error)
                    return
                } else {
                    // 成功创建文档后获取 documentID
                    let documentID = self.db.collection("wishlists").document().documentID
                    // 将 wishlist ID 添加到用户文档中
                    self.addWishlistReferenceToUser(wishlistId: documentID, userId: userId)
                    completion(wishlist, nil)
                }
            }
        }

            
    func fetchWishLists (completion: @escaping (_ wishlist: [WishListModel]?, _ error: Error?) -> Void) {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            print("Error: No user is currently logged in.")
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user is currently logged in."]))
            return
        }
            db.collection("wishlists").getDocuments() { (querySnapshot, error) in
            guard error == nil else {
                    print("error getting wish lists", error ?? "")
                        return
                    }
                    
            var wishlistsArray: [WishListModel] = []
                    
            for document in querySnapshot!.documents {
                if let dateString = document["dateCreated"] as? String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                    if let date = dateFormatter.date(from: dateString) {
                    var wishlist = WishListModel(
                        wishlistId: document.documentID as String,
                        userId: document["userId"] as? String ?? "",
                        wishlistName: document["wishlistName"] as? String ?? "",
                        imageName: document["imageName"] as? String ?? "",
                        wishlistDescription: document["wishlistDescription"] as? String ?? nil,
                        dateCreated: date
                    )
                                    
                    wishlistsArray.append(wishlist)
                }
            }
        }
                    
                        completion(wishlistsArray, nil)
                        
                }
            }
        
         func fetchUserWishLists(completion: @escaping (_ wishlist: [WishListModel]?, _ error: Error?) -> Void) {
            guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
                print("Error: No user is currently logged in.")
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user is currently logged in."]))
                return
            }
            
            db.collection("wishlists").whereField("userId", isEqualTo: userId).getDocuments { (querySnapshot, error) in
                guard let querySnapshot = querySnapshot, error == nil else {
                    print("Error getting wishlists: \(error?.localizedDescription ?? "")")
                    completion(nil, error)
                    return
                }

                var wishlistsArray: [WishListModel] = []

                for document in querySnapshot.documents {
                    if let dateString = document["dateCreated"] as? String {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                        if let date = dateFormatter.date(from: dateString) {
                            let wishlist = WishListModel(
                                wishlistId: document.documentID,
                                userId: document["userId"] as? String ?? "",
                                wishlistName: document["wishlistName"] as? String ?? "",
                                imageName: document["imageName"] as? String ?? "",
                                wishlistDescription: document["wishlistDescription"] as? String ?? "",
                                dateCreated: date
                            )
                            wishlistsArray.append(wishlist)
                        }
                    }
                }
                
                completion(wishlistsArray, nil)
            }
        }



    func fetchWishListInfo(wishlistId: String, completion: @escaping (_ wishlist: WishListModel?, _ wishes: [WishModel]?, _ error: Error?) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        var wishlist: WishListModel?
        var wishes: [WishModel] = []
        
        // Step 1: 获取基本的 wishlist 信息
        dispatchGroup.enter()
        db.collection("wishlists").document(wishlistId).getDocument { document, error in
            defer { dispatchGroup.leave() }
            
            if let error = error {
                print("Error while fetching wishlist: \(error)")
                completion(nil, nil, error)
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()!
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                let date = dateFormatter.date(from: data["dateCreated"] as? String ?? "") ?? Date()
                
                wishlist = WishListModel(
                    wishlistId: document.documentID,
                    userId: data["userId"] as? String ?? "",
                    wishlistName: data["wishlistName"] as? String ?? "",
                    imageName: data["imageName"] as? String ?? "",
                    wishlistDescription: data["wishlistDescription"] as? String ?? "",
                    dateCreated: date
                )
            }
        }
        
        // Step 2: 获取与该 wishlist 相关的 wishes 信息
        dispatchGroup.enter()
        db.collection("wishes").whereField("wishlistId", isEqualTo: wishlistId).getDocuments { querySnapshot, error in
            defer { dispatchGroup.leave() }
            
            if let error = error {
                print("Error while fetching wishes: \(error)")
                completion(nil, nil, error)
                return
            }
            
            for document in querySnapshot!.documents {
                let wishQuantity = (document["wishQuantity"] as? Int).map { String($0) } ?? "1"
                
                let wish = WishModel(
                    id: document.documentID,
                    userId: document["userId"] as? String ?? "",
                    wishlistId: document["wishlistId"] as? String ?? "",
                    wishName: document["wishName"] as? String ?? "",
                    wishImageName: document["imageName"] as? String ?? "",
                    wishPrice: document["wishPrice"] as? String ?? "",
                    wishLink: document["wishLink"] as? String ?? "",
                    wishQuantity: wishQuantity,
                    wishDescription: document["wishDescription"] as? String ?? "",
                    dateCreated: (document["dateCreated"] as? Timestamp)?.dateValue() ?? Date()
                )
                wishes.append(wish)
            }
        }
        
        // 当所有的异步操作完成后，将结果返回
        dispatchGroup.notify(queue: .main) {
            if let wishlist = wishlist {
                completion(wishlist, wishes, nil)
            } else {
                completion(nil, nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load wishlist details"]))
            }
        }
    }



    func updateWishList(wishlistId: String, wishlist: WishListModel, completion: @escaping (_ done: Bool, _ error: Error?) -> Void) {
        let docRef = db.collection("wishlists").document(wishlistId)
        
        let data: [String: Any] = [
            "imageName": wishlist.imageName,
            "wishlistDescription": wishlist.wishlistDescription ?? FieldValue.delete()
        ]
        
        //直接更新数据，并在回调中处理完成状态
        docRef.updateData(data) { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
    
    func deleteWishList(wishlistId: String, completion: @escaping (_ error: Error?) -> Void) {
        
        
        let docRef = db.collection("wishlists").document(wishlistId).delete { error in
            if let error = error {
                print("Error deleting wishlist: \(error)")
                completion(error)
            }
        }
        
        completion(nil)
    }
    
    func deleteCollection(collectionName: String, batchSize: Int = 100, completion: @escaping (Error?) -> Void) {
        let collectionRef = db.collection(collectionName)
        collectionRef.getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                completion(error)
                return
            }
            
            let batch = collectionRef.firestore.batch()
            
            snapshot.documents.enumerated().forEach { index, document in
                batch.deleteDocument(document.reference)
                
                if index % batchSize == (batchSize - 1) || index == snapshot.documents.count - 1 {
                    batch.commit { batchError in
                        if let batchError = batchError {
                            completion(batchError)
                        }
                    }
                }
            }
        }
    }
    
    func reloadWish(wishId: String, completion: @escaping (_ wish: WishModel?, _ error: Error?) -> Void) {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            print("Error: No user is currently logged in.")
            completion(nil, NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        db.collection("wishes").document(wishId).getDocument { document, error in
            guard error == nil else {
                print("error getting wishes", error ?? "")
                completion(nil, error)
                return
            }
            
            if let document = document, document.exists {
                if let dateString = document["dateCreated"] as? String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                    if let date = dateFormatter.date(from: dateString) {
                        let wishQuantity = (document["wishQuantity"] as? Int).map { String($0) } ?? "1"  // 将 Int 转换为 String
                        let wish = WishModel(
                            id: document.documentID,
                            userId: document["userId"] as? String ?? "",
                            wishlistId: document["wishlistId"] as? String ?? "",
                            wishName: document["wishName"] as? String ?? "",
                            wishImageName: document["wishImageName"] as? String ?? "",
                            wishPrice: document["wishPrice"] as? String ?? "",
                            wishLink: document["wishLink"] as? String ?? "",
                            wishQuantity: wishQuantity,
                            wishDescription: document["wishDescription"] as? String ?? "",
                            dateCreated: date
                        )
                        completion(wish, nil)
                    } else {
                        print("Error parsing date")
                        completion(nil, NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Date parsing error"]))
                    }
                } else {
                    print("Missing dateCreated field")
                    completion(nil, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "dateCreated field not found"]))
                }
            } else {
                print("Document does not exist")
                completion(nil, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"]))
            }
        }
    }

    
    func addWish(wish: NewWishModel, newWishImages: [UIImage?], completion: @escaping (_ wish: NewWishModel?, _ error: Error?) -> Void) {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            print("Error: No user is currently logged in.")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateString = dateFormatter.string(from: Date())
        
        if let image = wish.wishImageName, let imageData = image.jpegData(compressionQuality: 0.8) {
            let storageRef = Storage.storage().reference().child("wish_images").child("\(UUID().uuidString).jpg")
            
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                guard metadata != nil else {
                    completion(nil, error)
                    return
                }
                
                self.addWishToFirestore(wish: wish, imageUrl: storageRef.fullPath, dateString: dateString, userId: userId, completion: completion)
            }
        } else {
            self.addWishToFirestore(wish: wish, imageUrl: nil, dateString: dateString, userId: userId, completion: completion)
        }
    }

    private func addWishToFirestore(wish: NewWishModel, imageUrl: String?, dateString: String, userId: String, completion: @escaping (_ wish: NewWishModel?, _ error: Error?) -> Void) {
        
        let data: [String: Any] = [
            "userId": userId,
            "wishlistId": wish.wishlistId,  // 关联的 wishlistId
            "wishName": wish.wishName,
            "imageName": imageUrl ?? "",
            "wishPrice": wish.wishPrice,
            "wishLink": wish.wishLink,
            "wishQuantity": wish.wishQuantity ?? 1,
            "wishDescription": wish.wishDescription ?? "",
            "dateCreated": dateString
        ]
        
        db.collection("wishes").addDocument(data: data) { error in
            if let error = error {
                completion(nil, error)
            } else {
                completion(wish, nil)
            }
        }
    }
    
    
    func addWishReferenceToUser(wishId: String, userId: String) {
        let userDocRef = db.collection("users").document(userId)
        
        userDocRef.updateData([
            "wishIds": FieldValue.arrayUnion([wishId])
        ]) { error in
            if let error = error {
                print("Error adding wish reference to user: \(error)")
            } else {
                print("Successfully added wish reference to user.")
            }
        }
    }
    
    
    func fetchWishes(completion: @escaping (_ wish: [WishModel]?, _ error: Error?) -> Void)  {
       // let dispatchGroup = DispatchGroup()
        db.collection("wishes").getDocuments() { (querySnapshot, error) in
            guard error == nil else {
                print("error getting wishes", error ?? "")
                return
            }
            
            var wishesArray: [WishModel] = []
            
            for document in querySnapshot!.documents {
                if let dateString = document["dateCreated"] as? String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                    if let date = dateFormatter.date(from: dateString) {
                        let wishQuantity = (document["wishQuantity"] as? Int).map { String($0) } ?? "1"  // 将 Int 转换为 String
                        var wish = WishModel(
                            id: document.documentID as String,
                            userId: document["userId"] as? String ?? "",
                            wishlistId: document["wishlistId"] as? String ?? "",
                            wishName: document["wishName"] as? String ?? "",
                            wishImageName: document["imageName"] as? String ?? "",
                            wishPrice: document["wishPrice"] as? String ?? "",
                            wishLink: document["wishlink"] as? String ?? "",
                            wishQuantity: wishQuantity,  // 已转换为 String
                            wishDescription: document["wishDescription"] as? String ?? nil,
                            //  categories: document["categories"] as? [Category] ?? nil,
                            dateCreated: date
                            )
                            wishesArray.append(wish)
                        }
                    }
                }
                    completion(wishesArray, nil)
        }
    }
        
    func fetchUserWishes(userId: String, completion: @escaping (_ wishes: [WishModel]?, _ error: Error?) -> Void) {
        db.collection("wishes").whereField("userId", isEqualTo: userId).getDocuments { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot, error == nil else {
                print("Error getting wishes: \(error?.localizedDescription ?? "")")
                completion(nil, error)
                return
            }

            var wishesArray: [WishModel] = []

            for document in querySnapshot.documents {
                let wishQuantity = (document["wishQuantity"] as? Int).map { String($0) } ?? "1"
                
                let wish = WishModel(
                    id: document.documentID,
                    userId: document["userId"] as? String ?? "",
                    wishlistId: document["wishlistId"] as? String ?? "",  // 添加 wishlistId
                    wishName: document["wishName"] as? String ?? "",
                    wishImageName: document["imageName"] as? String ?? "",
                    wishPrice: document["wishPrice"] as? String ?? "",
                    wishLink: document["wishLink"] as? String ?? "",
                    wishQuantity: wishQuantity,
                    wishDescription: document["wishDescription"] as? String ?? "",
                    dateCreated: (document["dateCreated"] as? Timestamp)?.dateValue() ?? Date()
                )
                wishesArray.append(wish)
            }
            
            completion(wishesArray, nil)
        }
    }
    
    func updateWish(wishId: String, wish: WishModel, completion: @escaping (_ done: Bool, _ error: Error?) -> Void) {
       // let dispatchGroup = DispatchGroup()
        
        let docRef = db.collection("wishes").document(wishId)
        
        // 准备要更新的数据
        let data: [String: Any] = [
                "wishName": wish.wishName,
                "imageName": wish.wishImageName,
                "wishPrice": wish.wishPrice ?? "",
                "wishLink": wish.wishLink ?? "",
                "wishQuantity": wish.wishQuantity,
                "wishDescription": wish.wishDescription ?? ""
            ]
        
        docRef.updateData(data) { error in
            if let error = error {
                completion(false, error)
                return
            }
            completion(true, nil)
        }
    }

    func deleteWish(wishId: String, completion: @escaping (_ error: Error?) -> Void) {
        db.collection("wishes").document(wishId).delete { error in
            if let error = error {
                print("Error deleting wish: \(error)")
                completion(error)
            } else {
                completion(nil)
            }
        }
    }

}
