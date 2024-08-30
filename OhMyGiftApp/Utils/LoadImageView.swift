//
//  LoadImageView.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 28/08/2024.
//

import Foundation
import SwiftUI

struct LoadImageView: View {
    let imageName: String
    let defaultImage: Image
    let reloadTrigger: Bool
    @State private var isLoading = true
    @State private var loadedImage: Image?
    var imagesRepository = ImagesRepository()
    
    init(imageName: String, reloadTrigger: Bool = false, defaultImage: Image = Image("defaultImage")) {
        self.imageName = imageName
        self.reloadTrigger = reloadTrigger
        self.defaultImage = defaultImage
    }

    var body: some View {
        VStack {
            if isLoading {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .modifier(ShimmerEffect())
            } else {
                (loadedImage ?? defaultImage)
                    .resizable()
            }
        }
        .onAppear {
            loadImage()
        }
        .onChange(of: reloadTrigger) { _ in
            loadImage()
        }
    }
    
    func loadImage() {
        isLoading = true
        imagesRepository.getImage(name: imageName) { image in
            DispatchQueue.main.async {
                loadedImage = image // Update the loaded image
                isLoading = false
            }
        }
    }
}

struct ShimmerEffect: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.6), Color.gray.opacity(0.3)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .mask(content)
                        .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                        .animation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false))
                }
            )
            .onAppear {
                isAnimating = true
            }
    }
}

#Preview {
    LoadImageView(imageName: "recipes/toasts.jpg")//改
            .aspectRatio(contentMode: .fill)
            .frame(width: 300, height: 300)
            .cornerRadius(10)
}

