//
//import SwiftUI
//
//struct WishItem: Identifiable {
//    var id: String  // 使用字符串 id 而不是 UUID
//    var name: String
//    var link: String
//    var icon: String
//    var price: String
//}
//
//struct WishListDetailView: View {
//    @State private var wishItems: [WishItem] = []
//    @State private var showingWishView = false
//    @ObservedObject var viewModel: WishListViewModel
//    @Binding var wishlists: [WishlistItem]
//    @ObservedObject private var wishlistsRepository = WishListsRepository()
//    
//    var body: some View {
//        VStack {
//            ScrollView {
//                LazyVStack(spacing: 20) {
//                    ForEach(wishItems) { item in  // 使用 wishItems 而不是 $wishItems
//                        NavigationLink(destination: WishDetailView(wish: WishModel(
//                            id: item.id,
//                            userId: FirebaseManager.shared.auth.currentUser?.uid ?? "",
//                            wishlistId: viewModel.wishlist?.wishlistId ?? "",
//                            wishName: item.name,
//                            wishImageName: item.icon,
//                            wishPrice: item.price,
//                            wishLink: item.link,
//                            wishQuantity: "1",
//                            wishDescription: "",
//                            dateCreated: Date()
//                        ), wishListId: viewModel.wishlist?.wishlistId ?? "")) {
//                            WishCardView(title: item.name, subtitle: item.price, icon: item.icon)
//                                .padding()
//                                .background(Color.white)
//                                .cornerRadius(10)
//                                .shadow(radius: 5)
//                        }
//                    }
//
//                    Button(action: {
//                        showingWishView = true
//                    }) {
//                        Image(systemName: "plus.circle.fill")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 50, height: 50)
//                            .foregroundColor(Color.white)
//                            .background(Color(red: 46/255, green: 35/255, blue: 108/255))
//                            .clipShape(Circle())
//                            .shadow(radius: 5)
//                    }
//                    .padding(.bottom, -10)
//                }
//                .padding()
//            }
//            .onAppear {
//                loadUserWishes()
//            }
//            
//            .sheet(isPresented: $showingWishView) {
//                WishView(
//                        wishlists: $wishlists,
//                        viewModel: WishViewModel(wish: WishModel(
//                            id: UUID().uuidString,
//                            userId: FirebaseManager.shared.auth.currentUser?.uid ?? "",
//                            wishlistId: viewModel.wishlist?.wishlistId ?? "",
//                            wishName: "",
//                            wishImageName: "",
//                            wishPrice: "",
//                            wishLink: "",
//                            wishQuantity: "1",
//                            wishDescription: "",
//                            dateCreated: Date()
//                        ), wishListId: viewModel.wishlist?.wishlistId ?? "")
//                ) { selectedWishlistId, newWish in
//                    let wishItem = WishItem(
//                        id: UUID().uuidString,
//                        name: newWish.wishName,
//                        link: newWish.wishLink ?? "",
//                        icon:  "gift.fill",
//                        price: newWish.wishPrice ?? ""
//                    )
//                    wishItems.append(wishItem)
//                }
//            }
//        }
//    }
//
//    private func loadUserWishes() {
//        let userId = FirebaseManager.shared.auth.currentUser?.uid ?? ""
//        wishlistsRepository.fetchUserWishes(userId: userId) { wishes, error in
//            if let wishes = wishes {
//                wishItems = wishes.map { wish in
//                    WishItem(
//                        id: wish.id,  // 使用服务器返回的 id 而不是生成新的 UUID
//                        name: wish.wishName,
//                        link: wish.wishLink ?? "",
//                        icon: wish.wishImageName,
//                        price: wish.wishPrice ?? ""
//                    )
//                }
//            } else if let error = error {
//                print("Failed to load wishes: \(error.localizedDescription)")
//            }
//        }
//    }
//}
//
//#Preview {
//    WishListDetailView(viewModel: WishListViewModel(wishlist: WishListModel(
//        wishlistId: "sampleWishlistId",
//        userId: "sampleUserId",
//        wishlistName: "Sample Wishlist",
//        imageName: "sampleImageName",
//        wishlistDescription: "Sample description",
//        dateCreated: Date()
//    ), wishListId: "sampleWishlistId"), wishlists: .constant([]))
//}

