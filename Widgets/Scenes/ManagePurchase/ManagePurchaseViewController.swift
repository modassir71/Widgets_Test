//
//  ManagePurchaseViewController.swift
//  FMPhotoPickerExample
//
//  Created by Apple on 14/09/20.
//  Copyright © 2020 Tribal Media House. All rights reserved.
//

import UIKit
import StoreKit
import IronSource

class ManagePurchaseViewController: UIViewController {
    
    
    @IBOutlet weak var viewHeader: UIView!
    
    @IBOutlet weak var btnShareApp: FilledButton!
    
    @IBOutlet weak var btnWriteReview: FilledButton!
    
    @IBOutlet weak var btnPrivacyPolicy: FilledButton!
    
    @IBOutlet weak var btnAboutUs: FilledButton!
//    MARK: - Property
    var bannerDelegate: BannerAdDelegate! = nil
    var initializationDelegate: InitializationDelegate! = nil
    var bannerView: ISBannerView! = nil
    let appId = "1dd4517e5"

    override func viewDidLoad() {
        super.viewDidLoad()
    
        btnAboutUs.dropShadow()
        btnPrivacyPolicy.dropShadow()
        btnWriteReview.dropShadow()
        btnShareApp.dropShadow()
//        MARK: - Ironsource Method Called
        setUpIronSource()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        MARK: - Destroy Method called
        destroyBanner()
    }
//    MARK: - Initialize Ironsource Method
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
        //Banner Size
        let bannerSize: ISBannerSize = ISBannerSize(description:kSizeBanner, width:320, height:50)
        //Load Banner
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

    @IBAction func shareBtnClicked(){
        let items = [Constants.shareAppMessage]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    @IBAction func rateBtnClicked(){
        if let scene = UIApplication.shared.currentScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    @IBAction func policyBtnClicked(){
        if let url = URL(string: Constants.policyURL) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func termsBtnClicked(){
        if let url = URL(string: Constants.termsURL) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func aboutBtnClicked(){
        if let url = URL(string: Constants.aboutURL) {
            UIApplication.shared.open(url)
        }
    }
    
}
//MARK: - Ironsource Delegate method Extension
extension ManagePurchaseViewController: AdViewControllerDelegate{
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
