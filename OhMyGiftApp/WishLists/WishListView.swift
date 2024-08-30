//
//  MainWishListView.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 24/08/2024.
//

import SwiftUI

struct WishListView: View {
    @State private var wishlistName: String = ""
    @State private var note: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State var shouldShowImagePicker = false
    @State var image: UIImage?
    
    @ObservedObject var viewModel: WishListViewModel
    
    var onSave: (NewWishListModel) -> Void
        
        init(wishlist: WishListModel, onSave: @escaping (NewWishListModel) -> Void) {
            viewModel = WishListViewModel(wishlist: wishlist, wishListId: wishlist.wishlistId)
            self.onSave = onSave
        }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Wishlist Icon and Name Input
                    VStack(spacing: 10) {
                        Button{
                            shouldShowImagePicker.toggle()
                        } label: {
                            VStack{
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 138, height: 138)
                                        .cornerRadius(64)
                                } else {
                                    Image(systemName: "photo")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(Color(.label))
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64)
                                .stroke(Color.black, lineWidth: 3)
                            )
                        }
                        
                        TextField("e.g. Christmas", text: $wishlistName)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        HStack {
                            Spacer()
                            Text("\(wishlistName.count)/20")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Note Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Note")
                            .font(.headline)
                        TextField("Add note", text: $note)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    // Save Button
                    Button(action: {
                        let newWishlist = NewWishListModel(
                            id: viewModel.wishListId,
                            userId: viewModel.chatUser?.uid ?? "",
                            wishlistName: wishlistName,
                            imageName: image,
                            wishlistDescription: note
                        )

                        viewModel.saveWishlist(newWishlist: newWishlist) {
                            onSave(newWishlist) // 调用回调并传递新创建的 Wishlist
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Save Wishlist")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                    }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        }
                            .padding(.top)
                                }
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $shouldShowImagePicker) {
                ImagePicker(image: $image)
            }
        }
    }
}

#Preview {
    WishListView(
        wishlist: WishListsDummyData.ChrismasWishList,
        onSave: { newWishlist in
            // 您可以在这里处理保存后的动作，例如打印、更新视图等
            print("New wishlist saved: \(newWishlist)")
        }
    )
}
