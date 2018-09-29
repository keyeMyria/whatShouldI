//
//  OtherViewController.swift
//  What Should I
//
//  Created by Jiang, Tony on 2/14/18.
//  Copyright © 2018 Jiang, Tony. All rights reserved.
//

import UIKit
import Eureka
import MessageUI
import StoreKit
import SwiftyStoreKit

enum RegisteredPurchase: String {
    case bingle = "premiumzz"
}


class OtherViewController: FormViewController, MFMailComposeViewControllerDelegate {
    
    let bundleID = "com.TianProductions"
    var bingle = RegisteredPurchase.bingle

    override func viewDidLoad() {
        super.viewDidLoad()

        form
            +++ Section("Profile Status") { section in
                section.footer = HeaderFooterView(title: defaults.bool(forKey: "premium") ? "Welcome to the club!" : "Support the cause by upgrading to premium for the cutting-edge ad-free experience.")
            }
            <<< ButtonRow("status") {
                $0.title = defaults.bool(forKey: "premium") ? "Privileges: Premium" : "Privileges: Guest"
                $0.onCellSelection( { cell, row in
                    let myAlert = UIAlertController(title: "Options", message: "", preferredStyle: .alert)
                    
                    let yesAction = UIAlertAction(title: "Go Premium", style: .cancel) { _ in
                        self.purchase(purchase: self.bingle)
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
                    }
                    
                    myAlert.addAction(cancelAction)
                    myAlert.addAction(yesAction)
                    
                    if let popoverController = myAlert.popoverPresentationController {
                        popoverController.sourceView = self.view
                    }
                    self.present(myAlert, animated: true, completion: nil)
                    
                })
            }
            <<< ButtonRow("restore") {
                $0.hidden = defaults.bool(forKey: "premium") ? true : false
                $0.title = "Restore my purchase"
                $0.onCellSelection({ cell, row in
                    self.restorePurchases()
                })
            }
            
            +++ Section("Contact Us")
            <<< ButtonRow() {
                $0.title = "Feedback?"
                $0.onCellSelection( { cell, row in
                    if !MFMailComposeViewController.canSendMail() {
                        self.alert(message: "Mail services are not available", title: "")
                        return
                    }
                    else {
                        let composeVC = MFMailComposeViewController()
                        composeVC.mailComposeDelegate = self
                        
                        // Configure the fields of the interface.
                        composeVC.setToRecipients(["Bryan.Maliken@gmail.com"])
                        composeVC.setSubject("Feedback for What Should I?")
                        composeVC.setMessageBody("", isHTML: false)
                        
                        // Present the view controller modally.
                        self.present(composeVC, animated: true, completion: nil)
                    }
                })
            }
            <<< ButtonRow() {
                $0.title = "Concerns?"
                $0.onCellSelection( { cell, row in
                    if !MFMailComposeViewController.canSendMail() {
                        self.alert(message: "Mail services are not available", title: "")
                        return
                    }
                    else {
                        let composeVC = MFMailComposeViewController()
                        composeVC.mailComposeDelegate = self
                        
                        // Configure the fields of the interface.
                        composeVC.setToRecipients(["Bryan.Maliken@gmail.com"])
                        composeVC.setSubject("Concerns for What Should I?")
                        composeVC.setMessageBody("", isHTML: false)
                        
                        // Present the view controller modally.
                        self.present(composeVC, animated: true, completion: nil)
                    }
                })
            }
            <<< ButtonRow() {
                $0.title = "Comments?"
                $0.onCellSelection( { cell, row in
                    if !MFMailComposeViewController.canSendMail() {
                        self.alert(message: "Mail services are not available", title: "")
                        return
                    }
                    else {
                        let composeVC = MFMailComposeViewController()
                        composeVC.mailComposeDelegate = self
                        
                        // Configure the fields of the interface.
                        composeVC.setToRecipients(["Bryan.Maliken@gmail.com"])
                        composeVC.setSubject("Comments for What Should I?")
                        composeVC.setMessageBody("", isHTML: false)
                        
                        // Present the view controller modally.
                        self.present(composeVC, animated: true, completion: nil)
                    }
                })
            }
            <<< ButtonRow() {
                $0.title = "Suggestions?"
                $0.onCellSelection( { cell, row in
                    if !MFMailComposeViewController.canSendMail() {
                        self.alert(message: "Mail services are not available", title: "")
                        return
                    }
                    else {
                        let composeVC = MFMailComposeViewController()
                        composeVC.mailComposeDelegate = self
                        
                        // Configure the fields of the interface.
                        composeVC.setToRecipients(["Bryan.Maliken@gmail.com"])
                        composeVC.setSubject("Suggestions for What Should I?")
                        composeVC.setMessageBody("", isHTML: false)
                        
                        // Present the view controller modally.
                        self.present(composeVC, animated: true, completion: nil)
                    }
                })
            }
            
            +++ Section("Rate Us")
            <<< ButtonRow() {
                $0.title = "A little pleasure goes a long way"
                $0.onCellSelection( { cell, row in
                    self.rateApp(appId: "1342918784") { success in
                        print("RateApp \(success)")
                    }
                })
            }
        
        form +++ Section("Made with support from:")
            <<< ButtonRow() {
                $0.title = "Tian Productions, LLC"
                $0.onCellSelection( { cell, row in
                    let myAlert = UIAlertController(title: "Options", message: "", preferredStyle: .alert)
                    
                    let teamAction = UIAlertAction(title: "The Team", style: .default) { _ in
                        let url = URL(string: "https://s3.amazonaws.com/tianproductions/credits1.jpg")!
                        self.openURL(url: url)
                    }
                    
                    let certificateAction = UIAlertAction(title: "Certificate of Good Standing", style: .default) { _ in
                        let url = URL(string: "https://s3.amazonaws.com/tianproductions/Certificate+of+Good+Standing.jpg")!
                        self.openURL(url: url)
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    myAlert.addAction(teamAction)
                    myAlert.addAction(certificateAction)
                    myAlert.addAction(cancelAction)
                    if let popoverController = myAlert.popoverPresentationController {
                        popoverController.sourceView = self.view
                    }
                    self.present(myAlert, animated: true, completion: nil)
                }).cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "logo")!
                }
            }
            <<< ButtonRow() {
                $0.title = "Excise a Lipoma, Save a Life"
                $0.onCellSelection( { cell, row in
                    let url = URL(string: "https://s3.amazonaws.com/tianproductions/lipoma.png")!
                    self.openURL(url: url)
                }).cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "lipomaLogo")!
                }
            }
            <<< ButtonRow() {
                $0.title = "Disk"
                $0.onCellSelection( { cell, row in
                    let url = URL(string: "https://github.com/saoudrizwan/Disk")!
                    self.openURL(url: url)
                }).cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "diskLogo")!
                }
            }
            <<< ButtonRow() {
                $0.title = "Eureka"
                $0.onCellSelection( { cell, row in
                    let url = URL(string: "https://github.com/xmartlabs/Eureka")!
                    self.openURL(url: url)
                }).cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "eurekaLogo")!
                }
            }
            <<< ButtonRow() {
                $0.title = "IQKeyboardManager"
                $0.onCellSelection( { cell, row in
                    let url = URL(string: "https://github.com/hackiftekhar/IQKeyboardManager")!
                    self.openURL(url: url)
                }).cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "IQkeyboardLogo")!
                }
            }
            <<< ButtonRow() {
                $0.title = "LGButton"
                $0.onCellSelection( { cell, row in
                    let url = URL(string: "https://github.com/loregr/LGButton")!
                    self.openURL(url: url)
                }).cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "githubLogo")!
                }
            }
            <<< ButtonRow() {
                $0.title = "SwiftMessages"
                $0.onCellSelection( { cell, row in
                    let url = URL(string: "https://github.com/SwiftKickMobile/SwiftMessages")!
                    self.openURL(url: url)
                }).cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "swiftMessagesLogo")!
                }
            }
            <<< ButtonRow() {
                $0.title = "SwiftyStoreKit"
                $0.onCellSelection( { cell, row in
                    let url = URL(string: "https://github.com/bizz84/SwiftyStoreKit")!
                    self.openURL(url: url)
                }).cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "swiftyStoreKitLogo")!
                }
        }
        
    }
    
    func openURL(url: URL) {
        if #available(iOS 10.0, *) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        if #available( iOS 10.3,*) {
            SKStoreReviewController.requestReview()
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    func restorePurchases() {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                self.alert(message: "Reason: \(results)" as NSString, title: "Could Not Restore Purchases")
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                defaults.set(true, forKey: "premium")
                self.alert(message: "Welcome back!", title: "Premium Access Restored")
            }
            else {
                print("Nothing to Restore")
                self.alert(message: "", title: "Nothing to Restore")
            }
        }
    }
        
    
}

