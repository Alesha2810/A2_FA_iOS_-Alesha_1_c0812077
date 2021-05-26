//
//  AppDelegate.swift
//  A2_FA_iOS_ Alesha_c0812077
//
//  Created by Alesha on 24/05/21.
//  Copyright © 2021 XYZ. All rights reserved.
//

import UIKit
import CoreData
let appDelegate = UIApplication.shared.delegate as! AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let obj = ProductListViewController()
        let objSuperNavigation = UINavigationController(rootViewController: obj)
        
        // create the side controller
        let objMenu = SideMenuViewController()

        var sideController : JASidePanelController?
        sideController = JASidePanelController()
        sideController?.shouldDelegateAutorotateToVisiblePanel = false
        sideController?.allowLeftSwipe = false
        sideController?.centerPanel = objSuperNavigation
        sideController?.leftPanel = objMenu
        
        appDelegate.window?.rootViewController = sideController
        
       // print("Database URL: - \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)")
        
        return true
    }
    

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "A2_FA_iOS__Alesha_c0812077")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK:- Global Function
    
    func setShadow(_ view: UIView) {
        view.layer.masksToBounds = false
        view.layer.shadowRadius = 3.0
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        view.layer.shadowOpacity = 0.5
    }
    
    func setBottomBorder(textfield:UITextField) {
        textfield.borderStyle = .none
        textfield.layer.backgroundColor = UIColor.white.cgColor
        textfield.layer.masksToBounds = false
        textfield.layer.shadowColor = UIColor.lightGray.cgColor
        textfield.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        textfield.layer.shadowOpacity = 1.0
        textfield.layer.shadowRadius = 0.0
    }
    
    func topMostController()->UIViewController? {
        
        var topController = window?.rootViewController
        
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        
        return topController
    }
    
    func CRGB(r red:CGFloat, g:CGFloat, b:CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }

    func CRGBA(r red:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }

}

