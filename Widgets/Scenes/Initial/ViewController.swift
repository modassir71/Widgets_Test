//
//  ViewController.swift
//  Widgets
//
//  Created by Apple on 15/10/20.
//

import UIKit
import CoreData
import WidgetKit
import StoreKit
import MessageUI
import AppTrackingTransparency

struct CharacterDetail {
    let name: String
    let avatar: String
    let healthLevel: Double
    let heroType: String

    static let availableCharacters = [
        CharacterDetail(name: "Power Panda", avatar: "🐼", healthLevel: 0.14, heroType: "Forest Dweller"),
        CharacterDetail(name: "Unipony", avatar: "🦄", healthLevel: 0.67, heroType: "Free Rangers"),
        CharacterDetail(name: "Spouty", avatar: "🐳", healthLevel: 0.83, heroType: "Deep Sea Goer")
    ]
}

class ViewController: UIViewController {
    private let pullUpControl = SOPullUpControl()
    @IBOutlet weak var templateCollection: TemplateCollectionView!

    @IBOutlet weak var btnFeedBack: UIButton!
    @IBOutlet weak var btnRateUs: UIButton!
    var widgets:[WidgetCollection] = []
    
    
    var attrs = [
        NSAttributedString.Key.font : UIFont.systemFont(ofSize: 19.0),
        NSAttributedString.Key.foregroundColor : UIColor.black,
        NSAttributedString.Key.underlineStyle : 1] as [NSAttributedString.Key : Any]

    var attributedString = NSMutableAttributedString(string:"")
    var attributedString1 = NSMutableAttributedString(string:"")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        
        pullUpControl.dataSource = self
        pullUpControl.setupCard(from: view)
        /*
        if !StoreManager.shared.isPremium {
            let coordinator = OnboardingCoordinator.init(controller: self)
            coordinator.showGoPro(completion: nil)
        }
        */
        btnRateUs.layer.borderWidth = 0
        btnFeedBack.layer.borderWidth = 0
        btnRateUs.layer.cornerRadius = 20
        btnFeedBack.layer.cornerRadius = 20
        btnRateUs.layer.borderColor = UIColor.white.cgColor
        btnFeedBack.layer.borderColor = UIColor.white.cgColor
   
        let buttonTitleStr = NSMutableAttributedString(string:"Rate Us", attributes:attrs)
        attributedString.append(buttonTitleStr)
        btnRateUs.setAttributedTitle(attributedString, for: .normal)
        
        let buttonTitleStr1 = NSMutableAttributedString(string:"Feedback", attributes:attrs)
        attributedString1.append(buttonTitleStr1)
        btnFeedBack.setAttributedTitle(attributedString1, for: .normal)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadWidgets()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PermissionsDataManager.shared.requestNotificationsPermission {
            
        } denied: {}
        passed: {}
        
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization{ status in
                print(status)
            }
        }
    }
    
    func loadWidgets() {
        let context = CoreDataStorage.mainQueueContext()
        let request: NSFetchRequest<WidgetCollection> = WidgetCollection.fetchRequest()
        request.returnsObjectsAsFaults = false
        do {
            self.widgets = try context.fetch(request)
            templateCollection.reloadData()
        } catch {
            
            print("Failed")
        }
    }
    
    func registerCell(){
        templateCollection.register(CalendarTemplateCollectionViewCell.self, forCellWithReuseIdentifier: CalendarTemplateCollectionViewCell.identifier)
    }
    
    @IBAction func settingBtnClicked(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsVC = storyboard.instantiateViewController(withIdentifier: "ManagePurchaseViewController") as! ManagePurchaseViewController
        self.present(settingsVC)
    }
    
    @IBAction func infoBtnClicked(){
        let infoView = self.storyboard?.instantiateViewController(withIdentifier: "HowToViewController") as? HowToViewController
        present(infoView!)
    }
    
    @IBAction func rateBtnClicked(){
        if let scene = UIApplication.shared.currentScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    @IBAction func moreAppsBtnClicked(){
        if let url = URL(string: Constants.moreAppUrl) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func feedbackBtnClicked(){
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([Constants.feedbackEmail])

            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
}

extension ViewController:MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

extension ViewController: UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.widgets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let collectionView  =  collectionView as? TemplateCollectionView else { return UICollectionViewCell() }

        let widget = self.widgets[indexPath.section]
        var cell: TemplateCollectionViewCell!
        
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarTemplateCollectionViewCell.identifier, for: indexPath) as? CalendarTemplateCollectionViewCell

        let template = TemplateWidget(widget: widget)
        cell?.setItem(template, sizeType: "medium", canDelete: indexPath.section != 0)
        cell.deleteBtnAction = { cell in
            let index = collectionView.indexPath(for: cell)?.section
            self.deleteWidget(index!)
        }
        return cell!
    }
    
    func deleteWidget(_ at: Int) {
        let widget = self.widgets[at]
        
        CoreDataStorage.mainQueueContext().delete(widget)
        loadWidgets()
        
        do {
            try CoreDataStorage.mainQueueContext().save()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Failed saving")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let widgetCollection = self.widgets[indexPath.section]
        if let customizeWidgetView = self.storyboard?.instantiateViewController(withIdentifier: "MakeStyleViewController") as? MakeStyleViewController{
            customizeWidgetView.widget = widgetCollection
            self.push(customizeWidgetView)
        }
    }
}

extension ViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.size.width - 50, height: 170)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension ViewController:SOPullUpViewDataSource{
    func pullUpViewCollapsedViewHeight() -> CGFloat {
        return 250.0
    }

    func pullUpViewExpandedViewHeight() -> CGFloat{
        return UIScreen.main.bounds.size.height - 120
    }
    
    func pullUpViewController() -> UIViewController {
        let pullUpController = self.storyboard?.instantiateViewController(withIdentifier: "WidgetTemplatesViewController") as! WidgetTemplatesViewController
        
        pullUpController.templateSelection = { (widgetCollection) in
            self.openEditView(widgetCollection)
            //self.openPreview(widgetCollection)
        }
        pullUpController.pullUpControl = self.pullUpControl
        return pullUpController
    }
    
    func openPreview(_ widget: WidgetCollection)  {
        if let preview = self.storyboard?.instantiateViewController(withIdentifier: "PreviewWidgetViewController") as? PreviewWidgetViewController{
            preview.widget = widget
            present(preview)
            
            preview.editSelection = {
                self.openEditView(widget)
            }
        }
    }
    
    func openEditView(_ widget: WidgetCollection) {
        if let customizeWidgetView = self.storyboard?.instantiateViewController(withIdentifier: "MakeStyleViewController") as? MakeStyleViewController{
            customizeWidgetView.widget = widget
            customizeWidgetView.widgetName = widget.templateId
            self.push(customizeWidgetView)
        }
    }
    static func UIColorFromRGB(_ rgbValue: Int) -> UIColor {
        return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((rgbValue & 0x00FF00) >> 8))/255.0, blue: ((CGFloat)((rgbValue & 0x0000FF)))/255.0, alpha: 1.0)
    }
}
