//
//  HabitObject.swift
//  Project21
//
//  Created by Jeff Huang on 2015-08-12.
//  Copyright (c) 2015 Jeff Huang. All rights reserved.
//

import UIKit
import Parse

class HabitObject: PFObject, PFSubclassing {
    @NSManaged var title:String!
    @NSManaged var occurrences:[NSDate]!
    @NSManaged var numPerDay:NSNumber!
    @NSManaged var reminders:[NSDate]!
    @NSManaged var repeatDay:[String:Int]!
    @NSManaged var progress:NSNumber!
    @NSManaged var why:String!
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    override init() {
        super.init()
    }
    
    init(title: String!, occurrences: [NSDate]!, repeatDay:[String:Int]!, reminders: Int!, why: String!) {
        super.init()
        self.title = title
        self.repeatDay = repeatDay
        self.occurrences = [NSDate]()
        self.numPerDay = occurrences.count
        self.reminders = [NSDate]()
        self.progress = 0
        self.why = why
        
        let weekArray = [
            (repeatDay["Sunday"] == 1) ? true : false,
            (repeatDay["Monday"] == 1) ? true : false,
            (repeatDay["Tuesday"] == 1) ? true : false,
            (repeatDay["Wednesday"] == 1) ? true : false,
            (repeatDay["Thursday"] == 1) ? true : false,
            (repeatDay["Friday"] == 1) ? true : false,
            (repeatDay["Saturday"] == 1) ? true : false,
        ]
        
        let creationDate = NSDate()
        var numOfCycle = 0
        var numOfDay = 0
        var isCycle = false
        
        while numOfCycle != 21 {
            for index in 0..<occurrences.count{
                let time = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: numOfDay, toDate: occurrences[index], options: NSCalendarOptions(0))
                if(weekArray[getDayOfWeek(time!) - 1]){
                    self.occurrences.append(time!)
                    isCycle = true
                }
            }
            if(isCycle){
                isCycle = false
                numOfCycle++
            }
            numOfDay++
        }
        var newOccurrences = self.occurrences
        for var index = 0; index < occurrences.count; ++index{
            let date = newOccurrences[index]
            if date.compare(creationDate) == .OrderedAscending {
                newOccurrences.removeAtIndex(index)
            }
        }
        self.occurrences = newOccurrences
        
        for date in self.occurrences{
            var occurrenceNotification = UILocalNotification()
            var reminderNotification = UILocalNotification()
            
            occurrenceNotification.alertBody = "Habit is due!"
            occurrenceNotification.alertAction = "open"
            occurrenceNotification.fireDate = date
            occurrenceNotification.category = "Habit_Occurrence_Category"
            occurrenceNotification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().scheduleLocalNotification(occurrenceNotification)
            
            if(reminders != nil){
                let time = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitMinute, value:-reminders, toDate: date, options: NSCalendarOptions(0))
                
                reminderNotification.alertBody = "Habit will be due in \(reminders) mins"
                reminderNotification.alertAction = "open"
                reminderNotification.fireDate = time
                reminderNotification.category = "Habit_Reminder_Category"
                reminderNotification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.sharedApplication().scheduleLocalNotification(reminderNotification)
                
                self.reminders.append(time!)
            }
        }
        
    }
    
    class func parseClassName() -> String {
        return "HabitObject"
    }
    
    func getDayOfWeek(date: NSDate) -> Int{
        let dateCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let dateComponents = dateCalendar.components(.CalendarUnitWeekday, fromDate: date)
        let weekDay = dateComponents.weekday
        return weekDay
    }
    
    func getDayOfWeekInString(date: Int) -> String{
        var weekDay:String!
        switch(date){
        case 1:
            weekDay = "Sunday"
        case 2:
            weekDay = "Monday"
        case 3:
            weekDay = "Tuesday"
        case 4:
            weekDay = "WednesDay"
        case 5:
            weekDay = "Thursday"
        case 6:
            weekDay = "Friday"
        case 7:
            weekDay = "Saturday"
        default:
            println("Invalid date")
        }
        return weekDay
    }
}
