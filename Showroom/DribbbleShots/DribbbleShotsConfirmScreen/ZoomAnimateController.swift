import UIKit

final class ZoomAnimateController: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum Direction { case presenting, dismissing }
    
    private let originFrame: CGRect
    private let direction: Direction
    
    init(originFrame: CGRect, direction: Direction) {
        self.originFrame = originFrame
        self.direction = direction
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to)
            else { return }
        
        switch direction {
            case .presenting: animatePresentation(from: fromVC, to: toVC, using: transitionContext)
            case .dismissing: animateDismissal(from: fromVC, to: toVC, using: transitionContext)
        }
    }
    
    private func animatePresentation(from sourceVC: UIViewController, to destinationVC: UIViewController, using transitionContext: UIViewControllerContextTransitioning) {
        guard let snapshot = destinationVC.view.snapshotView(afterScreenUpdates: true) else { return }
        let finalFrame = transitionContext.finalFrame(for: destinationVC)
        
        snapshot.frame = originFrame
        transitionContext.containerView.addSubview(destinationVC.view)
        transitionContext.containerView.addSubview(snapshot)
        destinationVC.view.isHidden = true
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: [.curveEaseInOut, .layoutSubviews],
            animations: { snapshot.frame = finalFrame },
            completion: { _ in
                destinationVC.view.isHidden = false
                snapshot.removeFromSuperview()
                sourceVC.view.layer.transform = CATransform3DIdentity
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    private func animateDismissal(from sourceVC: UIViewController, to destinationVC: UIViewController, using transitionContext: UIViewControllerContextTransitioning) {
        guard let snapshot = sourceVC.view.snapshotView(afterScreenUpdates: false) else { return }
        
        transitionContext.containerView.insertSubview(destinationVC.view, at: 0)
        transitionContext.containerView.addSubview(snapshot)
        sourceVC.view.isHidden = true
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: [.curveEaseIn, .layoutSubviews],
            animations: { [weak self] in snapshot.frame = self?.originFrame ?? .zero },
            completion: { _ in
                sourceVC.view.isHidden = false
                snapshot.removeFromSuperview()
                if transitionContext.transitionWasCancelled { destinationVC.view.removeFromSuperview() }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

