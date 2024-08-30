//
//  WishListModel.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 25/08/2024.


import Foundation
import SwiftUI

class WishListViewModel: ObservableObject {
    @Published var chatUser: ChatUser?
    @Published var wishlist: WishListModel?
    @Published var wishListId: String = ""
    @Published var wishes: [WishModel] = []//store wishes in wishlistViewModel
    @Published var isDeleted: Bool = false
    @Published var isEditing: Bool = false
    @Published var deletionAlert: Bool = false
    @Published var isRefreshing = false

    private var wishlistsRepository = WishListsRepository()
    private var usersRepository = ChatUserRepository()

    init(wishlist: WishListModel, wishListId: String) {
        // 获取当前登录用户的 UID
                if let uid = FirebaseManager.shared.auth.currentUser?.uid {
                    self.chatUser = ChatUser(data: ["uid": uid, "email": "", "profileImageUrl": ""])
                    fetchUser(userId: uid) // 更新 chatUser 的信息
                }
                self.wishListId = wishListId
                fetchWishList(wishlist: wishlist)
    }

    func fetchWishList(wishlist: WishListModel) {
        wishlistsRepository.fetchWishListInfo(wishlistId: wishlist.wishlistId) { [weak self] wishlist, wishes, error in
            guard let self = self else { return }
            if let error = error {
                print("Error while fetching the wishlist: \(error)")
                return
            } else {
                self.wishlist = wishlist
                self.wishes = wishes ?? [] //store wishes in ViewModel
            }
        }
    }
    
    func saveWishlist(newWishlist: NewWishListModel, completion: @escaping () -> Void) {
            wishlistsRepository.addWishlist(wishlist: newWishlist, newWishListImages: [newWishlist.imageName]) { _, error in
                if let error = error {
                    print("Error saving wishlist: \(error)")
                    return
                }
                completion()
            }
        }


    func reloadWishList() async {
        guard let wishlist = self.wishlist else {
            return
        }
        wishlistsRepository.reloadWishlist(wishlistId: wishlist.wishlistId) { [weak self] wishlist, error in
            guard let self = self else { return }
            if let error = error {
                print("Error while fetching the wishlist: \(error)")
                self.isRefreshing = false
                return
            } else {
                DispatchQueue.main.async {
                    self.wishlist = wishlist
                    self.isRefreshing = false
                }
            }
        }
    }

    func fetchUser(userId: String) {
        usersRepository.fetchProfile(userId: userId) { [weak self] chatUser, error in
            if let error = error {
                print("Error while fetching the user profile: \(error)")
                return
            }
            
            if let chatUser = chatUser {
                self?.chatUser = chatUser
            } else {
                print("Error: User profile not found.")
            }
        }
    }

    func deleteWishList(completion: @escaping () -> Void) {
        if let id = wishlist?.wishlistId {
            wishlistsRepository.deleteWishList(wishlistId: id) { error in
                if let error = error {
                    print("Error deleting wishlist: \(error.localizedDescription)")
                } else {
                    self.isDeleted = true
                    completion()
                }
            }
        }
    }
}
