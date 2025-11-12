import SwiftUI

struct EnterUser: View {
    
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.secondary
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    
                    Spacer(minLength: 10)
                    
                    Text("Spiral")
                        .font(.custom("sippinOnSunshine", size: 48))
                        .foregroundStyle(.black)
                    
                    Image("SpiralLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                        .padding(.bottom, 16)
                    
                    VStack(spacing: 16) {
                        NavigationLink(destination: Login()) {
                            Text("Login")
                                .font(.custom("AlegreyaSansSC-Bold", size: 20))
                                .frame(maxWidth: .infinity, minHeight: 52)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        NavigationLink(destination: SignUp()) {
                            Text("Sign Up")
                                .font(.custom("AlegreyaSansSC-Bold", size: 20))
                                .frame(maxWidth: .infinity, minHeight: 52)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding(.horizontal, 32)
                    
                    Text("The Journal")
                        .font(.custom("AlegreyaSansSC-Regular", size: 20))
                        .foregroundStyle(.black)
                        .underline()
                        .padding(.top, 12)
                    
                    Spacer(minLength: 30)
                }
            }
            .navigationBarBackButtonHidden(true)
            .task {
                launchScreenState.dismiss()
            }
        }
    }
}

// MARK: - Reusable Button Style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(Color.primary)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(radius: configuration.isPressed ? 1 : 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    EnterUser()
        .environmentObject(LaunchScreenStateManager())
}
