import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let animationName: String
    let loopMode: LottieLoopMode = .playOnce
    var onCompletion: (() -> Void)? = nil

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: animationName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode

        animationView.play { finished in
            if finished {
                onCompletion?()
            }
        }

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