import SwiftUI

struct WishItem: Identifiable {
    var id: String  // 使用字符串 id 而不是 UUID
    var name: String
    var link: String
    var icon: String
    var price: String
}

struct WishListDetailView: View {
    @State private var wishItems: [WishItem] = []
    @State private var showingWishView = false
    @ObservedObject var viewModel: WishListViewModel
    @Binding var wishlists: [WishlistItem]
    @ObservedObject private var wishlistsRepository = WishListsRepository()
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(wishItems) { item in
                        // 添加调试语句，打印当前 item 的信息
                        
                        NavigationLink(destination: WishDetailView(wish: WishModel(
                            id: item.id,
                            userId: FirebaseManager.shared.auth.currentUser?.uid ?? "",
                            wishlistId: viewModel.wishlist?.wishlistId ?? "",
                            wishName: item.name,
                            wishImageName: item.icon,
                            wishPrice: item.price,
                            wishLink: item.link,
                            wishQuantity: "1",
                            wishDescription: "",
                            dateCreated: Date()
                        ), wishListId: viewModel.wishlist?.wishlistId ?? "")) {
                            WishCardView(title: item.name, subtitle: item.price, icon: item.icon)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                    }

                    Button(action: {
                        showingWishView = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color.white)
                            .background(Color(red: 46/255, green: 35/255, blue: 108/255))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding(.bottom, -10)
                }
                .padding()
            }
            .onAppear {
                loadUserWishes()
            }
            
            .sheet(isPresented: $showingWishView) {
                WishView(
                        wishlists: $wishlists,
                        viewModel: WishViewModel(wish: WishModel(
                            id: UUID().uuidString,
                            userId: FirebaseManager.shared.auth.currentUser?.uid ?? "",
                            wishlistId: viewModel.wishlist?.wishlistId ?? "",
                            wishName: "",
                            wishImageName: "",
                            wishPrice: "",
                            wishLink: "",
                            wishQuantity: "1",
                            wishDescription: "",
                            dateCreated: Date()
                        ), wishListId: viewModel.wishlist?.wishlistId ?? "")
                ) { selectedWishlistId, newWish in
                    let wishItem = WishItem(
                        id: UUID().uuidString,
                        name: newWish.wishName,
                        link: newWish.wishLink ?? "",
                        icon:  "gift.fill",
                        price: newWish.wishPrice ?? ""
                    )
                    print("Adding new wish item: \(wishItem)")
                    wishItems.append(wishItem)
                }
            }
        }
    }

    private func loadUserWishes() {
        let userId = FirebaseManager.shared.auth.currentUser?.uid ?? ""
        wishlistsRepository.fetchUserWishes(userId: userId) { wishes, error in
            if let wishes = wishes {
                wishItems = wishes.map { wish in
                    let wishItem = WishItem(
                        id: wish.id,
                        name: wish.wishName,
                        link: wish.wishLink ?? "",
                        icon: wish.wishImageName,
                        price: wish.wishPrice ?? ""
                    )
                    print("Loaded wish item: \(wishItem)")
                    return wishItem
                }
            } else if let error = error {
                print("Failed to load wishes: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    WishListDetailView(viewModel: WishListViewModel(wishlist: WishListModel(
        wishlistId: "sampleWishlistId",
        userId: "sampleUserId",
        wishlistName: "Sample Wishlist",
        imageName: "sampleImageName",
        wishlistDescription: "Sample description",
        dateCreated: Date()
    ), wishListId: "sampleWishlistId"), wishlists: .constant([]))
}
