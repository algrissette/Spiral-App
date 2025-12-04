import SwiftUI

struct Login: View {
    @State private var userText: String = ""
    @State private var userPassword: String = ""
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager
    @EnvironmentObject var checkAuth: AuthModel
    @State private var loginError: String = ""

    // 🌀 Loading state
    @State private var isLoading: Bool = false
    @State private var rotationAngle: Double = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.secondary
                    .ignoresSafeArea()

                VStack(spacing: 50) {
                    // Top bar
                    HStack {
                        NavigationLink(destination: EnterUser()
                            .environmentObject(launchScreenState)) {
                            Image(systemName: "x.square")
                                .foregroundColor(.black)
                                .font(.system(size: 30))
                        }
                        Spacer()
                    }

                    Text("Login")
                        .font(.custom("sippinOnSunshine", size: 40))
                        .foregroundStyle(.black)

                    // Username/email field
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Enter Username or Email")
                            .font(.custom("AlegreyaSansSC-regular", size: 20))
                            .foregroundStyle(.black)
                        TextField("", text: $userText)
                            .font(.custom("AlegreyaSansSC-regular", size: 16))
                            .foregroundStyle(.black)
                            .padding()
                            .frame(width: 300)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    }
                    .padding(.top, 50)

                    // Password field
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Enter Password")
                            .font(.custom("AlegreyaSansSC-regular", size: 20))
                            .foregroundStyle(.black)
                        SecureField("", text: $userPassword)
                            .font(.custom("AlegreyaSansSC-regular", size: 16))
                            .foregroundStyle(.black)

