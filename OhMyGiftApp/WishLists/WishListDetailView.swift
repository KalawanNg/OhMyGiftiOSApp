import SwiftUI

struct WishItem: Identifiable {
    var id: String  // 使用字符串 id 而不是 UUID
    var name: String
    var link: String
    var icon: String
    var price: String
    var maingiftname: String
}

struct WishListDetailView: View {
    @State private var wishItems: [WishItem] = []
    @State private var showingWishView = false
    @ObservedObject var viewModel: WishListViewModel
    @Binding var keyname:String
    @Binding var wishlists: [WishlistItem]
    @ObservedObject private var wishlistsRepository = WishListsRepository()
    var keyword:String = ""
    var body: some View {
        ZStack {
            Image("baby-shower")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 350, height: 400)
                .opacity(0.3)
                .position(CGPoint(x: 200, y: 300))
            VStack {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(wishItems.filter { $0.maingiftname == GiftNameClass.SelectedGiftName }) { item in
                            NavigationLink(destination: WishDetailView(
                                title: item.name,
                                subtitle: item.price,
                                imageKey: item.icon,  // Assuming `item.icon` is the image key stored in Firebase
                                viewModel: WishViewModel(
                                    wish: WishModel(
                                        id: item.id,
                                        userId: FirebaseManager.shared.auth.currentUser?.uid ?? "",
                                        wishlistId: viewModel.wishlist?.wishlistId ?? "",
                                        wishName: item.name,
                                        wishImageName: item.icon,  // Assuming `item.icon` is the image key stored in Firebase
                                        wishPrice: item.price,
                                        wishLink: item.link,
                                        wishQuantity: "1",
                                        wishDescription: "",
                                        dateCreated: Date()
                                    ),
                                    wishListId: viewModel.wishlist?.wishlistId ?? ""
                                )
                            )) {
                                WishCardView(title: item.name, subtitle: item.price, imageKey: item.icon) // Pass `imageKey` here
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(25)
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
                            price: newWish.wishPrice ?? "", maingiftname: newWish.maingiftname ?? ""
                        )
                        print("Adding new wish item: \(wishItem)")
                        wishItems.append(wishItem)
                    }
                }
            }
           // .background(Color(red: 232/255, green: 238/255, blue: 255/255))
            .onAppear {
                loadUserWishes()
              
        }
        }
        .background(Color(red: 232/255, green: 238/255, blue: 255/255))
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
                        price: wish.wishPrice ?? "" ,
                        maingiftname: wish.maingiftname ?? ""
                    )
                    print("Loaded wish item: \(wishItem)")
                    print("testing 99999 \(wish.maingiftname)")
                    return wishItem
                }
            } else if let error = error {
                print("Failed to load wishes: \(error.localizedDescription)")
            }
        }
    }
}


//struct WishListDetailView_Previews: PreviewProvider {
//    @State static var testKeyName: String = "Sample Key Name"
//    @State static var testWishlists: [WishlistItem] = [
//        WishlistItem(id: "1", title: "Sample WishList 1", subtitle: "Description 1", icon: "gift.fill", mycategory: "Category 1"),
//        WishlistItem(id: "2", title: "Sample WishList 2", subtitle: "Description 2", icon: "star.fill", mycategory: "Category 2")
//    ]
//    
//    static var previews: some View {
//        WishListDetailView(
//            viewModel: WishListViewModel(
//                wishlist: WishListModel(
//                    wishlistId: "testWishlistID",
//                    userId: "testUserID",
//                    wishlistName: "Test Wishlist",
//                    imageName: "gift.fill",
//                    wishlistDescription: "A test description for this wishlist",
//                    dateCreated: Date()
//                ),
//                wishListId: "testWishlistID"
//            )
//            ）
//    }
//}
//
