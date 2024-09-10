//
//  ProfileView.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 30/08/2024.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore

struct ProfileView: View {
    
    @ObservedObject var vm = MainMessagesViewModel()
    @State var shouldShowLogOutOptions = false
    
    var body: some View {
        ZStack {
            Image("weddingcake")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 400, height: 4000)
                .opacity(0.3)
                .position(CGPoint(x: 200, y: 300))
            
            
            VStack(spacing: 16) {
                WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 130, height: 130)
                    .clipped()
                    .cornerRadius(50)
                    .overlay(RoundedRectangle(cornerRadius: 44)
                        .stroke(Color(.label), lineWidth: 1)
                    )
                    .shadow(radius: 5)
                    .padding()
                
                
                let email = vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? ""
                Text(email)
                    .font(.system(size: 25, weight: .bold))
                    .padding()
                    .background(Color(red: 232/255, green: 238/255, blue: 255/255))
                    .cornerRadius(150)
                    .shadow(radius: 5)
            }
        }
        Button {
            shouldShowLogOutOptions.toggle()
        } label: {
        
                Image(systemName: "gear")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(Color(.label))

        }
    .padding()
    .actionSheet(isPresented: $shouldShowLogOutOptions) { .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
        .destructive(Text("Sign Out"), action: {
            print("handle sign out")
            vm.handleSignOut()
        }),
            .cancel()
        ])
    }
    .background(Color(red: 232/255, green: 238/255, blue: 255/255))
    .cornerRadius(50)
        .padding()
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
            LogInView(didCompleteLoginProcess: {
                vm.fetchCurrentUser()
            })
        }
    }
}

#Preview {
    ProfileView()
}
