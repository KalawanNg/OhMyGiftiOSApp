//
//  MainMessagesView.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 12/08/2024.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore

struct RecentMessage: Identifiable {
    var id: String { documentId }
//    @DocumentID var id: String?
    
    let documentId: String
    let text, email: String
    let fromId, toId: String
    let profileImageUrl: String
    let timestamp: Timestamp
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.text = data["text"] as? String ?? ""
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    }
    
    var username: String {
        email.components(separatedBy: "@").first ?? email
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp.dateValue(), relativeTo: Date())
    }
}

class MainMessagesViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var shouldNavigateToChatLogView = false
    
    @Published var selectedUser: ChatUser? {
            didSet {
                if selectedUser != nil {
                    shouldNavigateToChatLogView = true
                }
            }
        }
    
    init() {
        
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()
        
        fetchRecentMessages()
    }
    
    @Published var recentMessages = [RecentMessage]()
    
    private var firestoreListener: ListenerRegistration?
    
     func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
         firestoreListener?.remove()
         self.recentMessages.removeAll()
         
//        FirebaseManager.shared.firestore
//             .collection(FirebaseConstants.recentMessages)
//             .document(uid)
//             .collection(FirebaseConstants.messages)
//             .order(by: FirebaseConstants.timestamp)//按时间顺讯排列对话框
//            .addSnapshotListener { querySnapshot, error in
//                if let error = error {
//                    self.errorMessage = "Failed to listen for recent messages: \(error)"
//                    print(error)
//                    return
//                }
                
         firestoreListener = FirebaseManager.shared.firestore
                     .collection("recent_messages")
                     .document(uid)
                     .collection("messages")
                     .order(by: "timestamp")//按时间顺讯排列对话框
                    .addSnapshotListener { querySnapshot, error in
                        if let error = error {
                            self.errorMessage = "Failed to listen for recent messages: \(error)"
                            print(error)
                            return
                        }
                
                querySnapshot?.documentChanges.forEach({ change in
                        let docId = change.document.documentID
                    
                    if let index = self.recentMessages.firstIndex(where: { rm in
                        return rm.id == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    } //每次更新消息，会自动把消息显示更新到最新的那一个
                    
                    self.recentMessages.insert(.init(documentId: docId, data: change.document.data()), at: 0)
                    
                        //新消息置顶

                })
            }
    }
    
    func fetchCurrentUser() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }
            
        
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found "
                return
            }
            
            self.chatUser = .init(data: data)
        }
    }
    
    @Published var isUserCurrentlyLoggedOut = false
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
        
    }
    
    // DateFormatter 用于格式化时间戳为日期字符串
        private var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium // 设置日期格式，可以根据需要更改
            formatter.timeStyle = .short
            return formatter
        }()
        
        func formattedDate(for timestamp: Timestamp) -> String {
            let date = timestamp.dateValue()
            return dateFormatter.string(from: date)
        }
    
    }
    

struct MainMessagesView: View {
    
    @State var shouldShowLogOutOptions = false
    
    @State var shouldNavigateToChatLogView = false
    
    private var chatLogViewModel = ChatLogViewModel(chatUser: nil)
    
    @ObservedObject private var vm = MainMessagesViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("tree")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 350, height: 350)
                    .opacity(0.18)
                    .position(CGPoint(x: 200, y: 350))
            VStack {
                
                customNavBar
                messagesView
                
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    ChatLogView(vm: chatLogViewModel)
                }
            }
        }
            .overlay(
               newMessageButton, alignment: .bottom
               
            )
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private var customNavBar: some View {
        HStack(spacing: 16) {
            
            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 44)
                    .stroke(Color(.label), lineWidth: 1)
                )
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 4) {
                let email = vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? ""
                Text(email)
                    .font(.system(size: 24, weight: .bold))
                
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
            }
            
            Spacer()
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
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
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
            LogInView(didCompleteLoginProcess: {
                self.vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser()
                self.vm.fetchRecentMessages()
            })
        }
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(vm.recentMessages) { recentMessage in
                VStack {
                    Button{
                        let uid = FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId
                        self.chatUser = .init(data: [FirebaseConstants.email: recentMessage.email, FirebaseConstants.profileImageUrl: recentMessage.profileImageUrl, FirebaseConstants.uid: uid])
                        self.chatLogViewModel.chatUser = self.chatUser
                        self.chatLogViewModel.fetchMessages()
                        self.shouldNavigateToChatLogView.toggle()
                    }label: {
                        HStack(spacing: 16) {
                            WebImage(url: URL(string: recentMessage.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 54, height: 54)
                                .clipped()
                                .cornerRadius(64)
                                .overlay(RoundedRectangle(cornerRadius: 64)
                                    .stroke(Color.black, lineWidth: 2))
                                .shadow(radius: 5)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(recentMessage.username)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(.label))
                                Text(recentMessage.text)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.darkGray))
                                    .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                            }
                            Spacer()
                            
                            Text(recentMessage.timeAgo)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(.label))
                        }
                    }

                    Divider()
                        .padding(.vertical, 8)
                }.padding(.horizontal)
            }.padding(.bottom, 50)
        }
    }
    
    @State var shouldShowNewMessageScreen = false
    
    private var newMessageButton: some View {
        Button{
            shouldShowNewMessageScreen.toggle()
        } label: {
            HStack{
                Spacer()
                Text("+ New Message")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
//            .background(Color.blue)
            .background(Color(red: 66/255, green: 72/255, blue: 116/255))
            .cornerRadius(32)
            .padding(.horizontal)
            .shadow(radius: 15)
        }
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            CreateNewMessageView(didSelectNewUser: {
                user in
                print(user.email)
                //self.vm.selectedUser = user
                self.shouldNavigateToChatLogView.toggle()
                self.chatUser = user
                self.chatLogViewModel.chatUser = user
                self.chatLogViewModel.fetchMessages()
            })
        }
    }
    @State var chatUser: ChatUser?
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
//        MainMessagesView()
//            .preferredColorScheme(.dark)
        
        MainMessagesView()
    }
}
