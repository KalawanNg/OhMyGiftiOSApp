//
//  ButtonView.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 28/08/2024.
//

import Foundation
import SwiftUI

struct ButtonView: View {
    @State var text: String
    @State var color: Color
    
    var body: some View {
        Text(text)
            .frame(width: UIScreen.main.bounds.width * 0.25)
            .padding(.horizontal)
            .padding(.vertical, 8.0)
            .background(color)
            .cornerRadius(10.0)
            .foregroundColor(Color.white)
    }
}

#Preview {
    ButtonView(text: "Edit", color: Color.green)
}
