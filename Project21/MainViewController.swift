//
//  MainViewController.swift
//  Project21
//
//  Created by Jeff Huang on 2015-08-11.
//  Copyright (c) 2015 Jeff Huang. All rights reserved.
//

import UIKit
import KDCircularProgress
import SCLAlertView
import Darwin

class MainViewController: UIViewController {
    var buttonView: UIView!
    var progressView: KDCircularProgress!
    var progressButton: UIButton!
    var iconView:UIImageView!

    @IBOutlet weak var labelDay: UILabel!
    @IBOutlet weak var labelHour: UILabel!
    @IBOutlet weak var labelMinute: UILabel!
    @IBOutlet weak var labelSecond: UILabel!
    @IBOutlet weak var minuteTitle: UILabel!
    
    @IBOutlet weak var currentStreak: UILabel!
    var currentProgress:Double!
    var isUpdateAvailable:Bool!
    var isReminded:Bool!
    var buttonTimer:NSTimer!
    var kCountDown:Int = 900
    var kCountDownReminder:Int = 600
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var actionButton: ActionButton!
    
    var DEBUG = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if(self.DEBUG){
            appDelegate.currentHabit!.progress = 3
        }
        
        isReminded = false
        isUpdateAvailable = false
        
        currentProgress = Double(appDelegate.currentHabit!.progress)/Double(appDelegate.currentHabit!.occurrences.count)
        
