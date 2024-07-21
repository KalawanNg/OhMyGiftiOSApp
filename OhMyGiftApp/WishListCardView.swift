//
//  WishListCardView.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 18/07/2024.
//

import SwiftUI

struct WishListCardView: View {
    var title: String
    var subtitle: String
    var icon: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2)
                    .bold()
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            Image(systemName: icon)
                .resizable()
                .frame(width: 40, height: 40)
                .padding()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

#Preview {
    WishListCardView(title: "Sample Title", subtitle: "Sample Subtitle", icon: "gift.fill")
}
