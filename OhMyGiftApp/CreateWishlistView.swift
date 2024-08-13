import SwiftUI

struct CreateWishlistView: View {
    @State private var wishlistName: String = ""
    @State private var note: String = ""
    @State private var selectedVisibility = "Friends"
    @State private var showReservations = false
    @State private var shareWith = ""
    @Environment(\.presentationMode) var presentationMode
    
    let visibilityOptions = ["Public", "Friends", "Private"]
    
    var onSave: (WishlistItem) -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Wishlist Icon and Name Input
                    VStack(spacing: 10) {
                        Image(systemName: "house.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        
                        TextField("e.g. Christmas", text: $wishlistName)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        HStack {
                            Spacer()
                            Text("\(wishlistName.count)/20")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Note Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Note")
                            .font(.headline)
                        TextField("Add note", text: $note)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    // Visibility Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Visibility")
                            .font(.headline)
                        HStack {
                            ForEach(visibilityOptions, id: \.self) { option in
                                Button(action: {
                                    selectedVisibility = option
                                }) {
                                    HStack {
                                        Circle()
                                            .fill(selectedVisibility == option ? Color.blue : Color.gray)
                                            .frame(width: 20, height: 20)
                                        Text(option)
                                            .font(.body)
                                            .foregroundColor(selectedVisibility == option ? .blue : .black)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Reservations Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Reservations")
                            .font(.headline)
                        Toggle("Would you like to see when someone has reserved a wish of yours?", isOn: $showReservations)
                            .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                    }
                    .padding(.horizontal)
                    
                    // Share With Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Share with")
                            .font(.headline)
                        HStack {
                            Button(action: {
                                // Add person action
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add person")
                                }
                                .foregroundColor(.blue)
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    
                    // Create List Button
                    Button(action: {
                        let newItem = WishlistItem(
                            title: wishlistName.isEmpty ? "New Wishlist" : wishlistName,
                            subtitle: note,
                            icon: "house.fill" // Here you can choose a different icon if needed
                        )
                        onSave(newItem)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Create list")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .padding(.top)
            }
            .navigationBarTitle("Create Wishlist", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct CreateWishlistView_Previews: PreviewProvider {
    static var previews: some View {
        CreateWishlistView { newItem in }
    }
}
