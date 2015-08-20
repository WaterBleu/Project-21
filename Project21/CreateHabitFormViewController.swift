//
//  CreateHabitFormViewController.swift
//  Project21
//
//  Created by Jeff Huang on 2015-08-12.
//  Copyright (c) 2015 Jeff Huang. All rights reserved.
//

import UIKit
import XLForm
import SCLAlertView
import Parse

class CreateHabitFormViewController: XLFormViewController {
    
    var reminders:Int!
    var whyTextField:UITextField!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    func initializeForm() {
        
        let form : XLFormDescriptor
        var section : XLFormSectionDescriptor
        var row : XLFormRowDescriptor
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelPressed:")
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "savePressed:")
        
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = saveButton
        
        form = XLFormDescriptor(title: "New Habit")
        
        section = XLFormSectionDescriptor.formSection()
        form.addFormSection(section)
        
        // Title
        row = XLFormRowDescriptor(tag: "title", rowType: XLFormRowDescriptorTypeText)
        row.cellConfigAtConfigure["textField.placeholder"] = "Name of Habit"
        row.required = true
        section.addFormRow(row)
        
        section = XLFormSectionDescriptor.formSection()
        form.addFormSection(section)
        
        // Step counter
        row = XLFormRowDescriptor(tag: "numOccurrence", rowType: XLFormRowDescriptorTypeStepCounter, title: "# of Occurrence")
        row.value = 1
        section.addFormRow(row)
        
        // Starts
        row = XLFormRowDescriptor(tag: "occurrence-1", rowType: XLFormRowDescriptorTypeTimeInline, title: "1st Occurrence")
        row.value = NSDate()
        row.required = true
        section.addFormRow(row)
        
        section = XLFormSectionDescriptor.formSection()
        section.title = "Repeated Day"
        form.addFormSection(section)
        
        // WeekDays
        row = XLFormRowDescriptor(tag: "CustomRowWeekdays", rowType: XLFormRowDescriptorTypeWeekDays)
        row.value =  [
            XLFormWeekDaysCell.kWeekDay.Sunday.description(): true,
            XLFormWeekDaysCell.kWeekDay.Monday.description(): true,
            XLFormWeekDaysCell.kWeekDay.Tuesday.description(): true,
            XLFormWeekDaysCell.kWeekDay.Wednesday.description(): true,
            XLFormWeekDaysCell.kWeekDay.Thursday.description(): true,
            XLFormWeekDaysCell.kWeekDay.Friday.description(): true,
            XLFormWeekDaysCell.kWeekDay.Saturday.description(): true
        ]
        row.required = true
        section.addFormRow(row)
        
        section = XLFormSectionDescriptor.formSection()
        form.addFormSection(section)
        
        // Alert
        row = XLFormRowDescriptor(tag: "alert", rowType:XLFormRowDescriptorTypeSelectorPush, title:"Alert")
        row.value = XLFormOptionsObject(value: 0, displayText: "None")
        row.selectorTitle = "Event Alert"
        row.selectorOptions = [
            XLFormOptionsObject(value: 0, displayText: "None"),
            XLFormOptionsObject(value: 1, displayText: "5 minutes before"),
            XLFormOptionsObject(value: 2, displayText: "10 minutes before"),
            XLFormOptionsObject(value: 3, displayText: "15 minutes before"),
            XLFormOptionsObject(value: 4, displayText: "30 minutes before"),
            XLFormOptionsObject(value: 5, displayText: "1 hour before"),
            XLFormOptionsObject(value: 6, displayText: "2 hours before")]
        section.addFormRow(row)
        
