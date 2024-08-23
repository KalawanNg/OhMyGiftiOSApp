//
//  ChatUser.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 18/08/2024.
//

import Foundation
import Firebase
import FirebaseFirestore

struct ChatUser: Identifiable {
    
    var id: String { uid }
    
    let uid, email, profileImageUrl: String
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
    }
}

//struct ChatUser: Codable, Identifiable {
//    @DocumentID var id: String?
//    let uid, email, profileImageUrl: String
//}

