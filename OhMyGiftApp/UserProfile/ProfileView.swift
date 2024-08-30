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
        VStack(spacing: 16) {
            
            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 200)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 44)
                    .stroke(Color(.label), lineWidth: 1)
                )
                .shadow(radius: 5)
                .padding()
            
            
            let email = vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? ""
            Text(email)
                .font(.system(size: 34, weight: .bold))
        }
        Button {
            shouldShowLogOutOptions.toggle()
        } label: {
            Image(systemName: "gear")
                .font(.system(size: 24, weight: .bold))
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
