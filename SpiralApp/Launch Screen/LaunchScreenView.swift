import SwiftUI

struct LaunchScreenView : View {
    
    @EnvironmentObject private var launchScreenState : LaunchScreenStateManager
    //enviornment object to show launch screen over entire app
    
    
    @State private var firstAnimation = false
    @State private var secondAnimation = false
    @State private var startFadeOutAnimation = false
    
    
    
    
    
    @ViewBuilder //building a view of the main image
    private var image : some View {
        Image("SpiralLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .rotationEffect(firstAnimation ? Angle (degrees: 900) : Angle (degrees: 1800))
            .animation(.easeInOut(duration: 1), value:  Angle (degrees: 1800))

            .scaleEffect(secondAnimation ? 0 : 1)
            .offset(y: secondAnimation ? 400 : 0)
    }
    
    @ViewBuilder
    private var backgroundColor : some View {
        Color.blue.ignoresSafeArea()
    }
    
    private let animationTimer = Timer //sparks animation  ever .5 seconds
        .publish(every : 0.5, on: .current, in: .common)
        .autoconnect()
    
    var body: some View {
        ZStack{
            backgroundColor
            image
            
        }
        .onReceive(animationTimer){ timerValue in
            updateAnimation()
        }
        .opacity(startFadeOutAnimation ? 0 : 1 )
        
    }
    
    private func updateAnimation() {
        switch launchScreenState.state{
        case .firstStep:
            withAnimation(.easeInOut(duration: 0.9)){
                firstAnimation.toggle()
            }
        case .secondStep :
            if secondAnimation == false{
                withAnimation(.linear){
                    self.secondAnimation = true
                    startFadeOutAnimation = true
                }
                
            }
        case .finished :
            break
        }
    }
    
    
    
    
    
}

/*summary :
 We make an enum that we use as a drop down menu
 We turn make a state manager that just switches from enum values
 */

//Launch animation starts automatically but timer is used to give some time inbetween we start the second animation phase 

