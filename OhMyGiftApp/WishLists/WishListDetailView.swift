import SwiftUI

struct Wish: Identifiable {
    var id = UUID()
    var name: String
    var price: String
    var link: String
    var quantity: Int
    var note: String
    var isMustHave: Bool
}

struct WishlistDetailView: View {

    @Binding var wishlists: [WishlistItem]
    
    @Binding var wishlist: WishlistItem
    
    @State private var shouldShowAddWishView = false  // 控制 AddWi
    
    var body: some View {
//            NavigationView { // 添加 NavigationView 包裹整个视图
                VStack(alignment: .center, spacing: 20) {
                    HStack {
                        Image(systemName: wishlist.icon)
                            .resizable()
                            .frame(width: 70, height: 70)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .padding()
                        
                        VStack(alignment: .leading) {
                            Text(wishlist.title)
                                .font(.largeTitle)
                                .bold()
                        }
                    }
                    
                    List(wishlist.wishes) { wish in
                                    VStack(alignment: .leading) {
                                        Text(wish.name)
                                            .font(.headline)
                                        Text("Price: \(wish.price)")
                                            .font(.subheadline)
                                    }
                                }
                    
                    Button {
                                    shouldShowAddWishView.toggle()  // 切换显示 AddWishView
                                } label: {
                                    HStack {
                                        Image(systemName: "plus")
                                        Text("Add Wish")
                                            .font(.headline)
                                            .bold()
                                    }
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                }
                                .padding(.top, 20)
                                .sheet(isPresented: $shouldShowAddWishView) {  // 使用 sheet 显示 AddWishView
                                    AddWishView(
                                        wishlists: $wishlists,  // 传递 wishlists 的绑定
                                        onSave: { id, wish in   // 定义保存 wish 的操作
                                            if let index = wishlists.firstIndex(where: { $0.id == id }) {
                                                wishlists[index].wishes.append(wish)
                                                wishlist = wishlists[index]
                                            }
                                        }
                                    )
                                }
                    
                    Spacer() // 将内容推至顶部
                }
                .padding()
            
        }
    }

    
struct WishlistDetailView_Previews: PreviewProvider {
        @State static var sampleWishlists = [
            WishlistItem(
                title: "General",
                subtitle: "1 List",
                icon: "gift.fill",
                wishes: [
                    Wish(name: "Sample Wish", price: "10.00", link: "", quantity: 1, note: "Sample note", isMustHave: true)
                ]
            )
        ]
        
        @State static var selectedWishlist = sampleWishlists[0]  // 添加一个 State 变量表示当前选中的 wishlist
        
        static var previews: some View {
            WishlistDetailView(wishlists: $sampleWishlists, wishlist: $selectedWishlist)
        }
    }
