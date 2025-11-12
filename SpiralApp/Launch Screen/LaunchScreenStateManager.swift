import Foundation
final class LaunchScreenStateManager : ObservableObject {
    
    @MainActor @Published var state : LaunchScreenStep = .firstStep
    
    @MainActor func dismiss(){
        Task {
            state = .secondStep
            try? await Task.sleep(for: Duration.seconds(1))
            self.state = .finished
            
        }
    }
}

//class to pick launch screen state based on drop down of enum 