extension OtherViewController {
    func getInfo(purchase: RegisteredPurchase) {
        SwiftyStoreKit.retrieveProductsInfo([bundleID + "." + purchase.rawValue], completion: { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
            }
            self.showAlert(alert: self.alertForProductRetreivalInfo(result: result))
        })
    }
    
    func purchase(purchase: RegisteredPurchase) {
        print("purch func")
        SwiftyStoreKit.purchaseProduct(bundleID + "." + purchase.rawValue, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("success")
                if purchase.productId == self.bundleID + "." + "premiumzz" {
                    defaults.set(true, forKey: "premium")
                    let myAlert = UIAlertController(title: "Premium access granted!", message: "Welcome to the club!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (ACTION) in
                        
                    }
                    myAlert.addAction(okAction)
                    
                    if let popoverController = myAlert.popoverPresentationController {
                        popoverController.sourceView = self.view
                    }
                    self.present(myAlert, animated: true, completion: nil)
                }
            case .error (let error):
                print(error)
                self.showAlert(alert: self.alertForPurchaseResult(result: result))
                break
            }
        }
        
        SwiftyStoreKit.shouldAddStorePaymentHandler = { payment, product in
            // return true if the content can be delivered by your app
            // return false otherwise
            return false
        }
    }
    
    func verifyPurchase(product: RegisteredPurchase) {
        let appleValidator = AppleReceiptValidator(service: .production)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false, completion: {  result in
            switch result {
            case .success (let receipt):
                self.showAlert(alert: self.alertForVerifyReceipt(result: result))
            case .error (let error):
                self.showAlert(alert: self.alertForVerifyReceipt(result: result))
                if case .noReceiptData = error {
                    self.verifyReceipt()
                    print(error)
                }
            }
        })
    }
    
    func verifyReceipt() {
        let appleValidator = AppleReceiptValidator(service: .production)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false, completion: { result in
            self.showAlert(alert: self.alertForVerifyReceipt(result: result))
            if case .error(let error) = result {
                if case .noReceiptData = error {
                    //self.refreshReceipt()
                    print("no receipt")
                }
            }
        })
    }
    
    func alertWithTitle(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
        }
        return alert
    }
    
    func showAlert(alert: UIAlertController) {
        //if let _ = self.present else {
        self.present(alert, animated: true, completion: nil)
        return
        //}
    }
    
    func alertForProductRetreivalInfo(result: RetrieveResults) -> UIAlertController {
        if let product = result.retrievedProducts.first {
            let priceString = product.localizedPrice!
            return alertWithTitle(title: product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
        }
        else if let invalidProductID = result.invalidProductIDs.first {
            return alertWithTitle(title: "Could not retrieve product info", message: "Invalid product identifier: \(invalidProductID)") //mainly for developer
        }
        else {
            let errorString = result.error?.localizedDescription ?? "Unknown error. Please contact support"
            return alertWithTitle(title: "Could not retrieve product info", message: errorString)
        }
    }
    
    func alertForPurchaseResult(result: PurchaseResult) -> UIAlertController {
        switch result {
        case .success(let product):
            return alertWithTitle(title: "Thank You", message: "Purchase completed")
        case .error(let error):
            switch error.code {
            case .unknown:
                return alertWithTitle(title: "Purchase Error", message: "Unknown error. Please contact support")
            case .clientInvalid:
                return alertWithTitle(title: "Purchase Error", message: "Not allowed to make the payment")
            case .paymentCancelled:
                return alertWithTitle(title: "Payment Cancelled", message: "Payment Cancelled")
            case .paymentInvalid:
                return alertWithTitle(title: "Purchase Error", message: "The purchase identifier was invalid")
            case .paymentNotAllowed:
                return alertWithTitle(title: "Purchase Error", message: "The device is not allowed to make the payment")
            case .storeProductNotAvailable:
                return alertWithTitle(title: "Purchase Error", message: "The product is not available in the current storefront")
            case .cloudServicePermissionDenied:
                return alertWithTitle(title: "Purchase Error", message: "Access to cloud service information is not allowed")
            case .cloudServiceNetworkConnectionFailed:
                return alertWithTitle(title: "Purchase Error", message: "Could not connect to the network")
            default:
                return alertWithTitle(title: "Purchase Error", message: "Unknown error")
            }
        }
    }
    
    func alertForVerifyReceipt(result: VerifyReceiptResult) -> UIAlertController {
        switch result {
        case .success(let receipt):
            return alertWithTitle(title: "Receipt verified", message: "Receipt verified remotely")
        case .error(let error):
            switch error {
            case .noReceiptData:
                return alertWithTitle(title: "Receipt verificadtion", message: "No receipt data found. Application will try to get a new one. Try again")
            default:
                return alertWithTitle(title: "Receipt verificadtion", message: "Receipt verification failed")
            }
            
        }
    }
    
    func alertForVerifySubscription(result: VerifySubscriptionResult) -> UIAlertController {
        switch result {
        case .purchased(let expiryDate):
            return alertWithTitle(title: "Thank you for your purchase!", message: "Product is valid until \(expiryDate)")
        case .notPurchased:
            return alertWithTitle(title: "Please consider!", message: "Product has never been purchased")
        case .expired (let expiryDate):
            return alertWithTitle(title: "Product expired!", message: "Product has been expired since \(expiryDate), please renew your subscription")
        }
        
    }
    
    func alertForVerifyPurchase(result: VerifyPurchaseResult) -> UIAlertController {
        switch result {
        case .purchased:
            return alertWithTitle(title: "Product is purchased!", message: "This product will not expire!")
        case .notPurchased:
            return alertWithTitle(title: "Product is not purchased", message: "")
        }
    }
    
    func alertForRefreshReceipt(result: VerifyReceiptResult) -> UIAlertController {
        switch result {
        case .success(let receiptData):
            print(receiptData)
            return alertWithTitle(title: "Receipt refreshed successfully", message: "")
        case .error (let error):
            print(error)
            return alertWithTitle(title: "Recept refreshed failed", message: "Please contact support and try again")
        }
    }
}
