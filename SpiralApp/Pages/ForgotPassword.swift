//
//  ForgotPassword.swift
//  SpiralApp
//
//  Created by Alan Grissette on 11/3/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ForgotPassword: View {
    
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var fetchedEmail: String = ""
    @State private var message: String = ""
    @State private var showingAlert: Bool = false
    
    private let db = Firestore.firestore()
    
    var body: some View {
        ZStack {
            Color.primary
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
            Text("Text is case sensitive")
                .font(.custom("AlegreyaSansSC-Bold", size: 15))
                .foregroundColor(.black)
            
                Text("Forgot Password")
                    .font(.custom("AlegreyaSansSC-Bold", size: 20))
                    .foregroundColor(.white)
                
                // MARK: - Password Reset by Email
                VStack(spacing: 10) {
                    TextField("Enter your email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        .frame(width: 250, height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                    
                    Button(action: sendResetLink) {
                        Text("Send Reset Link")
                            .font(.custom("AlegreyaSansSC-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 40)
                            .background(Color.blue)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 3)
                            )
                            .shadow(color: .gray, radius: 3)
                    }
                }
                
                Divider()
                    .padding(.vertical, 1)
                    .background(Color.white)
                
                
                // MARK: - Lookup Email by Username
                VStack(spacing: 10) {
                    Text("Forgot Email")
                        .font(.custom("AlegreyaSansSC-Bold", size: 20))
                        .foregroundColor(.white)
                    
                    TextField("Enter your username", text: $username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        .frame(width: 250, height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                    
                    Button(action: fetchEmail) {
                        Text("Find Email")
                            .font(.custom("AlegreyaSansSC-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 40)
                            .background(Color.green)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 3)
                            )
                            .shadow(color: .gray, radius: 3)
                    }
                    
                    if !fetchedEmail.isEmpty {
                        Text("Your registered email is:")
                            .foregroundColor(.white)
                        Text(fetchedEmail)
                            .bold()
                            .foregroundColor(.white)
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Info"),
                      message: Text(message),
                      dismissButton: .default(Text("OK")))
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Send Firebase Password Reset Link
    private func sendResetLink() {
        guard !email.isEmpty else {
            message = "Please enter your email address."
            showingAlert = true
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                message = "Failed to send reset link: \(error.localizedDescription)"
            } else {
                message = "A password reset link has been sent to \(email)."
            }
            showingAlert = true
        }
    }
    
    // MARK: - Fetch Email by Username from Firestore
    private func fetchEmail() {
        guard !username.isEmpty else {
            message = "Please enter your username."
            fetchedEmail = ""
            showingAlert = true
            return
        }
        
        db.collection("users")
            .whereField("userName", isEqualTo: username)
            .getDocuments { snapshot, error in
                if let error = error {
                    message = "Error fetching user: \(error.localizedDescription)"
                    fetchedEmail = ""
                    showingAlert = true
                    return
                }
                
                guard let doc = snapshot?.documents.first,
                      let emailFound = doc.get("email") as? String else {
                    message = "No user found with that username."
                    fetchedEmail = ""
                    showingAlert = true
                    return
                }
                
                fetchedEmail = emailFound
                message = ""
            }
    }
}

#Preview {
    ForgotPassword()
}


