//
//  OhMyGiftAppApp.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 18/07/2024.
//

import SwiftUI

@main
struct OhMyGiftAppApp: App {
    
    init() {
            _ = FirebaseManager.shared // 强制实例化 FirebaseManager 以确保 Firebase 初始化
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
