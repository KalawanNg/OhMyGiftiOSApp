import SwiftUI

struct WishDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: WishViewModel
    @State var deletionAlert: Bool = false
    
    init(wish: WishModel, wishListId: String) {
        self.viewModel = WishViewModel(wish: wish, wishListId: wishListId)
    }
    
    var body: some View {
        if let fetchedWish = viewModel.wish {
            VStack(alignment: .leading, spacing: 20) {
                // 显示愿望的图片
                if !fetchedWish.wishImageName.isEmpty {
                    Image(fetchedWish.wishImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                }
                
                // 显示愿望名称
                Text(fetchedWish.wishName)
                    .font(.title)
                    .fontWeight(.bold)
                
                // 显示愿望价格
                if let wishPrice = fetchedWish.wishPrice, !wishPrice.isEmpty {
                    Text("Price: \(wishPrice)")
                        .font(.headline)
                }
                
                // 显示愿望链接
                if let wishLink = fetchedWish.wishLink, !wishLink.isEmpty {
                    Link("Purchase Link", destination: URL(string: wishLink)!)
                        .foregroundColor(.blue)
                }
                
                // 显示愿望数量
                if let wishQuantity = fetchedWish.wishQuantity, !wishQuantity.isEmpty {
                    Text("Quantity: \(wishQuantity)")
                        .font(.subheadline)
                }
                
                // 显示愿望描述
                if let wishDescription = fetchedWish.wishDescription, !wishDescription.isEmpty {
                    Text("Description: \(wishDescription)")
                        .font(.body)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitle(fetchedWish.wishName, displayMode: .inline)
            .refreshable {
                viewModel.isRefreshing = true
                viewModel.reloadWish()
            }
            .onAppear {
                viewModel.reloadWish() // 在视图加载时重新加载数据
            }
        } else {
            ProgressView()  // 显示加载状态
        }
    }
}

#Preview {
    WishDetailView(wish: WishModel(
        id: "kURrLR7qVNSai8n7Y1Te",
        userId: "c2Q33BwZSmQBxlmIenV8kH2kX8z1",
        wishlistId: "BNVribYwyKPv4oer1LjV",
        wishName: "New Item",
        wishImageName: " ",
        wishPrice: "20.00",
        wishLink: " ",
        wishQuantity: "1",
        wishDescription: "Sample Description",
        dateCreated: Date()
    ), wishListId: "BNVribYwyKPv4oer1LjV")
}
