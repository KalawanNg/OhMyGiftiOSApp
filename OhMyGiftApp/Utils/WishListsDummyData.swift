//
//  WishListsDummyData.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 28/08/2024.
//

import Foundation

class WishListsDummyData {
    public static var ChrismasWishList: WishListModel = WishListModel(
        wishlistId: UUID().uuidString, // 使用随机生成的 UUID 作为 wishlistId
        userId: "3emnbJygvpUlHvLiQDVpfuk0IsE3", // 假设的用户 ID
        wishlistName: "Chrismas",
        imageName: "chrismastree.jpg",
        wishlistDescription: "These are what I want for Chrismas",
        dateCreated: Date() // 当前日期和时间
    )
}
