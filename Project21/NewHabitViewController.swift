//
//  ViewController.swift
//  Project21
//
//  Created by Jeff Huang on 2015-08-10.
//  Copyright (c) 2015 Jeff Huang. All rights reserved.
//

import UIKit
import AAShareBubbles
import SCLAlertView

class NewHabitViewController: UIViewController, AAShareBubblesDelegate {
    
    @IBOutlet weak var menuButton: UIButton!
    var startMenu:AAShareBubbles!
    var radius:Int32 = 140
    var bubbleRadius:Int32! = 35

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func menuTapped(sender: UIButton) {
        if((startMenu) != nil){
            startMenu = nil
        }
        startMenu = AAShareBubbles(point: menuButton.center, radius: radius, inView: self.view)
        startMenu.delegate = self
        startMenu.bubbleRadius = bubbleRadius
        
        startMenu.addCustomButtonWithIcon(UIImage(named: "add"), label: "New Habit", andBackgroundColor: UIColor(red:0.87, green:0.29, blue:0.22, alpha:1.0), andButtonId: 100)
        
        
        startMenu.addCustomButtonWithIcon(UIImage(named: "friend"), label: "Private Habit", andBackgroundColor: UIColor(red:0.30, green:0.66, blue:0.40, alpha:1.0), andButtonId: 101)
        
        startMenu.addCustomButtonWithIcon(UIImage(named: "world"), label: "Public Habit", andBackgroundColor: UIColor(red:0.27, green:0.52, blue:0.95, alpha:1.0), andButtonId: 102)
        
        startMenu.show()
    }
    
    func aaShareBubbles(shareBubbles: AAShareBubbles!, tappedBubbleWithType bubbleType: Int32){
        switch(bubbleType){
        case 100:
            let vc = CreateHabitFormViewController(nibName: nil, bundle: nil)
            let navControl = UINavigationController(rootViewController: vc)
            self.presentViewController(navControl, animated: true, completion: nil)
        case 101,
        102:
            SCLAlertView().showInfo("Under Construction!", subTitle: "This feature is being implemented please proceed to personal habit function", closeButtonTitle: "Ok")
        
        default:
            println("Inside default")
        }
    }
    
    

}

