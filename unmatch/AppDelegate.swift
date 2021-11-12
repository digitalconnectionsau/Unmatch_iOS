//
//  AppDelegate.swift
//  unmatch
//
//  Created by Xiao Long on 2021/7/1.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import SwiftyJSON

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    var accessToken = ""
    var refreshToken = ""

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        let authData = self.getAuthData()
        self.accessToken = authData["accessToken"].stringValue
        self.refreshToken = authData["refreshToken"].stringValue
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        var viewController = storyBoard.instantiateViewController(withIdentifier: "LandingNavVC")
        let firstRun = UserDefaults.standard.bool(forKey: "HasBeenLaunched")
        if !firstRun {
            viewController = storyBoard.instantiateViewController(withIdentifier: "IntroViewController")
        } else {
            if self.accessToken.count > 0 {
                viewController = storyBoard.instantiateViewController(withIdentifier: "TabVCID")
            }
        }
        
        window?.rootViewController = viewController
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "AuthData")
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
    
    func deleteAuthData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AuthEntity")
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try self.persistentContainer.viewContext.execute(DelAllReqVar)
            self.accessToken = ""
            self.refreshToken = ""
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    func setAuthData(accessToken: String, refreshToken: String) {
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AuthEntity")
        
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do { try managedContext.execute(DelAllReqVar) }
        catch { print(error) }
        
        let projectEntity = NSEntityDescription.entity(forEntityName: "AuthEntity", in: managedContext)!
        
        let authData = NSManagedObject(entity: projectEntity, insertInto: managedContext)
        authData.setValue(accessToken, forKeyPath: "accessToken")
        authData.setValue(refreshToken, forKeyPath: "refreshToken")
        
        do {
            try managedContext.save()
            self.accessToken = accessToken
            self.refreshToken = refreshToken
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func getAuthData() -> JSON {
        var result: NSManagedObject? = nil
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AuthEntity")
        var authJSON: JSON = [
            "accessToken": "",
            "refreshToken": ""
        ]
        
        do {
            let data = try managedContext.fetch(fetchRequest)
            if data.count > 0 {
                result = data[0] as? NSManagedObject
                authJSON["accessToken"].string = result?.value(forKey: "accessToken") as? String
                authJSON["refreshToken"].string = result?.value(forKey: "refreshToken") as? String
                return authJSON
            }
        } catch let error as NSError {
            print("Could not retrieve. \(error), \(error.userInfo)")
        }
        return authJSON
    }
}

