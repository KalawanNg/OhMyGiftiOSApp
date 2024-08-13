//
//  LogInView.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 07/08/2024.
//

import SwiftUI

struct LogInView: View {
    
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    
    @State var shouldShowImagePicker = false
    
    var body: some View {
        VStack (spacing: 12) {
            NavigationView{
                ScrollView{
                    Picker(selection: $isLoginMode, label: Text("Picker here")) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                        .padding()
                    
                    if !isLoginMode{
                        Button{
                            shouldShowImagePicker.toggle()
                        } label: {
                            
                            VStack{
                                
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
                                .stroke(Color.black,lineWidth:3)
                            )
                        }
                    }
                    
                    Group{
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
            
                        SecureField("Password", text: $password)
                    }
                    .padding()
                    .background(Color.white)
                    
                    Button{
                        handleAction()
                    } label: {
                        HStack{
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                                //.bold()
                                .foregroundStyle(Color.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }.background(Color.blue)
                    }
                    
                    Text(self.loginStatusMessage)
                        .foregroundStyle(Color.red)
                }
                .padding()
                .navigationTitle(isLoginMode ? "Log In" : "Create Account ")
                .background(Color(UIColor(white: 0, alpha: 0.05))
                    .ignoresSafeArea())
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
                ImagePicker(image: $image)
            }
        }
    }
    
    @State var image: UIImage?
    
    private func handleAction(){
        if isLoginMode{
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password){
            result, err in
            if let err = err {
                print("Failed to login user:", err)
                self.loginStatusMessage = "Failed to login user: \(err)"
                return
            }
            print("Successfully logged in as user: \(result?.user.uid ?? "")")
            
            self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
        }
    }
    
    @State var loginStatusMessage = ""
    
    private func createNewAccount() {
        FirebaseManager.shared.auth.createUser(withEmail:email, password: password){
            result, err in
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
                //let filename = UUID().uuidString
                guard let uid = FirebaseManager.shared.auth.currentUser?.uid
                else { return }
                let ref = FirebaseManager.shared.storage.reference(withPath: uid)
                guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
                ref.putData(imageData, metadata: nil) { metadata, err in
                    if let err = err {
                        self.loginStatusMessage = "Failed to push image to Storage: \(err)"
                        return
                    }
                    
                    ref.downloadURL{
                        url, err in
                        if let err = err {
                            self.loginStatusMessage = "Failed to retrieve downloadURL: \(err)"
                            return
                        }
                        
                        self.loginStatusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                        print(url?.absoluteString)
                        
                        guard let url = url else { return }
                        self.storeUserInformation(imageProfileUrl: url)
                    }
                }
            }
    
    private func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = ["email": self.email, "uid": uid, "profileImageUrl": imageProfileUrl.absoluteString]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) {
                err in
                if let err = err {
                    print(err)
                    self.loginStatusMessage = "\(err)"
                    return
                }
                print("Success")
            }
    }
}

#Preview {
    LogInView()
}
