import UIKit

class ViewController: UIViewController {
    
    private let images = ["barcelona", "dubai", "la", "london", "newYork", "paris", "roma", "tokyo"].compactMap {
        UIImage(named: $0)
    }
    

    private var currentIndex = 0 {
        didSet {
            if currentIndex < 0 {
                currentIndex = images.count - 1
            } else if currentIndex >= images.count {
                currentIndex = 0
            }
        }
    }
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    
    private var initialTouchPoint: CGPoint = .zero
    private var currentScale: CGFloat = 1.0
    private var initialScale: CGFloat = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestureRecognizers()
        updateImage()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7)
        ])
    }
    
    private func setupGestureRecognizers() {

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        imageView.addGestureRecognizer(panGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        imageView.addGestureRecognizer(pinchGesture)
    }
    
    private func updateImage() {
        UIView.transition(with: imageView,
                        duration: 0.3,
                        options: .transitionCrossDissolve,
                        animations: {
                            self.imageView.image = self.images[self.currentIndex]
                            self.imageView.transform = .identity
                            self.currentScale = 1.0
                        },
                        completion: nil)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let touchPoint = gesture.location(in: view)
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .began:
            initialTouchPoint = touchPoint
            
        case .changed:
            imageView.transform = CGAffineTransform(translationX: translation.x, y: 0)
            
        case .ended, .cancelled:
            if abs(translation.x) > 100 {
                if translation.x > 0 {
                    currentIndex -= 1
                } else {
                    currentIndex += 1
                }
                updateImage()
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.imageView.transform = .identity
                }
            }
            
        default:
            break
        }
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3) {
            self.imageView.transform = .identity
            self.currentScale = 1.0
        }
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            initialScale = currentScale
            
        case .changed:
            let newScale = initialScale * gesture.scale
            if newScale >= 1.0 && newScale <= 3.0 {
                currentScale = newScale
                imageView.transform = CGAffineTransform(scaleX: currentScale, y: currentScale)
            }
            
        default:
            break
        }
    }
}
