//
//  WishListModel.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 27/08/2024.
//

import Foundation
import SwiftUI

struct WishListModel: Identifiable, Codable, Hashable {
    var id: String { wishlistId }  // 使用 wishlistId 作为 id
    var wishlistId: String
    var userId: String
    var wishlistName: String
    var imageName: String
    var wishlistDescription: String?
    var dateCreated: Date
}
struct NewWishListModel {
    var id: String
    var userId: String
    var wishlistName: String
    var imageName: UIImage?
    var wishlistDescription: String
}
