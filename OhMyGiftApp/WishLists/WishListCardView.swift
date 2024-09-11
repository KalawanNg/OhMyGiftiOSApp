//
//  WishListCardView.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 18/07/2024.
//

import SwiftUI
import FirebaseStorage

struct WishListCardView: View {
    var title: String
    var subtitle: String
    var imageKey: String  // 使用 imageKey 替代 icon 来指定图像的路径

    @State private var image: Image? = nil
    @State private var isLoading: Bool = true

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color(red: 53/255, green: 21/255, blue: 93/255))
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .padding(.top,10)
            }
            Spacer()
            if let image = image {
                image
                    .resizable()
         
                    .scaledToFill()
                    .frame(width: 100, height: 50)
                    .padding()
                    .clipShape(Circle())
                   
                   
            } else if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(width: 40, height: 40)
                    .padding()
            } else {
                Image(systemName: "photo")  // 默认图标
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .padding()
            }
        }
        .padding()
        .cornerRadius(10)
        

        .onAppear {
            downloadImage(key: imageKey)
        }
    }

    private func downloadImage(key: String) {
        let storage = Storage.storage()
        let imageRef = storage.reference(withPath: key)

        // Convert Int to Int64 for maxSize
        imageRef.getData(maxSize: Int64(10 * 1024 * 1024)) { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                self.isLoading = false
            } else if let data = data, let uiImage = UIImage(data: data) {
                self.image = Image(uiImage: uiImage)
                self.isLoading = false
            }
        }
    }
}


#Preview {
    WishListCardView(title: "Sample Title", subtitle: "Sample Subtitle", imageKey: "gift.fill")
}