                            .padding()
                            .frame(width: 300)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    }

                    // Forgot password link
                    NavigationLink(destination: ForgotPassword()) {
                        Text("Forgot Password or Email")
                    }
                    .font(.custom("AlegreyaSansSC-regular", size: 16))
                    .foregroundColor(.black)
                    .underline()

                    // Login button
                    Button(action: {
                        guard !userText.isEmpty, !userPassword.isEmpty else {
                            loginError = "Please enter both username/email and password."
                            return
                        }

                        Task {
                            isLoading = true
                            loginError = ""

                            // Start spinning
                            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                rotationAngle = 360
                            }

                            do {
                                try await checkAuth.signIn(
                                    identifier: userText,
                                    password: userPassword
                                )
                            } catch {
                                if let authError = error as? AuthModel.AuthError{
                                    
                                    switch authError {
                                    case .usernameNotFound:
                                        loginError = "Username doesn't exist"
                                        
                                    case .incorrectPassword:
                                        loginError = "Password is incorrect"
                                        
                                    }
                                } else {
                                        loginError = "Try again later. Server is down"
                                        print( "Firebase error: \(error.localizedDescription)")
                                    }
                                }
                            
                            

                            // Stop loading after login attempt
                            isLoading = false
                            rotationAngle = 0
                        }

                    }) {
                        Text("Login!")
                            .font(.custom("AlegreyaSansSC-Bold", size: 20))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 40)
                            .background(Color.primary)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 3)
                            )
                            .padding()
                            .shadow(color: .gray , radius: 3)

                    }
                    .disabled(isLoading)

                    // Error message
                    if !loginError.isEmpty {
                        Text(loginError)
                            .foregroundColor(.red)
                            .font(.custom("AlegreyaSansSC-regular", size: 14))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding(100)

                // 🌀 Spinning logo overlay when loading
                if isLoading {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    Image("SpiralLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(rotationAngle))
                        .onAppear {
                            rotationAngle = 0
                            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                rotationAngle = 360
                            }
                        }
                        .onDisappear {
                            rotationAngle = 0
                        }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

// MARK: - SIGN UP VIEW

struct SignUp: View {
    @State private var isChecked: Bool = false
    @State private var signUpError: String = ""
    @EnvironmentObject var checkAuth: AuthModel

    @State private var first: String = ""
    @State private var last: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var repeatEmail: String = ""
    @State private var password: String = ""
    @State private var repeatPassword: String = ""

    // 🌀 Loading state
    @State private var isLoading: Bool = false
    @State private var rotationAngle: Double = 0

    var body: some View {
        ZStack {
            Color.secondary
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        NavigationLink(destination: EnterUser()
                            .environmentObject(LaunchScreenStateManager())) {
                            Image(systemName: "x.square")
                                .foregroundColor(.black)
                                .font(.system(size: 30))
                                .padding()
                        }
                        Spacer()
                    }
                    .padding()

                    HStack {
                        Text("First Time?")
                            .font(.custom("sippinOnSunshine", size: 40))
                            .foregroundStyle(.black)

                        Spacer()
                    }
                    .padding(.horizontal, 50)

                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            ZStack {
                                Rectangle()
                                    .fill(.clear)
                                    .border(.black, width: 4)
                                    .frame(width: 350, height: 600)
                                    .cornerRadius(10)
                                    .padding(.horizontal, 25)

                                VStack(alignment: .center, spacing: 0) {
                                    HStack(spacing: 0) {
                                        inputBox(placeholder: "First", text: $first)
                                        inputBox(placeholder: "Last", text: $last)
                                    }
                                    inputBox(placeholder: "Username", text: $username)
                                    inputBox(placeholder: "Email", text: $email)
                                    inputBox(placeholder: "ReEnter Email", text: $repeatEmail)
                                    inputBox(placeholder: "Password", text: $password, isSecure: true)
                                    inputBox(placeholder: "ReEnter Password", text: $repeatPassword, isSecure: true)
                                }
                                .frame(width: 350)
                            }
                            .padding(.bottom, 10)
                        }

                        // Error message
                        Text("\(signUpError)")
                            .foregroundStyle(.red)
                            .font(.custom("AlegreyaSansSC-regular", size: 16))
                            .frame(maxWidth: .infinity)
                            .padding()

                        Toggle(isOn: $isChecked) {
                            Text("Click here to Agree to Terms and Conditions")
                                .font(.custom("AlegreyaSansSC-regular", size: 16))
                                .foregroundColor(.black)
                                .padding()
                        }
                        .toggleStyle(.button)

                        // Sign Up button
                        Button(action: {
                            Task {
                                guard isChecked else {
                                    signUpError = "Please agree to Terms and Conditions."
                                    return
                                }

                                isLoading = true
                                signUpError = ""

                                // Start spinning
                                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                    rotationAngle = 360
                                }

                                let (isValid, error) = await Validator.validSignUp(
                                    fullName: "\(first) \(last)",
                                    userName: username,
                                    emailOne: email,
                                    emailTwo: repeatEmail,
                                    passwordOne: password,
                                    passwordTwo: repeatPassword,
                                    checkAuth: checkAuth
                                )

                                guard isValid else {
                                    signUpError = error
                                    isLoading = false
                                    rotationAngle = 0
                                    return
                                }

                                do {
                                    try await checkAuth.createAccount(
                                        email: email,
                                        password: password,
                                        name: "\(first) \(last)",
                                        username: username
                                    )
                                    isLoading = false
                                    rotationAngle = 0
                                } catch {
                                    signUpError = "Firebase error: \(error.localizedDescription)"
                                }

                                isLoading = false
                                rotationAngle = 0
                            }
                        }) {
                            Text("Sign Up!")
                                .font(.custom("AlegreyaSansSC-Bold", size: 20))
                                .foregroundColor(.white)
                                .frame(width: 200, height: 40)
                                .background(Color.primary)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white, lineWidth: 3)
                                )
                                .padding()
                                .shadow(color: .gray , radius: 3)

                        }
                        .disabled(isLoading)
                    }
                }
            }

            // 🌀 Spinning Spiral logo overlay
            if isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                Image("SpiralLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(rotationAngle))
                    .onAppear {
                        rotationAngle = 0
                        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                            rotationAngle = 360
                        }
                    }
                    .onDisappear {
                        rotationAngle = 0
                    }
            }
        }
    }

    // MARK: - Input Box
    @ViewBuilder
    private func inputBox(
        placeholder: String,
        text: Binding<String>,
        width: CGFloat? = nil,
        isSecure: Bool = false
    ) -> some View {
        ZStack(alignment: .leading) {
            if text.wrappedValue.isEmpty {
                Text(placeholder)
                    .padding(.leading, 30)
                    .font(.custom("AlegreyaSansSC-regular", size: 16))
                    .tracking(3)
                    .foregroundColor(.gray) // placeholder color
            }
            
            if isSecure {
                SecureField("", text: text)
                    .padding(.leading, 30)
                    .font(.custom("AlegreyaSansSC-regular", size: 25))
                    .tracking(3)
                    .foregroundStyle(.black)
                    .frame(width: width ?? .infinity, height: 100, alignment: .trailing)
                    .border(Color.black, width: 2)
                    .shadow(color: .gray , radius: 3)
            } else {
                TextField("", text: text)
                    .padding(.leading, 30)
                    .font(.custom("AlegreyaSansSC-regular", size: 25))
                    .tracking(3)
                    .foregroundStyle(.black)
                    .frame(width: width ?? .infinity, height: 100, alignment: .trailing)
                    .border(Color.black, width: 2)
                    .shadow(color: .gray , radius: 3)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

}

#Preview {
    SignUp()
        .environmentObject(AuthModel())
        .environmentObject(LaunchScreenStateManager())
}
