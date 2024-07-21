//
//  WishListsView.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 18/07/2024.
//

import SwiftUI

struct WishlistItem: Identifiable {
    var id = UUID()
    var title: String
    var subtitle: String
    var icon: String
}

struct WishListsView: View {
    @State private var showingOptions = false
        @State private var showingAddWishView = false
        @State private var showingAddCategoryView = false
    
    let wishlistItems = [
            WishlistItem(title: "General", subtitle: "1 List", icon: "gift.fill"),
            WishlistItem(title: "birthday", subtitle: "open wishes 3\ntotal £21.99", icon: "house.fill")
        ]
    
    var body: some View {
        NavigationView{
            VStack{
                HStack{
                    Text("Wishlists")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                    HStack(spacing: 20){
                        Image(systemName: "arrow.up.arrow.down")
                        Image(systemName: "line.horizontal.3")
                    }
                }
                .padding()
                
                ScrollView{
                    LazyVStack(spacing: 20){
                        ForEach(wishlistItems) { item in
                            WishListCardView(title: item.title, subtitle: item.subtitle, icon: item.icon)
                        }
                    }
                    .padding()
                }
                Spacer()
                
                ZStack{
                    if showingOptions {
                        VStack(spacing: 20){
                            Button(action: {
                                showingAddCategoryView = true
                            }) {
                                HStack {
                                    Image(systemName: "folder.fill")
                                    Text("Create category")
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                            }
                            Button(action: {
                                showingAddWishView = true
                            }) {
                                HStack {
                                    Image(systemName: "star.fill")
                                    Text("Add wish")
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                            }
                            Button(action: { print("Create Wishlist tapped")
                            }) {
                                HStack {
                                    Image(systemName: "list.bullet")
                                    Text("Create Wishlist")
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                            }
                        }
                        .transition(.move(edge: .bottom))//什么意思
                        .animation(.easeInOut, value: showingOptions)
                    }
                    
                    Button(action: {withAnimation {
                        showingOptions.toggle()//什么意思
                    }}){
                        Image(systemName: showingOptions ? "xmark" : "plus.circle.fill")
                            .font(.largeTitle)
                            .padding()
                            .background(Color.white)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            .shadow(radius: 5)
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddWishView) {
                AddWishView()//如何理解
            }
            .sheet(isPresented: $showingAddCategoryView) {
                AddCategoryView()
            }
        }
    }
}

#Preview {
    WishListsView()
}
