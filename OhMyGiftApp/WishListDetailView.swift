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
    var wishlist: WishlistItem

    var body: some View {
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
            }
        List{
            
        }
//        VStack(alignment: .leading, spacing: 20) {
//            HStack {
//                Image(systemName: wishlist.icon)
//                    .resizable()
//                    .frame(width: 70, height: 70)
//                    .background(Color.gray.opacity(0.2))
//                    .cornerRadius(10)
//                
//                VStack(alignment: .leading) {
//                    Text(wishlist.title)
//                        .font(.largeTitle)
//                        .bold()
//                    
//                    Text(wishlist.subtitle)
//                        .font(.title3)
//                        .foregroundColor(.gray)
//                }
//            }
//            .padding()
//
//            List(wishlist.wishes) { wish in
//                VStack(alignment: .leading) {
//                    Text(wish.name)
//                        .font(.headline)
//                    
//                    Text("Price: \(wish.price)")
//                    
//                    Text("Quantity: \(wish.quantity)")
//                    
//                    if !wish.note.isEmpty {
//                        Text("Note: \(wish.note)")
//                    }
//                }
//                .padding()
//                .background(Color.white) // 添加背景颜色
//                .cornerRadius(10)
//                .shadow(radius: 1)
//            }
//            .listStyle(InsetGroupedListStyle())
//
//            Spacer()
//        }
//        .padding()
//        .navigationTitle(wishlist.title)
//        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WishlistDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WishlistDetailView(
            wishlist: WishlistItem(
                title: "General",
                subtitle: "1 List",
                icon: "gift.fill",
                wishes: [
                    Wish(name: "Sample Wish", price: "10.00", link: "", quantity: 1, note: "Sample note", isMustHave: true)
                ]
            )
        )
    }
}
