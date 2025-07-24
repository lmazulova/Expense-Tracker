import SwiftUI

struct ContentView: View {
    @State private var isAnimationCompleted = false

    var body: some View {
        Group {
            if isAnimationCompleted {
                AppTabView()
            } else {
                LottieView(animationName: "launchAnimation") {
                    withAnimation {
                        isAnimationCompleted = true
                    }
                }
                .ignoresSafeArea()
                .background(Color.white)
            }
        }
    }
}
