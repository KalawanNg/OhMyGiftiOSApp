//
//  ChatLogView.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 20/08/2024.
//

import SwiftUI
import Firebase


struct FirebaseConstants {
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
    static let timestamp = "timestamp"
    static let email = "email"
    static let uid = "uid"
    static let profileImageUrl = "profileImageUrl"
    static let messages = "messages"
    static let users = "users"
    static let recentMessages = "recent_messages"
}

struct ChatMessage: Identifiable {
    
    var id: String { documentId }
    
    let documentId: String
    let fromId, toId, text: String
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
    }
}

class ChatLogViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    
    @Published var chatMessages = [ChatMessage]()
    
    var chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
    var firestoreListener: ListenerRegistration?
    
    func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid
        else { return }
        
        guard let toId = chatUser?.uid else { return }
        firestoreListener?.remove()
        chatMessages.removeAll()
        firestoreListener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
                    }
                })
                
                DispatchQueue.main.async {
                    self.count += 1
                }//怎么运作的呢？
                
            }
    }
    
    func handleSend() {
        print(chatText)
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid
        else { return }
        
        guard let toId = chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = [FirebaseConstants.fromId: fromId, FirebaseConstants.toId: toId, FirebaseConstants.text: self.chatText, FirebaseConstants.timestamp: Timestamp()] as [String : Any]
        
        document.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            print("Successfully saved current user sending message")
            
            self.persistRecentMessage()
            
            self.chatText = ""
            self.count += 1
        }
        
        let recipientMessageDocument = FirebaseManager.shared.firestore
            .collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        recipientMessageDocument.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            print("Recipient saved message as well")
        }
    }
    
    private func persistRecentMessage() {
        guard let chatUser = chatUser else { return }
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = self.chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .document(toId)
        
        let data = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
            FirebaseConstants.email: chatUser.email
        ] as [String : Any]
        
        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message: \(error)"
                print("Failed to save recent message: \(error)")
                return
            }
        }
    }
    
    @Published var count = 0
    
}

struct ChatLogView: View {
    @State private var showWishlistPicker = false // 控制 ActionSheet 的显示
    @State private var selectedWishlistId: String? // 用户选择的 Wish List ID
    @State private var wishlists: [WishListModel] = [] // 存储加载的 Wish Lists
    @ObservedObject var vm: ChatLogViewModel
    
    var body: some View {
        VStack {
            messagesView
            
            chatBottomBar
        }
        .navigationTitle(vm.chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadWishLists() // 在页面加载时，加载当前用户的 Wish Lists
        }
        .onDisappear {
            vm.firestoreListener?.remove()
        }
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            // 用户点击此按钮时，将弹出 Picker 供用户选择 Wish List
            Button {
                showWishlistPicker = true // 显示 Picker
            } label: {
                Image(systemName: "list.bullet")
                    .font(.system(size: 24))
                    .foregroundColor(Color(.darkGray))
            }
            .actionSheet(isPresented: $showWishlistPicker) {
                // 使用 ActionSheet 展示 Picker 供用户选择 Wish List
                ActionSheet(title: Text("Select Wish List"), message: nil, buttons: wishlistPickerButtons())
            }
            
            ZStack {
                DescriptionPlaceholder()
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
           
            Button {
                vm.handleSend() // 发送消息
            } label: {
                Text("Send")
                    .foregroundColor(.white)
                    .bold()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(red: 66/255, green: 72/255, blue: 116/255))
            .cornerRadius(6)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // 加载当前用户的 Wish Lists
    private func loadWishLists() {
        let wishlistsRepository = WishListsRepository()
        wishlistsRepository.fetchUserWishLists { fetchedWishLists, error in
            if let error = error {
                print("Failed to load wish lists: \(error.localizedDescription)")
                return
            }
            if let fetchedWishLists = fetchedWishLists {
                wishlists = fetchedWishLists // 存储加载到的 Wish Lists
            }
        }
    }
    
    // 动态生成 ActionSheet 中的按钮，显示所有可选择的 Wish List
    private func wishlistPickerButtons() -> [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = wishlists.map { wishlist in
            .default(Text(wishlist.wishlistName)) {
                selectedWishlistId = wishlist.wishlistId
                sendWishListItems(wishlistId: wishlist.wishlistId)
            }
        }
        buttons.append(.cancel()) // 添加取消按钮
        return buttons
    }
    
    // 发送选中 Wish List 的 Items 信息
    private func sendWishListItems(wishlistId: String) {
        let wishlistsRepository = WishListsRepository()
        wishlistsRepository.fetchWishListInfo(wishlistId: wishlistId) { wishlist, wishes, error in
            guard let wishes = wishes, error == nil else {
                print("Failed to load wish list items: \(error?.localizedDescription ?? "")")
                return
            }
            
            // 将 Wish Items 转换为文本
            let wishItemsText = wishes.map { wishItem in
                """
                - Name: \(wishItem.wishName)
                  Price: \(wishItem.wishPrice ?? "N/A")
                  Link: \(wishItem.wishLink ?? "N/A")
                """
            }.joined(separator: "\n\n")
            
            // 将 Wish List 的内容作为消息填入 chatText 中
            DispatchQueue.main.async {
                vm.chatText = "Wish List: \(wishlist?.wishlistName ?? wishlistId)\n\n\(wishItemsText)"
            }
        }
    }
    
    // 显示聊天记录的视图
    private var messagesView: some View {
        VStack {
            if #available(iOS 15.0, *) {
                ScrollView {
                    ScrollViewReader { scrollViewProxy in
                        VStack {
                            ForEach(vm.chatMessages) { message in
                                MessageView(message: message)
                                }
                            HStack { Spacer() }.id("Empty")
                            }
                            .onReceive(vm.$count) { _ in
                                withAnimation(.easeOut(duration: 0.5)) {
                                    scrollViewProxy.scrollTo("Empty", anchor: .bottom)
                                }
                            }
                        }
                    }
                    .background(Color(.init(white: 0.95, alpha: 1)))
                }
            }
        }
}

struct MessageView: View {
    let message: ChatMessage
    
    var body: some View {
        VStack {
            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                HStack {
                    Spacer()
                    HStack {
                        Text(message.text)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color(red: 66/255, green: 72/255, blue: 116/255))
                    .cornerRadius(8)
                }
            } else {
                HStack {
                    HStack {
                        Text(message.text)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Description")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
//                NavigationView {
//                   ChatLogView(chatUser: .init(data: ["uid": "36TLospFonXMJcYKrU7r4YPx1OO2", "email": "appuser3@gmail.com"]))
//               }
        MainMessagesView()
    }
}
