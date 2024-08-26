//
//  WishlistRepository.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 25/08/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class WishlistRepository: ObservableObject {
    private var db = Firestore.firestore()
    
    func reloadWishlist(wishlistId: String, completion: @escaping (_ wishlist: WishListModel?, _ error: Error?) -> Void) {
        
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
                print("Error: No user is currently logged in.")
                return
            }
        
        let dispatchGroup = DispatchGroup()
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
                            id: document.documentID as String,
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
                
                self.addWishListToFirestore(wishlist: wishlist, imageUrl: storageRef.fullPath, dateString: dateString, stringCategories: stringCategories, newWishListImage: newWishListImage, completion: completion)
            }
        } else {
            self.addWishListToFirestore(recipe: recipe, imageUrl: nil, dateString: dateString, stringCategories: stringCategories, newWishListImage: newWishListImage, completion: completion)
        }
    }
    
            
           func addWishiListToFirestore(wishlist: NewWishListModel, imageUrl: String?, dateString: String, newWishListImages: [UIImage?], completion: @escaping (_ recipe: NewRecipeModel?, _ error: Error?) -> Void) {
                
//                guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
//                        print("Error: No user is currently logged in.")
//                        return
//                    }
                
                let data: [String: Any] = [
                    "userId": wishlist.userId,
                    "wishlistName": wishlist.wishlistName,
                    "imageName": imageUrl ?? "", // Save the image URL
                    "wishlistDescription": wishlist.wishlistDescription ?? nil,
                    "dateCreated": dateString
                ]
                
                let docRef = db.collection("wishlists").addDocument(data: data) { error in
                    if let error = error {
                        completion(nil, error)
                        return
                    } else {
                        completion(wishlist, nil)
                    }
                }
                
                completion(wishlist, nil)
            }

            
    func fetchWishLists (completion: @escaping (_ wishlist: [WishListModel]?, _ error: Error?) -> Void) {
            let dispatchGroup = DispatchGroup()
            db.collection("wishlists").getDocuments() { (querySnapshot, error) in
            guard error == nil else {
                    print("error getting recipes", error ?? "")
                        return
                    }
                    
            var wishlistsArray: [WishListModel] = []
                    
            for document in querySnapshot!.documents {
                if let dateString = document["dateCreated"] as? String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                    if let date = dateFormatter.date(from: dateString) {
                    var wishlist = WishListModel(
                        id: document.documentID as String,
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
        
        func fetchUserWishLists (completion: @escaping (_ wishlist: [WishListModel]?, _ error: Error?) -> Void) {
                let dispatchGroup = DispatchGroup()
                db.collection("wishlists").getDocuments() { (querySnapshot, error) in
                guard error == nil else {
                        print("error getting recipes", error ?? "")
                            return
                        }
                        
                var wishlistsArray: [WishListModel] = []
                        
                for document in querySnapshot!.documents {
                    if let dateString = document["dateCreated"] as? String {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                        if let date = dateFormatter.date(from: dateString) {
                        var wishlist = WishListModel(
                            id: document.documentID as String,
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


    func fetchWishListInfo(wishlistId: String, completion: @escaping (_ wishlist: WishListModel?, _ error: Error?) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        var wishlist: WishListModel?
        var wishes: [WishModel] = []
        
        // Step 1: 获取基本的 wishlist 信息
        dispatchGroup.enter()
        db.collection("wishlists").document(wishlistId).getDocument { document, error in
            defer { dispatchGroup.leave() }
            
            if let error = error {
                print("Error while fetching wishlist: \(error)")
                completion(nil, error)
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()!
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                let date = dateFormatter.date(from: data["dateCreated"] as? String ?? "") ?? Date()
                
                wishlist = WishListModel(
                    id: document.documentID,
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
                completion(nil, error)
                return
            }
            
            for document in querySnapshot!.documents {
                let wish = WishModel(
                    id: document.documentID,
                    userId: document["userId"] as? String ?? "",
                    wishName: document["wishName"] as? String ?? "",
                    imageName: document["imageName"] as? String ?? "",
                    wishPrice: document["wishPrice"] as? String ?? "",
                    wishLink: document["wishLink"] as? String ?? "",
                    wishQuantity: document["wishQuantity"] as? Int ?? 1,
                    wishDescription: document["wishDescription"] as? String ?? ""
                )
                wishes.append(wish)
            }
        }
        
        // 当所有的异步操作完成后，将结果返回
        dispatchGroup.notify(queue: .main) {
            if var wishlist = wishlist {
                wishlist.wishes = wishes
                completion(wishlist, nil)
            } else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load wishlist details"]))
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
    
    func reloadWish(wishId: String, completion: @escaping (_ recipe: wishModel?, _ error: Error?) -> Void) {
        
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
                print("Error: No user is currently logged in.")
                return
            }
        
        let dispatchGroup = DispatchGroup()
        db.collection("wishes").document(wishId).getDocument { document, error in
            guard error == nil else {
                print("error getting wishes", error ?? "")
                return
            }
            
            if let document = document {
                if let dateString = document["dateCreated"] as? String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                    if let date = dateFormatter.date(from: dateString) {
                        var wish = WishModel(
                            id: document.documentID as String,
                            userId: document["userId"] as? String ?? "",
                            wishName: document["wishName"] as? String ?? "",
                            imageName: document["imageName"] as? String ?? "",
                            wishPrice: document["wishPrice"] as? String ?? "",
                            wishLink: document["wishlink"] as? String ?? "",
                            wishQuantity: document["wishQuantity"] as? Int ?? 1,
                            wishDescription: document["wishDescription"] as? String ?? nil
                          //  categories: document["categories"] as? [Category] ?? nil,
                            dateCreated: date
                        )
                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    func addWish(wish: NewWishModel, newWishImages: [UIImage?], completion: @escaping (_ wish: NewWishModel?, _ error: Error?) -> Void) {
        let collectionRef = db.collection("wishes")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateString = dateFormatter.string(from: Date())
        
        
        if let image = wish.imageName, let imageData = image.jpegData(compressionQuality: 0.8) {
            let storageRef = Storage.storage().reference().child("wish_images").child("\(UUID().uuidString).jpg")
            
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                guard metadata != nil else {
                    completion(nil, error)
                    return
                }
                
                self.addWishToFirestore(wish: wish, imageUrl: storageRef.fullPath, dateString: dateString, newWishImages: newWishImages, completion: completion)
            }
        } else {
            self.addWishToFirestore(wish: wish, imageUrl: storageRef.fullPath, dateString: dateString, newWishImages: newWishImages, completion: completion)
        }
    }
    
    private func addWishToFirestore(recipe: NewWishModel, imageUrl: String?, dateString: String, newWishImages: [UIImage?], completion: @escaping (_ recipe: NewRecipeModel?, _ error: Error?) -> Void) {
        
//        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
//                print("Error: No user is currently logged in.")
//                return
//            }
        
        let data: [String: Any] = [
            "userId": wish.userId,
            "wishName": wish.wishName,
            "imageName": imageUrl ?? "", // Save the image URL
            "wishPrice": wish.wishPrice,
            "wishLink": wish.wishLink,
            "wishQuantity":wish.wishQuantity,
            "wishDescription": wish.wishDescription ?? nil,
            "dateCreated": dateString
        ]
        
        let docRef = db.collection("wishes").addDocument(data: data) { error in
            if let error = error {
                completion(nil, error)
                return
            } else {
                completion(wish, nil)
            }
        }
        
        completion(wish, nil)
    }
    
    func fetchWishes(completion: @escaping (_ wish: [WishModel]?, _ error: Error?) -> Void)  {
        let dispatchGroup = DispatchGroup()
        db.collection("wishes").getDocuments() { (querySnapshot, error) in
            guard error == nil else {
                print("error getting wishes", error ?? "")
                return
            }
            
            var recipesArray: [WishModel] = []
            
            for document in querySnapshot!.documents {
                if let dateString = document["dateCreated"] as? String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                    if let date = dateFormatter.date(from: dateString) {
                        var wish = WishModel(
                            id: document.documentID as String,
                            userId: document["userId"] as? String ?? "",
                            wishName: document["wishName"] as? String ?? "",
                            imageName: document["imageName"] as? String ?? "",
                            wishPrice: document["wishPrice"] as? String ?? "",
                            wishLink: document["wishlink"] as? String ?? "",
                            wishQuantity: document["wishQuantity"] as? Int ?? 1,
                            wishDescription: document["wishDescription"] as? String ?? nil
                            //  categories: document["categories"] as? [Category] ?? nil,
                            dateCreated: date
                            )
                        }
                    }
                }
                    completion(recipesArray, nil)
        }
    }
        
        func fetchUserWishes(userId: String, completion: @escaping (_ wish: [WishModel]?, _ error: Error?) -> Void) {
            let dispatchGroup = DispatchGroup()
            db.collection("wishes").whereField("userId", isEqualTo: userId).getDocuments { (querySnapshot, error) in
                guard let querySnapshot = querySnapshot, error == nil else {
                    print("Error getting wishes: \(error?.localizedDescription ?? "")")
                    completion(nil, error)
                    return
                }

                var wishesArray: [WishModel] = []

                for document in querySnapshot.documents {
                    if let dateString = document["dateCreated"] as? String {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                        if let date = dateFormatter.date(from: dateString) {
                            var wish = WishModel(
                                id: document.documentID as String,
                                userId: document["userId"] as? String ?? "",
                                wishName: document["wishName"] as? String ?? "",
                                imageName: document["imageName"] as? String ?? "",
                                wishPrice: document["wishPrice"] as? String ?? "",
                                wishLink: document["wishlink"] as? String ?? "",
                                wishQuantity: document["wishQuantity"] as? Int ?? 1,
                                wishDescription: document["wishDescription"] as? String ?? nil
                                //  categories: document["categories"] as? [Category] ?? nil,
                                dateCreated: date
                            )
                        }
                    }
                }
                        completion(recipesArray, nil)
                }
            }
        
        
        //    func fetchWishListInfo(forWishList: WishListModel, completion: @escaping (_ wishlist: WishListModel?, _ error: Error?) -> Void) {
        //        let dispatchGroup = DispatchGroup()
        //
        //        dispatchGroup.enter()
        //        self.fetchSteps(recipeId: forRecipe.id) { (recipeSteps, error) in
        //            defer {
        //                dispatchGroup.leave()
        //            }
        //
        //            if let error = error {
        //                print("Error while fetching the recipe ingredient: \(error)")
        //                return
        //            }
        //            steps = recipeSteps
        //        }
        //
        //        var ingredients: [RecipeModel.RecipeIngridient]?
        //        dispatchGroup.enter()
        //        self.fetchRecipeIngredients(recipeId: forRecipe.id) { (recipeIngredients, error) in
        //            defer {
        //                dispatchGroup.leave()
        //            }
        //
        //            if let error = error {
        //                print("Error while fetching the recipe ingredient: \(error)")
        //                return
        //            }
        //            ingredients = recipeIngredients
        //        }
        //
        //        dispatchGroup.notify(queue: .main) {
        //            if let ingredients = ingredients, let steps = steps {
        //                var recipe = forRecipe
        //                recipe.ingredients = ingredients
        //                recipe.steps = steps
        //                completion(recipe, nil)
        //            }
        //        }
        //    }
    
    func updateWish(wishId: String, wish: WishModel, completion: @escaping (_ done: Bool, _ error: Error?) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        let docRef = db.collection("wishes").document(wishId)
        
        // 准备要更新的数据
        let data: [String: Any] = [
            "imageName": wish.imageName,
            "wishDescription": wish.wishDescription ?? FieldValue.delete(),
            "wishQuantity": wish.wishQuantity,
            "wishPrice": wish.wishPrice,
            "wishLink": wish.wishLink
        ]
        
        //更新 wish 的基础数据
        dispatchGroup.enter()
        docRef.updateData(data) { error in
            if let error = error {
                completion(false, error)
                dispatchGroup.leave()
                return
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(true, nil)
        }
    }

    func deleteWish(wishId: String, completion: @escaping (_ error: Error?) -> Void) {
        
        let docRef = db.collection("wishes").document(wishId).delete { error in
            if let error = error {
                print("Error deleting recipe: \(error)")
                completion(error)
            }
        }
        
        completion(nil)
    }
}