        if(currentProgress != nil){
            setupView()
            checkButton()
            buttonTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("timerFired:"), userInfo: nil, repeats: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupView(){
        setupCountdown()
        setupProgress()
        setupMenuButton()
    }
    
    private func setupCountdown(){
        let rotate = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        let translate = CGAffineTransformMakeTranslation((minuteTitle.bounds.height/2) - (minuteTitle.bounds.width/2) , ((minuteTitle.bounds.width/2) - (minuteTitle.bounds.height/2)))
        minuteTitle.transform = CGAffineTransformConcat(rotate, translate)
    }
    
    func updateCountdown(dhms:(Int, Int, Int, Int)){
        if(labelDay.text == String(dhms.0)) { labelDay.textColor = UIColor.whiteColor() }
        else { labelDay.textColor = UIColor(red:0.84, green:0.40, blue:0.53, alpha:1.0) }
        if(labelHour.text == String(dhms.1)) { labelHour.textColor = UIColor.whiteColor() }
        else { labelHour.textColor = UIColor(red:0.84, green:0.40, blue:0.53, alpha:1.0) }
        if(labelMinute.text == String(dhms.2)) { labelMinute.textColor = UIColor.whiteColor() }
        else { labelMinute.textColor = UIColor(red:0.84, green:0.40, blue:0.53, alpha:1.0) }
        if(labelSecond.text == String(dhms.3)) { labelSecond.textColor = UIColor.whiteColor() }
        else { labelSecond.textColor = UIColor(red:0.84, green:0.40, blue:0.53, alpha:1.0) }
        labelDay.text = String(dhms.0)
        labelHour.text = String(dhms.1)
        labelMinute.text = String(dhms.2)
        labelSecond.text = String(dhms.3)
    }
    
    private func setupProgress(){
        setupButton()
        setupProgressCircle()
        updateStreak()
    }
    
    private func setupProgressCircle(){
        progressView = KDCircularProgress(frame: CGRect(x: 0,y: 0,width: view.frame.size.width/2, height: view.frame.size.width/2))
        progressView.startAngle = -90
        progressView.angle = Int(round(360 * currentProgress))
        progressView.progressThickness = 0.2
        progressView.trackThickness = 0.3
        progressView.trackColor = UIColor(red:0.31, green:0.40, blue:0.76, alpha:1.0)
        progressView.clockwise = true
        progressView.gradientRotateSpeed = 2
        progressView.roundedCorners = false
        progressView.glowMode = .Forward
        progressView.glowAmount = 0.9
        progressView.setColors(UIColor(red:0.30, green:0.66, blue:0.40, alpha:1.0))
        progressView.center = CGPoint(x: view.center.x, y: view.center.y)
        view.addSubview(progressView)
    }

    private func setupButton(){
        progressButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        progressButton.frame = CGRect(x: 0,y: 0,width: view.frame.size.width/2.5, height: view.frame.size.width/2.5)
        progressButton.center = CGPoint(x: view.center.x, y: view.center.y)
        progressButton.addTarget(self, action: "updateProgress", forControlEvents: .TouchUpInside)
        progressButton.backgroundColor = UIColor(red:0.27, green:0.52, blue:0.95, alpha:1.0)
        progressButton.layer.cornerRadius = progressButton.frame.width/2
        
        iconView = UIImageView(image: UIImage(named: "checkmark"))
        iconView.frame.origin.x = progressButton.frame.width/2 - iconView.frame.width/2
        iconView.frame.origin.y = progressButton.frame.height/2 - iconView.frame.height/2
        iconView.backgroundColor = UIColor.lightGrayColor()
        view.addSubview(progressButton)
        progressButton.addSubview(iconView)
    }
    
    private func setupMenuButton(){
        let deleteImage = UIImage(named: "delete")!
        
        let deleteButton = ActionButtonItem(title: "Delete", image: deleteImage)
        deleteButton.action = { item in
            let restartAlertView = SCLAlertView()
            restartAlertView.addButton("Yes", action: { () -> Void in
                self.deleteHabit()
            })
            restartAlertView.showError("Delete?", subTitle: "Are you sure you want to delete the current habit?", closeButtonTitle: "No")
        }
        
        
        actionButton = ActionButton(attachedToView: self.view, items: [deleteButton])
        actionButton.action = { button in button.toggleMenu() }
    }
    
    private func updateStreak(){
        let streak = (currentProgress == 1 ? 21 : Int(floor(appDelegate.currentHabit!.progress.doubleValue/appDelegate.currentHabit!.numPerDay.doubleValue)))
        currentStreak.text = "\(streak)"
    }
    
    
    func timerFired(sender: AnyObject) {
        checkButton()
    }
    
    func checkButton() -> (Int, Int, Int){
        let nextDueTime = appDelegate.currentHabit!.occurrences[Int(appDelegate.currentHabit!.progress)]
        let elapsedTime = NSDate().timeIntervalSinceDate(nextDueTime)
        let (h, m, s) = secondsToHoursMinutesSeconds(Int(-elapsedTime))
        updateCountdown(secondsToDaysHoursMinutesSeconds(Int(-elapsedTime)))
        if(elapsedTime >= 0){
            isUpdateAvailable = true
            iconView.backgroundColor = UIColor(red:0.30, green:0.66, blue:0.40, alpha:1.0)
            if(Int(elapsedTime) >= kCountDownReminder){
                if(Int(elapsedTime) >= kCountDown){
                    if(buttonTimer != nil){ buttonTimer.invalidate() }
                    let restartAlertView = SCLAlertView()
                    restartAlertView.showCloseButton = false
                    restartAlertView.addButton("Ok", action: { () -> Void in
                        self.deleteHabit()
                    })
                    restartAlertView.showError("Failed", subTitle: "You've fail to keep the habit..\n now starting a new habit")
                }
                if(!isReminded){
                    isReminded = !isReminded
                    var reminderNotification = UILocalNotification()
                    reminderNotification.alertBody = "You have 5 mins till breaking you streak! Don't you want \"\(appDelegate.currentHabit?.why)\"?"
                    reminderNotification.alertAction = "open"
                    reminderNotification.fireDate = NSDate()
                    reminderNotification.category = "Habit_Reminder_Category"
                    reminderNotification.soundName = UILocalNotificationDefaultSoundName
                    UIApplication.sharedApplication().scheduleLocalNotification(reminderNotification)
                }
            }
        }
        return (h,m,s)
    }
    
    func updateProgress(){
        if(isUpdateAvailable!){
            appDelegate.currentHabit!.progress = Double(appDelegate.currentHabit!.progress) + 1
            currentProgress = Double(appDelegate.currentHabit!.progress)/Double(appDelegate.currentHabit!.occurrences.count)
            progressView.angle = Int(round(360 * currentProgress))
            updateStreak()
            isUpdateAvailable = false
            kCountDown = 900
            iconView.backgroundColor = UIColor.lightGrayColor()
            if(currentProgress == 1){
                buttonTimer.invalidate()
                buttonTimer = nil
                pinHabit("PreviousHabit")
                let completeAlertView = SCLAlertView()
                
                completeAlertView.addButton("Ok", action: { () -> Void in
                    self.deleteHabit()
                })
                completeAlertView.showCloseButton = false
                completeAlertView.showSuccess("Congratulations", subTitle: "You've successfully maintain a habit! Now time for a new one", closeButtonTitle: "Ok")
            }
            else {
                pinHabit("Habit")
            }
        }
        else{
            let alertView = SCLAlertView()
            
            let cb = checkButton()
            
            alertView.showInfo("Not so fast..", subTitle:"Still \(cb.0) hours and \(cb.1) minutes and \(cb.2) seconds left" , closeButtonTitle: "Ok")
        }
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func secondsToDaysHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int, Int){
        return (seconds / 86400, (seconds % 86400) / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func deleteHabit(){
        if(buttonTimer != nil){
            buttonTimer.invalidate()
            buttonTimer = nil
        }
        self.unpinHabit()
        self.appDelegate.currentHabit = nil
        deleteNotification()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("NewHabitViewController") as! UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func deleteNotification(){
        var app:UIApplication = UIApplication.sharedApplication()
        for event in app.scheduledLocalNotifications {
            var notification = event as! UILocalNotification
            let notificationCategory = notification.category
            if(notificationCategory == "Habit_Occurrence_Category"){
                app.cancelLocalNotification(notification)
            }
        }
    }
    
    func unpinHabit(){
        appDelegate.currentHabit!.unpinInBackgroundWithName ("Habit") { (Bool, error) -> Void in
            if (error == nil){
                
            }
        }
    }
    
    func pinHabit(pinGroup: String!){
        appDelegate.currentHabit!.pinInBackgroundWithName (pinGroup) { (Bool, error) -> Void in
            if (error == nil){
                
            }
        }
    }
}
