import UIKit
import SwiftyAttributes
import NSObject_Rx
import RxCocoa
import RxSwift

fileprivate struct C {
  
  static let Copied = NSLocalizedString("COPIED", comment: "COPIED")
}

class MenuPopUpViewController: UIViewController {
  
  var backButtonTap: () -> Void = {}
  
  @IBOutlet weak var menuViewHeight: NSLayoutConstraint!
  @IBOutlet weak var infoViewHeight: NSLayoutConstraint!
  @IBOutlet weak var infoViewBottom: NSLayoutConstraint!
  @IBOutlet weak var copiedLabel: UILabel!
  @IBOutlet weak var exitContainer: UIView!
  
  @IBOutlet weak var shareContainer: UIView!
  @IBOutlet weak var copyLinkContainer: UIView!
  @IBOutlet weak var infoView: UIView!
  @IBOutlet weak var menuView: UIView!
  var presenter: PopUpPresenter?
  
  var isAutorotate: Bool = false
  
  fileprivate var shareUrlString: String!
  
}

// MARK: Life Cycle
extension MenuPopUpViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    copiedLabel.attributedText = C.Copied.withKern(1)
    
    infoViewBottom.constant = -infoViewHeight.constant
    infoView.alpha = 0
    
//    let gesture = UITapGestureRecognizer()
//    view.addGestureRecognizer(gesture)
    
//    _ = gesture.rx.event.asObservable().subscribe { [weak self] _ in
//      self?.dismiss(animated: true, completion: nil)
//    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    containerAnimations()
    shareContainer.alpha = 0
    copyLinkContainer.alpha = 0
    exitContainer.alpha = 0
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    infoView.alpha = 0
  }
  
  override open var shouldAutorotate: Bool {
    return isAutorotate
  }
}

// MARK: Methods
extension MenuPopUpViewController {
  
  @discardableResult
  class func showPopup(on: UIViewController, url: String, isRotate: Bool = false,  backButtonTap: @escaping () -> Void) -> MenuPopUpViewController {
    
    let storybord = UIStoryboard(storyboard: .Navigation)
    let vc: MenuPopUpViewController = storybord.instantiateViewController()
    vc.isAutorotate = isRotate
    on.threeThingersToch.subscribe { [weak on] _ in
      guard let on = on else { return }
      vc.shareUrlString = url
      vc.backButtonTap = backButtonTap
      vc.presenter = PopUpPresenter(controller: vc,
                                    on: on,
                                    showTransition: ShowMenuPopUpTransition(duration: 0.2),
                                    hideTransition: HideMenuPopUpTransition(duration: 0.2))
      }.disposed(by: on.rx.disposeBag)

    return vc
  }
}

// MARK: Animations
extension MenuPopUpViewController {
  
  func containerAnimations() {
    exitContainer.animate(duration: 0.001, delay: 0, [.alpha(to: 1)], timing: .easyOut)
    
    exitContainer.animate(duration: 0.4,
                          delay: 0,
                          [.layerPositionY(from: menuViewHeight.constant + exitContainer.bounds.size.height / 2,
                                           to: menuViewHeight.constant / 2)],
                          timing: .easyOut)
    
    copyLinkContainer.animate(duration: 0.001, delay: 0.08, [.alpha(to: 1)], timing: .easyOut)
    
    copyLinkContainer.animate(duration: 0.4,
                              delay: 0.08,
                              [.layerPositionY(from: menuViewHeight.constant + copyLinkContainer.bounds.size.height / 2,
                                               to: menuViewHeight.constant / 2)],
                              timing: .easyOut)
    
    shareContainer.animate(duration: 0.001, delay: 0.16, [.alpha(to: 1)], timing: .easyOut)
    
    shareContainer.animate(duration: 0.4,
                           delay: 0.16,
                           [.layerPositionY(from: menuViewHeight.constant + shareContainer.bounds.size.height / 2,
                                            to: menuViewHeight.constant / 2)],
                           timing: .easyOut)
    
  }
  
  func showInfoView() {
    if infoView.alpha == 1 { return }
    
    infoView.alpha = 1
    
    let from = Showroom.screen.height - menuViewHeight.constant + infoViewHeight.constant / 2
    let to = Showroom.screen.height - menuViewHeight.constant - infoViewHeight.constant / 2
    
    infoView.animate(duration: 0.2, [.layerPositionY(from: from, to: to)], timing: .easyInEasyOut)
    infoView.animate(duration: 0.2, delay:1, [.layerPositionY(from: to, to: from)], timing: .easyInEasyOut) { [weak self] in
      self?.infoView.alpha = 0
    }
  }
}

// MARK: Actions
extension MenuPopUpViewController {
  
  @IBAction func copyLinkHandler(_ sender: Any) {
    showInfoView()
    AppAnalytics.event(.google(name: "Buttons", parametr: "copy link popup: \(shareUrlString ?? "")"))
    UIPasteboard.general.string = shareUrlString
  }
  
  @IBAction func sharedHandler(_ sender: Any) {
    
    AppAnalytics.event(.google(name: "Buttons", parametr: "shared link popup: \(shareUrlString ?? "")"))
    let activity = UIActivityViewController(activityItems: [shareUrlString ?? ""], applicationActivities: nil)
    present(activity, animated: true, completion: nil)
  }
  
  @IBAction func backHandler(_ sender: Any) {
    AppAnalytics.event(.google(name: "Buttons", parametr: "back button popup"))
    dismiss(animated: true, completion: nil)
    backButtonTap()
  }
}
