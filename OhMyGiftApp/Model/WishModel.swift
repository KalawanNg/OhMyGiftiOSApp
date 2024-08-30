//
//  WishModel.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 27/08/2024.
//

import Foundation
import SwiftUI

struct WishModel: Identifiable, Codable, Hashable {
    var id: String
    var userId: String
    var wishlistId: String  // 新增，用于关联到特定的愿望清单
    var wishName: String
    var wishImageName: String
    var wishPrice: String?
    var wishLink: String?
    var wishQuantity: String?
    var wishDescription: String?
    var dateCreated: Date
}

struct NewWishModel {
    var userId: String
    var wishlistId: String  // 新增，用于关联到特定的愿望清单
    var wishName: String
    var wishImageName: UIImage?
    var wishPrice: String?
    var wishLink: String?
    var wishQuantity: String?
    var wishDescription: String?
}


