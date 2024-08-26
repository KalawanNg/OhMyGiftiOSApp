import SwiftUI

struct AddWishView: View {
    @State private var itemName = ""
    @State private var price = ""
    @State private var link = ""
    @State private var quantity = 1
    @State private var note = ""
    @State private var isMustHave = false
    @State private var selectedWishlistID: UUID?

    @Environment(\.presentationMode) var presentationMode
    @Binding var wishlists: [WishlistItem]
    //@Binding var wishlist: WishlistItem
    
    var onSave: (UUID, Wish) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Information")) {
                    TextField("e.g beer dispenser", text: $itemName)
                        .font(.title)
                        .padding()
                    
                    Picker("Select Wishlist", selection: $selectedWishlistID) {
                        ForEach(wishlists) { wishlist in
                            Text(wishlist.title).tag(wishlist.id as UUID?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onAppear {
                        if selectedWishlistID == nil, let firstWishlist = wishlists.first {
                            selectedWishlistID = firstWishlist.id
                        }
                    }

                    HStack {
                        Image(systemName: "photo")
                        Text("Image")
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "plus.circle")
                        }
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
                            if quantity > 1 { quantity -= 1 }
                        }) {
                            Image(systemName: "minus.circle")
                        }
                        Text("\(quantity)")
                        Button(action: {
                            quantity += 1
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
                    
                    Toggle(isOn: $isMustHave) {
                        VStack(alignment: .leading) {
                            Text("Must-have")
                            Text("The \"must-have\" wishes are the wishes you absolutely want to have. They are marked with a star in the Wishlist.")
                                .font(.caption)
                        }
                    }
                    .padding()
                }

                Button(action: {
                    if let selectedWishlistID = selectedWishlistID {
                        let newWish = Wish(name: itemName, price: price, link: link, quantity: quantity, note: note, isMustHave: isMustHave)
                        print("Saving new wish: \(newWish)")
                        onSave(selectedWishlistID, newWish)
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
        }
    }
}

struct AddWishView_Previews: PreviewProvider {
    static var previews: some View {
        AddWishView(wishlists: .constant([WishlistItem(title: "Sample", subtitle: "1 List", icon: "gift.fill")]), onSave: { _, _ in })
    }
}
