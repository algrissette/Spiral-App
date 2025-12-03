import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ForgotPassword: View {
    
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var fetchedEmail: String = ""
    @State private var message: String = ""
    @State private var showingAlert: Bool = false
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager
    
    private let db = Firestore.firestore()
    
    var body: some View {
        ZStack {
            Color.primary
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                
                // Top bar
                HStack {
                    NavigationLink(destination: EnterUser().environmentObject(launchScreenState)) {
                        Image(systemName: "xmark.square.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                VStack(spacing: 6) {
                    Text("Forgot Password")
                        .font(.custom("AlegreyaSansSC-Bold", size: 26))
                        .foregroundColor(.white)
                    
                    Text("Text is case sensitive")
                        .font(.custom("AlegreyaSansSC-Bold", size: 14))
                        .foregroundColor(.black.opacity(0.8))
                }
                
                // MARK: - Password Reset by Email
                VStack(spacing: 14) {
                    
                    TextField("Enter your email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        .frame(height: 50)
                        .foregroundColor(.black)
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 30)
                    
                    Button(action: sendResetLink) {
                        Text("Send Reset Link")
                            .font(.custom("AlegreyaSansSC-Bold", size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 45)
                            .background(Color.blue)
                            .cornerRadius(22)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .shadow(radius: 3)
                            .padding(.horizontal, 50)
                    }
                }
                
                Divider()
                    .background(Color.white)
                    .padding(.horizontal, 40)

                // MARK: - Lookup Email by Username
                VStack(spacing: 14) {
                    Text("Forgot Email")
                        .font(.custom("AlegreyaSansSC-Bold", size: 22))
                        .foregroundColor(.white)
                    
                    TextField("Enter your username", text: $username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        .frame(height: 50)
                        .foregroundColor(.black)
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 30)
                    
                    Button(action: fetchEmail) {
                        Text("Find Email")
                            .font(.custom("AlegreyaSansSC-Bold", size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 45)
                            .background(Color.green)
                            .cornerRadius(22)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .shadow(radius: 3)
                            .padding(.horizontal, 50)
                    }
                    
                    if !fetchedEmail.isEmpty {
                        VStack(spacing: 6) {
                            Text("Your registered email is:")
                                .foregroundColor(.black)
                            
                            Text(fetchedEmail)
                                .bold()
                                .foregroundColor(.black)
                        }
                        .padding(.top, 8)
                    }
                }
                
                Spacer()
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Info"),
                message: Text(message),
                dismissButton: .default(Text("OK"))
            )
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
