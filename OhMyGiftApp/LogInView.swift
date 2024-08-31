//
//  LogInView.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 07/08/2024.
//

import SwiftUI

struct LogInView: View {
    
    let didCompleteLoginProcess: () -> ()
    
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    
    @State var shouldShowImagePicker = false
    @State var loginStatusMessage = ""
    @State var image: UIImage?
    
    private var profileRepository = ChatUserRepository()
    
    init(didCompleteLoginProcess: @escaping () -> (), testProfile: Bool = false) {
        self.didCompleteLoginProcess = didCompleteLoginProcess
        
        // 为测试环境添加一个测试用的Profile
        if testProfile {
            // 在测试模式下，设置一个虚拟的ChatUser，避免Firebase的依赖
            FirebaseManager.shared.currentUser = ChatUser(data: ["uid": "dummyUid", "email": "test@example.com", "profileImageUrl": "defaultIcon.jpeg"])
        } else {
            // 正常的初始化过程
            observeAuthChanges()
        }
    }
    
    private func observeAuthChanges() {
        FirebaseManager.shared.auth.addStateDidChangeListener { _, user in
            // 如果用户已登录
            if let user = user {
                print("User \(user.uid) signed in.")
                
                // 从 Firebase Firestore 中获取用户的 Profile 信息
                self.profileRepository.fetchProfile(userId: user.uid) { profile, error in
                    if let error = error {
                        print("Error while fetching the user profile: \(error)")
                        self.loginStatusMessage = "Error fetching profile: \(error.localizedDescription)"
                        return
                    }
                    
                    if let profile = profile {
                        // 更新 FirebaseManager 中的 currentUser
                        FirebaseManager.shared.currentUser = profile
                        print("Fetched user profile: \(profile.email)")
                        self.didCompleteLoginProcess()  // 登录成功后通知父视图
                    } else {
                        print("Error: User profile not found.")
                    }
                }
            } else {
                // 如果用户已登出
                print("User signed out.")
                FirebaseManager.shared.currentUser = nil
            }
        }
    }
    
    private func handleAction() {
        if isLoginMode {
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to login user:", err)
                self.loginStatusMessage = "Failed to login user: \(err)"
                return
            }
            print("Successfully logged in as user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
            
            // 获取用户的Profile信息
            if let uid = result?.user.uid {
                self.profileRepository.fetchProfile(userId: uid) { profile, error in
                    if let error = error {
                        print("Error while fetching the user profile: \(error)")
                        self.loginStatusMessage = "Error fetching profile: \(error.localizedDescription)"
                        return
                    }
                    
                    if let profile = profile {
                        FirebaseManager.shared.currentUser = profile
                        self.didCompleteLoginProcess()  // 通知父视图登录流程完成
                    }
                }
            }
        }
    }
    
    private func createNewAccount() {
        if self.image == nil {
            self.loginStatusMessage = "You must select an avatar image"
            return
        }
        
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to create user:", err)
                self.loginStatusMessage = "Failed to create user: \(err)"
                return
            }
            print("Successfully created user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            self.persistImageToStorage()
        }
    }
    
    private func persistImageToStorage() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                self.loginStatusMessage = "Failed to push image to Storage: \(err)"
                return
            }
            ref.downloadURL { url, err in
                if let err = err {
                    self.loginStatusMessage = "Failed to retrieve downloadURL: \(err)"
                    return
                }
                guard let url = url else { return }
                self.storeUserInformation(imageProfileUrl: url)
            }
        }
    }
    
    private func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let chatUser = ChatUser(data: ["uid": uid, "email": email, "profileImageUrl": imageProfileUrl.absoluteString])
        profileRepository.createOrUpdateProfile(chatUser: chatUser) { chatUser, error in
            if let error = error {
                print("Failed to save user profile: \(error)")
                self.loginStatusMessage = "Failed to save user profile: \(error.localizedDescription)"
                return
            }
            FirebaseManager.shared.currentUser = chatUser
            self.loginStatusMessage = "Successfully saved user profile"
            self.didCompleteLoginProcess()  // 通知父视图登录流程完成
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            NavigationView {
                ScrollView {
                    Picker(selection: $isLoginMode, label: Text("Picker here")) {
                        Text("Login").tag(true)
                        Text("Create Account").tag(false)
                    }.pickerStyle(SegmentedPickerStyle()).padding()
                    
                    if !isLoginMode {
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: {
                            VStack {
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 138, height: 138)
                                        .cornerRadius(64)
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(Color(.label))
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64)
                                .stroke(Color.black, lineWidth: 3))
                        }
                    }
                    
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $password)
                    }
                    .padding()
                    .background(Color.white)
                    
                    Button {
                        handleAction()
                    } label: {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundStyle(Color.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }.background(Color.blue)
                    }
                    
                    Text(self.loginStatusMessage).foregroundStyle(Color.red)
                }
                .padding()
                .navigationTitle(isLoginMode ? "Log In" : "Create Account")
                .background(Color(UIColor(white: 0, alpha: 0.05)).ignoresSafeArea())
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
                ImagePicker(image: $image)
            }
        }
    }
}


#Preview {
    LogInView(didCompleteLoginProcess: {}, testProfile: true)
}


