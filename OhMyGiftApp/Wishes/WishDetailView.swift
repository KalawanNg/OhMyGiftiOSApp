
import SwiftUI
import FirebaseStorage

struct WishDetailView: View {
    var title: String
    var subtitle: String
    var imageKey: String  // 使用 imageKey 替代 icon 来指定图像的路径
    @ObservedObject var viewModel: WishViewModel
    
    @State private var image: Image? = nil
    @State private var isLoading: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            // 显示愿望图片
            VStack {
                if let image = image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 250, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 20)) // 椭圆形
                        .shadow(radius: 5)  // 添加阴影
                        .padding()
                } else if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 50, height: 50)
                        .padding()
                } else {
                    Image(systemName: "photo")  // 默认图片
                        .resizable()
                        .scaledToFill()
                        .frame(width: 250, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 5)
                        .padding()
                }
            }
            .frame(maxWidth: .infinity)
          //  .background(Color(red: 210/255, green: 224/255, blue: 251/255))
            .background(Color(UIColor.systemGray6))
            .cornerRadius(20)
            .shadow(radius: 5)
            .padding(.horizontal)
            
            // 显示愿望详细信息
            if let fetchedWish = viewModel.wish {
                VStack(alignment: .leading, spacing: 20) {
                    // 愿望名称
                    HStack {
                        Text("Name:")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        Text(fetchedWish.wishName)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 3)

                    // 愿望价格
                    if let wishPrice = fetchedWish.wishPrice, !wishPrice.isEmpty {
                        HStack {
                            Text("Price:")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("￡\(wishPrice)")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 3)
                    }

                    // 愿望链接
                    if let wishLink = fetchedWish.wishLink, !wishLink.isEmpty, let url = URL(string: wishLink) {
                        HStack {
                            Text("Link:")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            Text(wishLink)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)//改
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 3)
                    }

                    // 愿望数量
                    if let wishQuantity = fetchedWish.wishQuantity, !wishQuantity.isEmpty {
                        HStack {
                            Text("Quantity:")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(wishQuantity)")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 3)
                    }

                    // 愿望描述
                    if let wishDescription = fetchedWish.wishDescription, !wishDescription.isEmpty {
                        HStack {
                            Text("Description:")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            Text(wishDescription)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 3)
                    }
                    
                    Spacer()
                }
                .padding()
             //   .background(Color(UIColor.systemGray6))  // 使用灰色背景提升视觉效果
                .background(Color(red: 210/255, green: 224/255, blue: 251/255))
                .cornerRadius(20)
                .padding(.horizontal)
                .navigationBarTitle(fetchedWish.wishName, displayMode: .inline)
            }
        }
        .onAppear {
            downloadImage(key: imageKey)  // 在视图加载时下载图片
        }
       // .background(Color(UIColor.systemGray6))  // 整体背景为浅灰色
        .background(Color(red: 232/255, green: 238/255, blue: 255/255))
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // 从 Firebase 存储中下载图片
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
    WishDetailView(
        title: "Sample Wish",
        subtitle: "Sample Subtitle",
        imageKey: "sampleImageKey",
        viewModel: WishViewModel(wish: WishModel(
            id: "sampleWishID",
            userId: "sampleUserID",
            wishlistId: "sampleWishlistID",
            wishName: "Sample Wish",
            wishImageName: "sampleImagePathInFirebase",  // Replace this with a real Firebase path for testing
            wishPrice: "25.00",
            wishLink: "http://example.com",
            wishQuantity: "1",
            wishDescription: "This is a sample description for the wish.",
            dateCreated: Date()
        ), wishListId: "sampleWishlistID")
    )
}

