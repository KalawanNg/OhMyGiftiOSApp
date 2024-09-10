//
//  GiftPickerView.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 03/09/2024.
//

import SwiftUI

struct Gift: Equatable {
    var name: String
    var image: String
    var price: Double
    var carb: Double
    var fat: Double
    var protein: Double
    
    static let examples = [
        Gift(name: "Beauty & Relex", image: "💄💅💉💆", price: 294, carb: 14, fat: 24, protein: 17),
        Gift(name: "Cloth", image: "👗🧥👔👙", price: 89, carb: 20, fat: 0, protein: 1.8),
        Gift(name: "Food & Drink", image: "🎂🍷🍱", price: 266, carb: 33, fat: 10, protein: 11),
        Gift(name: "Eletric Device", image: "💻📱📺", price: 339, carb: 74, fat: 1.1, protein: 12),
        Gift(name: "Daily Good", image: "🪞🌂🍴", price: 191, carb: 19, fat: 8.1, protein: 11.7),
        Gift(name: "Shoes", image: "👠👞", price: 256, carb: 56, fat: 1, protein: 8),
        Gift(name: "Pet", image: "🐶🐱🐦", price: 233, carb: 26.5, fat: 17, protein: 22),
        Gift(name: "Accessory", image: "💍⌚️👓🎩", price: 219, carb: 33, fat: 5, protein: 9),
        Gift(name: "Flower", image: "🌹🌼🌷🪻", price: 80, carb: 4, fat: 4, protein: 6),
        Gift(name: "Sport", image: "⚾️⛷️", price: 80, carb: 4, fat: 4, protein: 6),
        Gift(name: "Music", image: "🎼🎻🎹🎺", price: 80, carb: 4, fat: 4, protein: 6),
        Gift(name: "Game", image: "🎮🎧🎰", price: 80, carb: 4, fat: 4, protein: 6),
        Gift(name: "Stationary", image: "🎨✒️📏📎", price: 80, carb: 4, fat: 4, protein: 6),
        Gift(name: "Realisic & Pratical", image: "💷 💶 💴", price: 80, carb: 4, fat: 4, protein: 6),
    ]
}

struct GiftPickerView: View {
    let food = Gift.examples
    @State private var selectedFood: Gift?
    @State private var showinfo: Bool = false
    
    var body: some View {
        ZStack {
                Image("gift")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 350, height: 550)
                    .opacity(0.22)
                    .position(CGPoint(x: 200, y: 300))
            VStack(spacing: 30) {
                Group {
                    if let selectedFood = selectedFood {
                        Text(selectedFood.image)
                            .font(.system(size: 70))
                            .minimumScaleFactor(0.7)
                    } else {
                        Image("noodles")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                .frame(height: 250)
               // .border(Color(.secondarySystemBackground))
                .padding()
                Spacer()
                
                Text("🩵 Inspire Me 🩵")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(Color(red: 46/255, green: 7/255, blue: 63/255))//224, 33, 138
                
                HStack {
                    if let selectedFood = selectedFood {
                        Text(selectedFood.name)
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(Color(red: 224/255, green: 33/255, blue: 138/255))
                            .id(selectedFood.name)
                            .transition(.identity)
//                        Button {
//                            showinfo.toggle()
//                        } label: {
//                            Image(systemName: "info.circle.fill")
//                                .foregroundColor(.secondary)
//                        }.buttonStyle(.plain)
                    }
                }
        
                
//                if let selectedFood = selectedFood {
//                    Text("Price \(selectedFood.price.formatted()) ")
//                        .font(.title2)
//                    
//                    VStack{
//                        if showinfo {
//                            Grid(horizontalSpacing: 12, verticalSpacing: 12){
//                                GridRow{
//                                    Text("Protein")
//                                    Text("Fat")
//                                    Text("Carb")
//                                }.frame(minWidth: 60)
//                                
//                                Divider()
//                                    .gridCellUnsizedAxes(.horizontal)
//                                    .padding(.horizontal, -10)
//                                
//                                GridRow{
//                                    Text(selectedFood.protein.formatted() + "g")
//                                    Text(selectedFood.fat.formatted() + "g")
//                                    Text(selectedFood.carb.formatted() + "g")
//                                }
//                            }
//                            .font(.title3)
//                            .padding(.horizontal)
//                            .padding()
//                            .background(RoundedRectangle(cornerRadius: 8).foregroundStyle(.background))
//                            .transition(.move(edge: .top).combined(with: .opacity))
//                        }
//                    }
//                    .frame(maxWidth: .infinity)
//                    .clipped()
//                }
                
                Spacer()
                
                Button(role: .none) {
                    selectedFood = food.shuffled().filter { $0 != selectedFood }.first
                } label: {
                    Text(selectedFood == nil ? "Let's Decide 🙋" : "Other Option Please 🙇").frame(width: 300)
                        .animation(.none, value: selectedFood)
                }
                .font(.title2)
                .bold()
                .padding(.bottom, -15)
                .buttonStyle(BorderedProminentButtonStyle())
                .tint(Color(red: 66/255, green: 72/255, blue: 116/255))//rgb(46, 7, 63)
                
                Button(role: .none) {
                    selectedFood = nil
                    showinfo = false
                } label: {
                    Text("Reset 👀")
                        .frame(width: 200)
                               .foregroundColor(Color(red: 12/255, green: 24/255, blue: 68/255))
                }
                .font(.title2)
                .bold()
                .buttonStyle(BorderedButtonStyle())
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
           // .background(Color(.secondarySystemBackground))
            .font(.title)
            .buttonStyle(BorderedProminentButtonStyle())
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .animation(.spring(dampingFraction: 0.6), value: showinfo)
        .animation(.easeInOut(duration: 0.6), value: selectedFood)
        }
        }
    }

#Preview {
    GiftPickerView()
}