        self.form = form
    }
    
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)
        if formRow.tag == "numOccurrence" {
            let oldNum = oldValue.valueData() as! Int
            let newNum = newValue.valueData() as! Int
            let newString = String(newNum)
            //resign responder
            self.tableView.endEditing(true)
            //TODO: limit range to be from 0-10
            if(newNum > oldNum && oldNum != 0){
                let oldRow = form.formRowWithTag("occurrence-\(oldNum)")
                let newRow = oldRow!.copy() as! XLFormRowDescriptor
                newRow.tag = "occurrence-\(newNum)"
                if(newString.hasSuffix("1")){
                    newRow.title = "\(newNum)st Occurrence"
                }
                else if(newString.hasSuffix("2")){
                    newRow.title = "\(newNum)nd Occurrence"
                }
                else if(newString.hasSuffix("3")){
                    newRow.title = "\(newNum)rd Occurrence"
                }
                else {
                    newRow.title = "\(newNum)th Occurrence"
                }
                self.form.addFormRow(newRow, afterRow:oldRow!)
            }
            else if(newNum > oldNum && oldNum == 0){
                let oldRow = self.form.formRowWithTag("occurrence-\(newNum)")
                oldRow?.hidden = false
            }
            else{
                if(oldNum != 1){
                    self.form.removeFormRowWithTag("occurrence-\(oldNum)")
                }
                else{
                    let oldRow = self.form.formRowWithTag("occurrence-\(oldNum)")
                    oldRow?.hidden = true
                }
            }
        }
        else if formRow.tag == "alert" {
            let newNum = newValue.valueData() as! Int
            switch newNum{
            case 1:
                reminders = 5
            case 2:
                reminders = 10
            case 3:
                reminders = 15
            case 4:
                reminders = 30
            case 5:
                reminders = 60
            case 6:
                reminders = 120
            default:
                println("Invalid alert duration")
            }
        }
    }
    
    func cancelPressed(sender: UIBarButtonItem) {
        println("display alert confirming to discard the changes")
        let alertView = SCLAlertView()
        alertView.addButton("Yes", action: { () -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        alertView.addButton("No", action: { () -> Void in
            println("button No, stayed inside same controller")
        })
        alertView.showCloseButton = false
        alertView.showWarning("Warning", subTitle: "You are about to lose all changes! Do you want to proceed?")
    }
    
    func savePressed(sender: UIBarButtonItem) {
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            return
        }
        self.tableView.endEditing(true)
        self.getWhy()
    }
    
    func occurrenceValidationErrors(){
        //TODO: handle occurrence order being incorrect
    }

    override func showFormValidationError(error: NSError!) {
        SCLAlertView().showError("Hold On...", subTitle:"\(error.localizedDescription)", closeButtonTitle:"OK")
    }
    
    func getWhy(){
        let whyAlertView = SCLAlertView()
        whyAlertView.addButton("Submit", action: { () -> Void in
            let confirmAlertView = SCLAlertView()
            confirmAlertView.addButton("Yes", action: { () -> Void in
                self.getWhy()
            })
            confirmAlertView.addButton("No", action: { () -> Void in
                self.saveHabit()
                let congratAlertView = SCLAlertView()
                congratAlertView.addButton("OK", action: { () -> Void in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewControllerWithIdentifier("MainViewController") as! UIViewController
                    self.appDelegate.mainVC = vc as! MainViewController
                    self.presentViewController(vc, animated: true, completion: nil)
                })
                congratAlertView.showCloseButton = false
                congratAlertView.showSuccess("Congratulations", subTitle: "You've took a step forward!")
            })
            confirmAlertView.showCloseButton = false
            confirmAlertView.showInfo("So...", subTitle: "Is there a deeper reason than \"\(self.whyTextField.text)\"?")
        })
        whyTextField = whyAlertView.addTextField(title: "Enter your why")
        whyAlertView.showCloseButton = false
        whyAlertView.showInfo("Why", subTitle: "What is the reason you want to form this habit?")
    }
    
    func saveHabit(){
        var occurrences = [NSDate]()
        var repeatDay:[String:Int]
        
        var row = self.form.formRowWithTag("title")
        let title = row!.value as! String
        
        row = self.form.formRowWithTag("numOccurrence")
        let numOccurrence = row!.value as! Int
        
        for index in 1...numOccurrence{
            let occurRow = self.form.formRowWithTag("occurrence-\(index)")
            //let time = NSCalendar.currentCalendar().dateBySettingUnit(.CalendarUnitSecond, value: 0, ofDate: occurRow?.value as! NSDate, options: NSCalendarOptions(0))
            occurrences.append(occurRow!.value as! NSDate)
        }
        
        row = self.form.formRowWithTag("CustomRowWeekdays")
        repeatDay = row?.value as! [String:Int]
        
        appDelegate.currentHabit = HabitObject(title: title, occurrences: occurrences, repeatDay: repeatDay, reminders: reminders, why: whyTextField.text)
        println(appDelegate.currentHabit)
        
        appDelegate.currentHabit!.pinInBackgroundWithName ("Habit") { (Bool, error) -> Void in
            if (error == nil){
                
            }
        }
    }
}
