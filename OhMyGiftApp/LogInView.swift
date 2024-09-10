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
    
    @State private var isPresentingMainView = false // 新增的状态变量
    
    private var profileRepository = ChatUserRepository()
    
    init(didCompleteLoginProcess: @escaping () -> (), testProfile: Bool = false) {
        self.didCompleteLoginProcess = didCompleteLoginProcess
        
        if testProfile {
            FirebaseManager.shared.currentUser = ChatUser(data: ["uid": "dummyUid", "email": "test@example.com", "profileImageUrl": "defaultIcon.jpeg"])
        } else {
            observeAuthChanges()
        }
    }
    
    private func observeAuthChanges() {
        FirebaseManager.shared.auth.addStateDidChangeListener { _, user in
            if let user = user {
                print("User \(user.uid) signed in.")
                self.fetchUserProfile(for: user.uid)
            } else {
                print("User signed out.")
                FirebaseManager.shared.currentUser = nil
            }
        }
    }
    
    private func fetchUserProfile(for uid: String) {
        self.profileRepository.fetchProfile(userId: uid) { profile, error in
            if let error = error {
                print("Error while fetching the user profile: \(error)")
                self.loginStatusMessage = "Error fetching profile: \(error.localizedDescription)"
                return
            }
            
            if let profile = profile {
                FirebaseManager.shared.currentUser = profile
                print("Fetched user profile: \(profile.email)")
                self.isPresentingMainView = true // 登录成功后显示MainView
            } else {
                print("Error: User profile not found.")
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
            
            if let uid = result?.user.uid {
                fetchUserProfile(for: uid) // 获取用户的Profile信息
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
            self.isPresentingMainView = true // 创建账户成功后显示MainView
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            NavigationView {
                ScrollView {
                    Picker(selection: $isLoginMode, label: Text("Picker here")) {
                        Text("Login").tag(true)
                        Text("Create Account").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
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
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(.primary)
                                        .background(Color.white.clipShape(Circle()))
                                        .overlay(Circle().stroke(Color.black, lineWidth: 3))
                                }
                            }
                        }
                    }
                    
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                    }
                   // .padding(.horizontal)
                    .padding(15)
                    
                    Spacer()
                    
                    Button {
                        handleAction()
                    } label: {
                        Text(isLoginMode ? "Log In" : "Create Account")
                            .foregroundColor(.white)
                            .padding()
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 66/255, green: 72/255, blue: 116/255))
                            .cornerRadius(8)
                    }
                    
                    Text(loginStatusMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                .padding()
                .navigationTitle(isLoginMode ? "Log In" : "Create Account")
                .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
                ImagePicker(image: $image)
            }
            .fullScreenCover(isPresented: $isPresentingMainView) {
                AppMainView()
            }
        }
    }

}
