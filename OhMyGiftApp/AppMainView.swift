
import SwiftUI
import SwiftUI

struct WishlistItem: Identifiable {
    var id: String
    var title: String
    var subtitle: String
    var icon: String
    var mycategory:String
}

struct AppMainView: View {
    @State private var showingWishListView = false
    @State private var selectedWishlistModel: WishListModel? // 用于存储选择的 wishlist 模型
    @State private var keyname: String = "" // 用于存储 keyname
    @ObservedObject private var wishlistsRepository = WishListsRepository()
    @State private var wishlistItems: [WishlistItem] = []

    var body: some View {
        NavigationView {
            VStack {
                // 顶部标题栏
                HStack {
                    Text("Wishlists")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color(red: 246/255, green: 246/255, blue: 246/255))
                    Spacer()
                    HStack(spacing: 20) {
                        Image(systemName: "arrow.up.arrow.down")
                        Image(systemName: "line.horizontal.3")
                    }
                    .bold()
                    .foregroundColor(Color(red: 246/255, green: 246/255, blue: 246/255))
                }
                .padding()
                .background(Color(red: 66/255, green: 72/255, blue: 116/255))

                // 主内容区域
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(wishlistItems) { item in
                            let wishListModel = WishListModel(
                                wishlistId: item.id,
                                userId: FirebaseManager.shared.auth.currentUser?.uid ?? "",
                                wishlistName: item.title,
                                imageName: item.icon,
                                wishlistDescription: item.subtitle,
                                dateCreated: Date()  // 使用实际的创建日期
                            )

                            // 使用 NavigationLink 包裹 WishListCardView
                            NavigationLink(destination: WishListDetailView(
                                viewModel: WishListViewModel(wishlist: wishListModel, wishListId: item.id),
                                keyname: $keyname,
                                wishlists: $wishlistItems
                            ).onAppear {
                                // 在目标视图出现时更新 keyname
                                keyname = item.title
                            }) {
                                WishListCardView(title: item.title, subtitle: item.subtitle, imageKey: item.icon)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                // 点击后延迟 2 秒执行打印
                               
                                    print("testing ok \(item.title)")
                                    GiftNameClass.SelectedGiftName = item.title
                                
                            })
                        }
                    }
                    .padding()
                }
                Spacer()

                // 底部导航栏
                ZStack {
                    HStack {
                        VStack {
                            Image(systemName: "heart.fill")
                            Text("Wishlists")
                        }
                        .frame(maxWidth: .infinity)

                        NavigationLink(destination: MainMessagesView()) {
                            VStack {
                                Image(systemName: "person.2.fill")
                                Text("Friends")
                            }
                        }.frame(maxWidth: .infinity)

                        NavigationLink(destination: ProfileView()) {
                            VStack {
                                Image(systemName: "bell.fill")
                                Text("Inbox")
                            }
                        }.frame(maxWidth: .infinity)

                        NavigationLink(destination: LogInView(didCompleteLoginProcess: {})) {
                            VStack {
                                Image(systemName: "gearshape.fill")
                                Text("Settings")
                            }
                        }.frame(maxWidth: .infinity)
                    }
                    .bold()
                    .padding(.vertical, 15)
                    .background(Color(red: 66/255, green: 72/255, blue: 116/255))
                    .foregroundColor(Color(red: 246/255, green: 246/255, blue: 246/255))
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .shadow(radius: 10)

                    Button(action: {
                        showingWishListView = true
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
                    .offset(y: -30)
                }
                .padding(.bottom, 20)
            }
            .background(Color(red: 244/255, green: 238/255, blue: 255/255))
            .navigationBarHidden(true)
            .onAppear {
                loadUserWishlists()
            }
            
            .sheet(isPresented: $showingWishListView) {
                           WishListView(
                               wishlist: WishListModel(
                                   wishlistId: UUID().uuidString,
                                   userId: FirebaseManager.shared.auth.currentUser?.uid ?? "",
                                   wishlistName: "",
                                   imageName: "",
                                   wishlistDescription: "",
                                   dateCreated: Date()
                               ),
                               onSave: { newWishlist in
                                   let wishlistItem = WishlistItem(
                                       id: newWishlist.id,
                                       title: newWishlist.wishlistName,
                                       subtitle: newWishlist.wishlistDescription ?? "",
                                       icon: "gift.fill", mycategory: newWishlist.wishlistName // 根据需要传递图标或图片
                                   )
                                   wishlistItems.append(wishlistItem)
                               }
                           )
                       }
        }
    }

    private func loadUserWishlists() {
        wishlistsRepository.fetchUserWishLists { wishlists, error in
            if let wishlists = wishlists {
                // 将 wishlists 转换为 wishlistItems
                wishlistItems = wishlists.map { wishlist in
                    WishlistItem(
                        id: wishlist.id,
                        title: wishlist.wishlistName,
                        subtitle: wishlist.wishlistDescription ?? "",
                        icon: wishlist.imageName, mycategory: wishlist.maingiftname ?? ""  // 使用正确的图标
                    )
                }
            } else if let error = error {
                print("Failed to load wishlists: \(error.localizedDescription)")
            }
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct WishListsView_Previews: PreviewProvider {
    static var previews: some View {
        AppMainView()
    }
}
