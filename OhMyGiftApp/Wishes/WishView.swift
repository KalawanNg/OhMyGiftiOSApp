import SwiftUI

struct WishView: View {
    @State private var itemName = ""
    @State private var price = ""
    @State private var link = ""
    @State private var quantity = "1"
    @State private var note = ""
    @State private var selectedWishlistId: String?
    @State private var image: UIImage?

    @Environment(\.presentationMode) var presentationMode
    @Binding var wishlists: [WishlistItem]
    @State var shouldShowImagePicker = false
    
    // 传入 WishViewModel 以管理愿望的创建与保存
    @ObservedObject var viewModel: WishViewModel
    
    var onSave: (String, NewWishModel) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Information")) {
                    TextField("e.g beer dispenser", text: $itemName)
                        .font(.title)
                        .padding()
                    
                    Picker("Select Wishlist", selection: $selectedWishlistId) {
                        ForEach(wishlists) { wishlist in
                            Text(wishlist.title).tag(wishlist.id)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onAppear {
                        if selectedWishlistId == nil, let firstWishlist = wishlists.first {
                            selectedWishlistId = firstWishlist.id
                        }
                    }

                    HStack {
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
                        Text("Image")
                        Spacer()
                    }
                    .padding()

                    HStack {
                        Image(systemName: "tag")
                        Text("Price")
                        Spacer()
                        TextField("Enter price", text: $price)
                            .keyboardType(.decimalPad)
                    }
                    .padding()
                    
                    HStack {
                        Image(systemName: "link")
                        Text("Link")
                        Spacer()
                        TextField("Add link", text: $link)
                            .keyboardType(.URL)
                    }
                    .padding()
                    
                    HStack {
                        Image(systemName: "number")
                        Text("Quantity")
                        Spacer()
                        Button(action: {
                            if let qty = Int(quantity), qty > 1 {
                                quantity = "\(qty - 1)"
                            }
                        }) {
                            Image(systemName: "minus.circle")
                        }
                        TextField("Quantity", text: $quantity)
                            .keyboardType(.numberPad)
                            .frame(width: 50)
                            .multilineTextAlignment(.center)
                        Button(action: {
                            if let qty = Int(quantity) {
                                quantity = "\(qty + 1)"
                            }
                        }) {
                            Image(systemName: "plus.circle")
                        }
                    }
                    .padding()
                    
                    HStack {
                        Image(systemName: "pencil")
                        Text("Note")
                        Spacer()
                        TextField("Add note", text: $note)
                    }
                    .padding()
                }

                Button(action: {
                    if let selectedWishlistId = selectedWishlistId {
                        let newWish = NewWishModel(
                            userId: FirebaseManager.shared.auth.currentUser?.uid ?? "",
                            wishlistId: viewModel.wishListId,
                            wishName: itemName,
                            wishImageName: image,
                            wishPrice: price,
                            wishLink: link,
                            wishQuantity: quantity,
                            wishDescription: note
                        )

                        print("Saving new wish: \(newWish)")
                        viewModel.saveWish(newWish: newWish) {
                            onSave(selectedWishlistId, newWish)
                        }
                    }
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Make a wish")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationBarTitle("Add Wish", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $shouldShowImagePicker) {
                ImagePicker(image: $image)
            }
        }
    }
}

struct WishView_Previews: PreviewProvider {
    static var previews: some View {
        WishView(
            wishlists: .constant([WishlistItem(id: "sample", title: "Sample", subtitle: "1 List", icon: "gift.fill")]),
            viewModel: WishViewModel(wish: WishModel(
                id: "sampleID",
                userId: "sampleUserID",
                wishlistId: "sampleWishlistID",
                wishName: "Sample Wish",
                wishImageName: "sampleImageName",
                wishPrice: "10.00",
                wishLink: "http://example.com",
                wishQuantity: "1",
                wishDescription: "Sample Description",
                dateCreated: Date()
            ),
            wishListId: "sampleWishlistID"),
            onSave: { _, _ in }
        )
    }
}
