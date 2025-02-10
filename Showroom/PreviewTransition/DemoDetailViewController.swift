import UIKit
import PreviewTransition

public class DemoDetailViewController: PTDetailViewController {
  
  @IBOutlet weak var controlHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var controlBottomConstrant: NSLayoutConstraint!
  
  // bottom control icons
  @IBOutlet weak var controlView: UIView!
  @IBOutlet weak var plusImageView: UIImageView!
  @IBOutlet weak var controlTextLabel: UILabel!
  @IBOutlet weak var controlTextLableLending: NSLayoutConstraint!
  @IBOutlet weak var shareImageView: UIImageView!
  @IBOutlet weak var hertIconView: UIImageView!
  
  var backButton: UIButton?
  
  
  var bottomSafeArea: CGFloat {
    var result: CGFloat = 0
    if #available(iOS 11.0, *) {
      result = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    }
    return result
  }
}

// MARK: life cicle

extension DemoDetailViewController {
  
  override public func viewWillAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as? UIView{
      statusBar.isHidden = false
    }
  }
  
  override public func viewWillDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
    statusBar.isHidden = true
  }
  
  override open var shouldAutorotate: Bool {
    return false
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    _ = MenuPopUpViewController.showPopup(on: self, url: "https://github.com/Ramotion/preview-transition") { [weak self] in
      self?.navigationController?.dismiss(animated: true, completion: nil)
      self?.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    backButton = createBackButton()
    let _ = createNavigationBarBackItem(button: backButton)
    
    // animations
    showBackButtonDuration(duration: 0.3)
    showControlViewDuration(duration: 0.3)
    
    let _ = createBlurView()
  }
}

// MARK: helpers

extension DemoDetailViewController {
  
  fileprivate func createBackButton() -> UIButton {
    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 44))
    button.setImage(UIImage(named: "back"), for: .normal)
    button.addTarget(self, action: #selector(DemoDetailViewController.backButtonHandler) , for: .touchUpInside)
    return button
  }
  
  fileprivate func createNavigationBarBackItem(button: UIButton?) -> UIBarButtonItem? {
    guard let button = button else {
      return nil
    }
    
    let buttonItem = UIBarButtonItem(customView: button)
    navigationItem.leftBarButtonItem = buttonItem
    return buttonItem
  }
  
  fileprivate func createBlurView() -> UIView {
    let height = controlView.bounds.height + bottomSafeArea
    let imageFrame = CGRect(x: 0, y: view.frame.size.height - height, width: view.frame.width, height: height)
    let image = view.makeScreenShotFromFrame(frame: imageFrame)
    let screnShotImageView = UIImageView(image: image)
    screnShotImageView.translatesAutoresizingMaskIntoConstraints = false
    screnShotImageView.blurViewValue(value: 5)
    controlView.insertSubview(screnShotImageView, at: 0)
    
    // added constraints
    [NSLayoutConstraint.Attribute.left, .right, .bottom, .top].forEach { attribute in
      (self.controlView, screnShotImageView) >>>- {
        $0.attribute = attribute
        return
      }
    }

    createMaskView(onView: screnShotImageView)

    return screnShotImageView
  }
  
  fileprivate func createMaskView(onView: UIView) {
    let blueView = UIView(frame: CGRect.zero)
    blueView.backgroundColor = .black
    blueView.translatesAutoresizingMaskIntoConstraints = false
    blueView.alpha = 0.4
    onView.addSubview(blueView)
    
    // add constraints
    [NSLayoutConstraint.Attribute.left, .right, .bottom, .top].forEach { attribute in
      (onView, blueView) >>>- {
        $0.attribute = attribute
        return
      }
    }
  }
}

// MARK: animations

extension DemoDetailViewController {
  
  fileprivate func showBackButtonDuration(duration: Double) {
    backButton?.rotateDuration(duration: duration, from: -CGFloat.pi / 4, to: 0)
    backButton?.scaleDuration(duration: duration, from: 0.5, to: 1)
    backButton?.opacityDuration(duration: duration, from: 0, to: 1)
  }
  
  fileprivate func showControlViewDuration(duration: Double) {
    moveUpControllerDuration(duration: duration)
    showControlButtonsDuration(duration: duration)
    showControlLabelDuration(duration: duration)
  }
  
  fileprivate func moveUpControllerDuration(duration: Double) {
    controlBottomConstrant.constant = -controlHeightConstraint.constant - bottomSafeArea
    
    view.layoutIfNeeded()
    
    controlBottomConstrant.constant = -bottomSafeArea
    UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { 
      self.view.layoutIfNeeded()
    }, completion: nil)
  }
  
  fileprivate func showControlButtonsDuration(duration: Double) {
    [plusImageView, shareImageView, hertIconView].forEach {
      $0?.rotateDuration(duration: duration, from: -CGFloat.pi / 4, to: 0, delay: duration)
      $0?.scaleDuration(duration: duration, from: 0.5, to: 1, delay: duration)
      $0?.alpha = 0
      $0?.opacityDuration(duration: duration, from: 0, to: 1, delay: duration, remove: false)
    }
  }
  
  fileprivate func showControlLabelDuration(duration: Double) {
    controlTextLabel.alpha = 0
    controlTextLabel.opacityDuration(duration: duration, from: 0, to: 1, delay: duration, remove: false)
    
    // move rigth
    let offSet: CGFloat = 20
    controlTextLableLending.constant -= offSet
    view.layoutIfNeeded()
    
    controlTextLableLending.constant += offSet
    UIView.animate(withDuration: duration * 2, delay: 0, options: .curveEaseOut, animations: {
      self.view.layoutIfNeeded()
    }, completion: nil)
  }
}

// MARK: actions

extension DemoDetailViewController {
  
  @objc func backButtonHandler() {
    popViewController()
  }
}
