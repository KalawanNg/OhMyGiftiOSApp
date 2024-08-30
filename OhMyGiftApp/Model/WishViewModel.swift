//
//  WishViewModel.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 30/08/2024.
//

import Foundation
import SwiftUI

class WishViewModel: ObservableObject {
    @Published var wish: WishModel?
    @Published var wishListId: String = ""
    @Published var isDeleted: Bool = false
    @Published var isEditing: Bool = false
    @Published var deletionAlert: Bool = false
    @Published var isRefreshing = false

    private var wishlistsRepository = WishListsRepository()

    init(wish: WishModel, wishListId: String) {
        self.wishListId = wishListId
        fetchWish(wishId: wish.id)
    }

    func fetchWish(wishId: String) {
        print("Fetching wish with ID: \(wishId)") // 调试日志
        wishlistsRepository.reloadWish(wishId: wishId) { [weak self] wish, error in
            guard let self = self else { return }
            if let error = error {
                print("Error while fetching the wish: \(error)")
                return
            } else {
                print("Fetched wish: \(wish)") // 调试日志
                self.wish = wish
            }
        }
    }
    
    func saveWish(newWish: NewWishModel, completion: @escaping () -> Void) {
        wishlistsRepository.addWish(wish: newWish, newWishImages: [newWish.wishImageName]) { _, error in
            if let error = error {
                print("Error saving wish: \(error)")
                return
            }
            completion()
        }
    }

    func reloadWish() {
        guard let wish = self.wish else {
            return
        }
        wishlistsRepository.reloadWish(wishId: wish.id) { [weak self] wish, error in
            guard let self = self else { return }
            if let error = error {
                print("Error while fetching(reloading) the wish: \(error)")
                self.isRefreshing = false
                return
            } else {
                DispatchQueue.main.async {
                    self.wish = wish
                    self.isRefreshing = false
                }
            }
        }
    }

    func deleteWish(completion: @escaping () -> Void) {
        if let id = wish?.id {
            wishlistsRepository.deleteWish(wishId: id) { error in
                if let error = error {
                    print("Error deleting wish: \(error.localizedDescription)")
                } else {
                    self.isDeleted = true
                    completion()
                }
            }
        }
    }
}
