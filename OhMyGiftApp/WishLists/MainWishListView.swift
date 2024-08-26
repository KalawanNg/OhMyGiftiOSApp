//
//  MainWishListView.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 24/08/2024.
//

import SwiftUI

struct MainWishListView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(0..<10, id: \.self) { num in
                HStack{
                    Text("WishListImage")
                    VStack {
                        Text("WishListname")
                        Text("Wish Item")
                    }
                    Spacer()
                    
                    Text("22d")
                        .font(.system(size: 14, weight: .semibold))
                    }
                    Divider()
                }
            }
            .navigationTitle("Main WishList View")
        }
    }
}

#Preview {
    MainWishListView()
}
