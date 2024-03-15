//
//  HowToViewController.swift
//  Widgets
//
//  Created by Apple on 23/10/20.
//

import UIKit
import IronSource

class HowToViewController: UIViewController {

    
    @IBOutlet weak var viewStep1: UIView!
    @IBOutlet weak var viewStep2: UIView!
    @IBOutlet weak var viewStep3: UIView!
    @IBOutlet weak var viewStep4: UIView!
    @IBOutlet weak var viewStep5: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet var viewBg: UIView!
//MARK: - Property
    var bannerDelegate: BannerAdDelegate! = nil
    var initializationDelegate: InitializationDelegate! = nil
    var bannerView: ISBannerView! = nil
    let appId = "1dd4517e5"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.animate(withDuration: 1, animations: {
            self.stackView.transform = CGAffineTransform(scaleX: 0, y: 0)
        }) { (finished) in
            UIView.animate(withDuration: 1, animations: {
                self.stackView.transform = CGAffineTransform.identity
            })
        }
//        MARK: - IronSource Method called
        setUpIronSource()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        MARK: - Destroy Banner Called
        destroyBanner()
    }
//    MARK: - Setup Iron source
    func setUpIronSource(){
        IronSource.initWithAppKey(appId, delegate: self.initializationDelegate)
        bannerDelegate = .init(delegate: self)
        IronSource.setLevelPlayBannerDelegate(bannerDelegate)
        IronSource.setAdaptersDebug(true)
        self.showBanner()
    }
//    MARK: - Show Banner
    func showBanner(){
        if bannerView != nil {
           destroyBanner()
        }
        let bannerSize: ISBannerSize = ISBannerSize(description:kSizeBanner, width:320, height:50)
        
        IronSource.loadBanner(with: self, size: bannerSize)
    }
//    MARK: - Destroy Banner
    func destroyBanner() {
        DispatchQueue.main.async {
            if self.bannerView != nil {
                IronSource.destroyBanner(self.bannerView)
                self.bannerView = nil
            }
        }
    }

}


extension UIView {
   func roundCornersTop(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
//MARK: - Set Banner View in screen
extension HowToViewController: AdViewControllerDelegate {
    func setAndBindBannerView(_ bannerView: ISBannerView!) {
        DispatchQueue.main.async {
            if (self.bannerView != nil) {
                self.bannerView.removeFromSuperview()
            }
            
            self.bannerView = bannerView
            self.bannerView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(bannerView)
            
            let centerX = self.bannerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
            let bottom = self.bannerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
            let width = self.bannerView.widthAnchor.constraint(equalToConstant: bannerView.frame.size.width)
            let height = self.bannerView.heightAnchor.constraint(equalToConstant: bannerView.frame.size.height)
            NSLayoutConstraint.activate([centerX, bottom, width, height])
        }
    }
}
