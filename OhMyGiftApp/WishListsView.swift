import SwiftUI

struct WishlistItem: Identifiable {
    var id = UUID()
    var title: String
    var subtitle: String
    var icon: String
    var wishes: [Wish] = []
}


struct WishListsView: View {
    @State private var showingOptions = false
    @State private var showingAddWishView = false
    @State private var showingAddCategoryView = false
    @State private var showingCreateWishlistView = false

    @State private var wishlistItems = [
            WishlistItem(title: "General", subtitle: "1 List", icon: "gift.fill", wishes: [
                Wish(name: "Sample Wish 1", price: "10.00", link: "", quantity: 1, note: "Sample note 1", isMustHave: true),
                Wish(name: "Sample Wish 2", price: "20.00", link: "", quantity: 2, note: "Sample note 2", isMustHave: false)
            ]),
            WishlistItem(title: "Birthday", subtitle: "Open wishes 3\nTotal £21.99", icon: "house.fill", wishes: [
                Wish(name: "Sample Wish 3", price: "30.00", link: "", quantity: 3, note: "Sample note 3", isMustHave: true),
                Wish(name: "Sample Wish 4", price: "40.00", link: "", quantity: 4, note: "Sample note 4", isMustHave: false)
            ])
        ]

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
                                                    NavigationLink(destination: WishlistDetailView(wishlist: item)) {
                                                        WishListCardView(title: item.title, subtitle: item.subtitle, icon: item.icon)
                                                            .padding()
                                                            .background(Color.white)
                                                            .cornerRadius(10)
                                                            .shadow(radius: 5)
                                                    }
                                                }
                    }
                    .padding()
                }
                Spacer()

//                // 底部弹出菜单
//                ZStack {
//                    if showingOptions {
//                        VStack(spacing: 20) {
//                            Button(action: {
//                                showingAddCategoryView = true
//                            }) {
//                                HStack {
//                                    Image(systemName: "folder.fill")
//                                    Text("Create category")
//                                }
//                                .bold()
//                                .padding()
//                                .foregroundColor(Color(red: 12/255, green: 45/255, blue: 87/255))
//                                .background(Color(red: 255/255, green: 239/255, blue: 239/255))
//                                .cornerRadius(10)
//                                .shadow(radius: 5)
//                            }
//
//                            Button(action: {
//                                showingAddWishView = true
//                            }) {
//                                HStack {
//                                    Image(systemName: "star.fill")
//                                    Text("Add wish")
//                                }
//                                .bold()
//                                .padding()
//                                .foregroundColor(Color(red: 12/255, green: 45/255, blue: 87/255))
//                                .background(Color(red: 255/255, green: 239/255, blue: 239/255))
//                                .cornerRadius(10)
//                                .shadow(radius: 5)
//                            }
//
//                            Button(action: {
//                                showingCreateWishlistView = true
//                            }) {
//                                HStack {
//                                    Image(systemName: "list.bullet")
//                                    Text("Create Wishlist")
//                                }
//                                .bold()
//                                .padding()
//                                .foregroundColor(Color(red: 12/255, green: 45/255, blue: 87/255))
//                                .background(Color(red: 255/255, green: 239/255, blue: 239/255))
//                                .cornerRadius(10)
//                                .shadow(radius: 5)
//                            }
//                        }
//                        .transition(.move(edge: .bottom))
//                        .animation(.easeInOut, value: showingOptions)
//                        .offset(x: 0, y: showingOptions ? 0 : -50)
//                    }
//                }
//                .padding(.bottom, 20)

                // 底部导航栏
                Spacer()
                ZStack {
                    HStack {
                        VStack {
                            Image(systemName: "heart.fill")
                            Text("Wishlists")
                        }
                        .frame(maxWidth: .infinity)

                        NavigationLink(destination: Text("Friends")) {
                            VStack {
                                Image(systemName: "person.2.fill")
                                Text("Friends")
                            }
                        }.frame(maxWidth: .infinity)

                        NavigationLink(destination: Text("Inbox")) {
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

//                    if !showingOptions {
//                        Button(action: {
//                            withAnimation(.easeInOut) {
//                                showingOptions = true
//                            }
//                        }) {
//                            Image(systemName: "plus.circle.fill")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 50, height: 50)
//                                .foregroundColor(Color.white)
//                                .background(Color(red: 46/255, green: 35/255, blue: 108/255))
//                                .clipShape(Circle())
//                                .shadow(radius: 5)
//                        }
//                        .padding(.bottom, -10)
//                        .offset(y: -30)
//                    }
                    
                    if !showingOptions {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                showingCreateWishlistView = true
                            }
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
 
                    
                    if showingOptions {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                showingOptions = false
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 50, height: 50)
                                    .shadow(radius: 10)

                                Text("✖️")
                                    .font(.system(size: 35))
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                        }
                        .offset(y: -35)
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color(red: 244/255, green: 238/255, blue: 255/255))
            .navigationBarHidden(true)
//            .sheet(isPresented: $showingAddWishView) {
//                AddWishView(wishlists: $wishlistItems) { wishlistID, newWish in
//                    if let index = wishlistItems.firstIndex(where: { $0.id == wishlistID }) {
//                        wishlistItems[index].wishes.append(newWish)
//                    }
//                }
//            }
            
            .sheet(isPresented: $showingAddWishView) {
                AddWishView(wishlists: $wishlistItems) { wishlistID, newWish in
                    if let index = wishlistItems.firstIndex(where: { $0.id == wishlistID }) {
                        wishlistItems[index].wishes.append(newWish)
                    }
                }
            }

            
            .sheet(isPresented: $showingAddCategoryView) {
                AddCategoryView()
            }
            .sheet(isPresented: $showingCreateWishlistView) {
                CreateWishlistView { newItem in
                    wishlistItems.append(newItem)
                }
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
        WishListsView()
    }
}
