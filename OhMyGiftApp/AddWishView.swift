//
//  AddWishView.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 18/07/2024.
//

import SwiftUI

struct AddWishView: View {
    @State private var itemName = ""
    @State private var price = ""
    @State private var link = ""
    @State private var quantity = 1
    @State private var note = ""
    @State private var isMustHave = false
    @Environment(\.presentationMode) var presentationMode //什么意思
    
    var body: some View {
        NavigationView{
            Form{
                Section(header: Text("Item Information")){
                    TextField("e.g beer dispenser", text: $itemName)//如何理解？
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .padding()
                    
                    HStack{
                        Image(systemName: "gift.fill")
                        Text("Pencil")
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                    
                    HStack{
                        Image(systemName: "photo")
                        Text("Image")
                        Spacer()
                        Button(action: {}){
                            Image(systemName: "plus.circle")
                        }
                    }
                    .padding()
                    HStack{
                        Image(systemName: "tag")
                        Text("Price")
                        Spacer()
                        TextField("Enter price", text: $price)
                            .keyboardType(.decimalPad)
                    }
                    .padding()
                    HStack{
                        Image(systemName: "link")
                        Text("Link")
                        Spacer()
                        TextField("Add link", text: $link)
                            .keyboardType(.URL)
                    }
                    .padding()
                    HStack{
                        Image(systemName: "number")
                        Text("Quantity")
                        Spacer()
                        Button(action: {
                            if quantity > 1 { quantity -= 1}
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
                    HStack{
                        Image(systemName: "pencil")
                        Text("Note")
                        Spacer()
                        TextField("Add note", text: $note)
                    }
                    .padding()
                    Toggle(isOn: $isMustHave){
                        VStack(alignment: .leading){
                            Text("Must-have")
                            Text("The \"must-have\" wishes are the wishes you absolutely want to have. They are marked with a star in the Wishlist.")
                                .font(.caption)
                        }
                    }
                    .padding()
                }
                Button(action: {print ("Wish added")}) {
                    Text("Make a wish") //print是什么意思
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
            .navigationBarItems(trailing: Button("Cancel") {presentationMode.wrappedValue.dismiss()})//如何理解
        }
    }
}

struct AddWishView_Previews: PreviewProvider {
    static var previews: some View {
        AddWishView()
    }
}
