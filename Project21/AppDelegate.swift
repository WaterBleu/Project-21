//
//  AppDelegate.swift
//  Project21
//
//  Created by Jeff Huang on 2015-08-10.
//  Copyright (c) 2015 Jeff Huang. All rights reserved.
//

import UIKit
import XLForm
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window:UIWindow?
    var currentHabit:HabitObject?
    var mainVC:MainViewController!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: nil))
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        Parse.enableLocalDatastore()
        Parse.setApplicationId("Eo8aQ6uWpTwco5uCYidMHXRkPkb3XgPkyJGYBZA9", clientKey: "ACvquY5B8P2V3Dw7LrjsxHlNGL9B37UuSwgJZlMi")
        
        
        let query = HabitObject.query()
        query!.fromPinWithName("Habit")
        query!.getFirstObjectInBackgroundWithBlock { (habit: PFObject?, error: NSError?) -> Void in
            self.currentHabit = habit as? HabitObject
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc:UIViewController
            if(self.currentHabit == nil){
                vc = storyboard.instantiateViewControllerWithIdentifier("NewHabitViewController") as! UIViewController
            }
            else{
                vc = storyboard.instantiateViewControllerWithIdentifier("MainViewController") as! UIViewController
                self.mainVC = vc as! MainViewController
            }
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }
        
        XLFormViewController.cellClassesForRowDescriptorTypes()[XLFormRowDescriptorTypeWeekDays] = "XLFormWeekDaysCell"
        
        let completeAction = UIMutableUserNotificationAction()
        completeAction.identifier = "Complete_Habit" // the unique identifier for this action
        completeAction.title = "Complete" // title for the action button
        completeAction.activationMode = .Background // UIUserNotificationActivationMode.Background - don't bring app to foreground
        completeAction.authenticationRequired = false // don't require unlocking before performing action
        completeAction.destructive = true // display action in red
        
        let HabitCategory = UIMutableUserNotificationCategory() // notification categories allow us to create groups of actions that we can associate with a notification
        HabitCategory.identifier = "Habit_Occurrence_Category"
        HabitCategory.setActions([completeAction], forContext: .Default)
        // UIUserNotificationActionContext.Default (4 actions max)
        HabitCategory.setActions([completeAction], forContext: .Minimal)
        // UIUserNotificationActionContext.Minimal - for when space is limited (2 actions max)
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: [HabitCategory]))
        // we're now providing a set containing our category as an argument
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        switch (identifier!) {
        case "Complete_Habit":
            mainVC.updateProgress()
        default: // switch statements must be exhaustive - this condition should never be met
            println("Error: unexpected notification action identifier!")
        }
        completionHandler() // per developer documentation, app will terminate if we fail to call this
    }
}

