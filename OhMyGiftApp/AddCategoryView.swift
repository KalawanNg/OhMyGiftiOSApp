//
//  AddCategoryView.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 18/07/2024.
//

import SwiftUI

struct AddCategoryView: View {
    @State private var categoryName = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Create category")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)

                TextField("e.g. clothes", text: $categoryName)
                    .font(.title2)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                    .padding(.horizontal)

                Text("Selected Wishlists")
                    .font(.headline)
                    .padding(.horizontal)
                
                Text("Add at least one wishlist.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                Text("Your wishlists")
                    .font(.headline)
                    .padding(.horizontal)

                HStack {
                    Image(systemName: "house.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding()
                    
                    VStack(alignment: .leading) {
                        Text("birthday")
                            .font(.title2)
                            .bold()
                    }
                    Spacer()
                    Button(action: {
                        print("Add wishlist tapped")
                    }) {
                        Text("Add")
                            .font(.headline)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    print("Create category tapped")
                }) {
                    Text("Create category")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitle("Add Category", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct AddCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        AddCategoryView()
    }
}
