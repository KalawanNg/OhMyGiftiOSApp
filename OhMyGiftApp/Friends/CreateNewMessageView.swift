//
//  CreateNewMessageIView.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 18/08/2024.
//

import SwiftUI
import SDWebImageSwiftUI

class CreateNewMessageViewModel: ObservableObject {
    
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    
    init() {
        fetchAllUsers()
    }
    
    private func fetchAllUsers() {
        FirebaseManager.shared.firestore.collection("users").getDocuments { documentsSnapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch users: \(error)"
                print("Failed to fetch users: \(error)")
                return
            }
            
            documentsSnapshot?.documents.forEach({ snapshot in
                snapshot.data()
                let data = snapshot.data() 
                let user = ChatUser(data: data)
                if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                    self.users.append(.init(data: data))
                }
            })
            
            //self.errorMessage = "Fetched users successfully"
        }
    }
}

struct CreateNewMessageView: View {
    
    let didSelectNewUser: (ChatUser) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var vm = CreateNewMessageViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("flower")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 380, height: 380)
                    .opacity(0.25)
                    .position(CGPoint(x: 200, y: 300))
                ScrollView {
                    Text(vm.errorMessage)
                    
                    ForEach (vm.users) {user in
                        Button {
                            presentationMode.wrappedValue.dismiss()
                            didSelectNewUser(user)
                        } label: {
                            HStack(spacing: 16) {
                                WebImage(url: URL(string: user.profileImageUrl))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipped()
                                    .cornerRadius(50)
                                    .overlay(RoundedRectangle(cornerRadius: 50)
                                    .stroke(Color(.label), lineWidth: 2))
                                Text(user.email)
                                    .foregroundColor(Color(.label))
                                Spacer()
                            }.padding(.horizontal)
                        }
                        Divider()
                            .padding(.vertical, 8)
                    }
                }.navigationTitle("New Message")
                    .toolbar{
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text("Cancel")
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    //CreateNewMessageView()
    MainMessagesView()
}
