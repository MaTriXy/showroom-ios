import UIKit

class CircleView: UIView {

  // MARK: Inits
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = .white
    layer.shouldRasterize = true
    
    layer.shadowOpacity = 1
    layer.shadowColor = UIColor.white.cgColor
    layer.shadowOffset = CGSize(width: -40, height: 30);
    layer.shadowRadius = 20
  }
//  enableBlurWithAngle
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: Methods
extension CircleView {
  
  class func build(on view: UIView, position: CGPoint) -> CircleView {
    let width = position.x
    let height = UIScreen.main.bounds.size.height - position.y
    let diagonal = sqrt(width * width + height * height) * 2
    let circleView = CircleView(frame: CGRect(x: 0, y: 0, width: diagonal, height: diagonal))
    circleView.layer.cornerRadius = diagonal / 2
    circleView.center = position
//    view.addSubview(circleView)
//    view.sendSubview(toBack: circleView)
    view.layer.mask = circleView.layer
    
    return circleView
  }
}

// MARK: Animations
extension CircleView {
  
  func show(completion: @escaping () -> Void = {}) {
    alpha = 0
    animate(duration: 0.1, [.alpha(to: 1)])
    animate(duration: 0.4, [.viewScale(from: 0, to: 1)], timing: .easyInEasyOut, completion: completion)
  }
  
  func hide(completion: @escaping () -> Void) {
    animate(duration: 0.4, [.viewScale(from: 1, to: 0)], timing: .easyInEasyOut, completion: completion)
  }
}
