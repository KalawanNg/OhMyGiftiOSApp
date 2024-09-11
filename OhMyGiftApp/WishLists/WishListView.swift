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
                VStack(spacing: 30) {  // 这里增加了间距，调整各个部分的距离
                    // Wishlist Icon and Name Input
                    VStack(spacing: 16) {
                        Button{
                            shouldShowImagePicker.toggle()
                        } label: {
                            VStack {
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 158, height: 158)
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
                    
                    // Note Section with more height
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Note")
                            .font(.title2)
                        
                        TextEditor(text: $note)  // 使用 TextEditor 代替 TextField
                            .frame(height: 50)  // 增加 Note 的输入框高度
                            .padding(.all, 8)    // 添加一些内边距
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    }
                    .padding(.horizontal)
                    
                    // Save Button
                    Spacer(minLength: 10)  // 增加按钮上方的间距
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
                                .background(Color(red: 66/255, green: 72/255, blue: 116/255))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .padding(.top)
            }
            .background(Color(red: 246/255, green: 246/255, blue: 246/255))
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $shouldShowImagePicker) {
                ImagePicker(image: $image)
            }
        }
    }
}

struct WishListView_Previews: PreviewProvider {
    static var previews: some View {
        // 创建一个测试的 WishListModel 实例
        let testWishList = WishListModel(
            wishlistId: "testID",
            userId: "testUser",
            wishlistName: "Christmas",
            imageName: "photo",
            wishlistDescription: "A note for Christmas Wishlist",
            dateCreated: Date()
        )
        
        // 调用 WishListView，并提供一个空的 onSave 回调
        WishListView(wishlist: testWishList) { newWishList in
            print("Wishlist Saved: \(newWishList.wishlistName)")
        }
    }
}
