//
//  WishCardView.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 30/08/2024.
//

import SwiftUI

struct WishCardView: View {
    var title: String
    var subtitle: String
    var icon: String

    var body: some View {
        HStack {
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            Spacer()
            Image(systemName: icon)
                .resizable()
                .frame(width: 50, height: 50)
                .padding()
            Spacer()
        }
        .padding()
       // .background(Color(red: 2485/255, green: 227/255, blue: 225/255))
        .cornerRadius(10)
       // .shadow(radius: 1)
    }
}

#Preview {
    WishCardView(title: "Sample Title", subtitle: "Sample Subtitle", icon: "gift.fill")
}
