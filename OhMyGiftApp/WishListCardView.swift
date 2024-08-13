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
        .foregroundColor(Color(red: 12/255, green: 45/255, blue: 87/255))
        //.background(Color(red: 255/255, green: 239/255, blue: 239/255))
        .background(Color(red: 2485/255, green: 227/255, blue: 225/255))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

#Preview {
    WishListCardView(title: "Sample Title", subtitle: "Sample Subtitle", icon: "gift.fill")
}
