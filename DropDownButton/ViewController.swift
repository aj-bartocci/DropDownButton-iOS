//
//  ViewController.swift
//  DropDownButton
//
//  Created by AJ Bartocci on 1/8/16.
//  Copyright © 2016 AJ Bartocci
//
//  The MIT License (MIT)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

class ViewController: UIViewController, DropDownButtonSwiftDelegate, UIGestureRecognizerDelegate  {

    let containerView = UIView()
    let swiftView = UIView()
    let objCView = UIView()
    
    let mainColor = UIColor(red: 253/255, green: 227/255, blue: 167/255, alpha: 1)
    
    // Buttons
    let swiftLabelOne = UILabel(frame: CGRectMake(0,105,300,40));
    let dropButton = DropDownButtonSwift(frame: CGRectMake(0, 150, 200, 40))
    let swiftLabelTwo =  UILabel(frame: CGRectMake(0,270,300,40));
    let checkButton = DropDownButtonSwift(frame: CGRectMake(0, 315, 200, 40))
    
    // An array of strings for the button to use when dropping down
    //let dataArray = ["object 1","object 2","object 3","object 4","object 5","and so on..."]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = mainColor
        
        // Creating container view to flip between swift and obj c
        containerView.frame = self.view.frame
        self.view.addSubview(containerView)
        
        // Create view for obj c buttons
        objCView.frame = self.view.frame
        objCView.backgroundColor = UIColor.whiteColor()
        
        containerView.addSubview(objCView)
        
        // Create view for swift buttons
        swiftView.frame = self.view.frame
        swiftView.backgroundColor = mainColor
        
        containerView.addSubview(swiftView)
        
        // Add a gesture recognizer to the view to close buttons when background is tapped
        // If there is a gesture recognizer it must ignore the button (See README for info)
        let tapGest = UITapGestureRecognizer(target: self, action: "handleBackgroundTap:")
        tapGest.delegate = self
        swiftView.addGestureRecognizer(tapGest)
        
        let objCImplement = ObjCImplementation(frame: CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height))
        objCImplement.createDropDownButtons()
        objCView.addSubview(objCImplement)
        
        containerView.addSubview(objCView)
        
        // Call method to create the buttons using swift
        setupButtons()
        
        // Create button to switch views
        let switchButton = DropDownButtonSwift(frame: CGRectMake(self.view.frame.size.width/2-125, 20, 250, 40))
        switchButton.delegate = self
        switchButton.borderAndArrowColor(UIColor.orangeColor(), ofWidth: 4.0)
        switchButton.setTitle("Objective-C", forState: UIControlState.Normal)
        switchButton.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
        switchButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 22)
        switchButton.amountOfDrops = -1
        let switchArray = ["Objective-C","Swift"]
        switchButton.setDataSource(switchArray, isCheckList: false)
        
        self.view.addSubview(switchButton)
    }
    
    func setupButtons() {
        
        // An array of strings for the button to use when dropping down
        let dataArray = ["object 1","object 2","object 3","object 4","object 5","and so on..."]
        
        let swiftLabel = UILabel(frame: CGRectMake(self.view.frame.size.width/2-100, 210, 200, 40))
        swiftLabel.text = "Swift"
        swiftLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 22)
        swiftLabel.textAlignment = NSTextAlignment.Center;
        swiftLabel.textColor = UIColor.orangeColor()
        
        swiftView.addSubview(swiftLabel);
        
        // UILabel for demonstrative purposes
        swiftLabelOne.text = "Nothing Selected Yet"
        swiftLabelOne.textAlignment = NSTextAlignment.Center
        swiftLabelOne.backgroundColor = UIColor.orangeColor()
        swiftLabelOne.textColor = mainColor
        swiftLabelOne.center.x = swiftLabel.center.x
        
        swiftView.addSubview(swiftLabelOne)
        
        // Create drop down button with swift
        dropButton.center.x = swiftLabel.center.x
        dropButton.delegate = self
        dropButton.borderColor(UIColor.orangeColor())
        dropButton.borderWidth(2.0)
        dropButton.arrowColor(mainColor)
        dropButton.arrowWidth(2.0)
        dropButton.setTitle("Drop Button", forState: UIControlState.Normal)
        dropButton.setTitleColor(mainColor, forState: UIControlState.Normal)
        dropButton.backgroundColor = UIColor.orangeColor()
        dropButton.amountOfDrops = 4
        dropButton.setDataSource(dataArray, isCheckList: false)
        
        swiftView.addSubview(dropButton)
        
        // UILabel for demonstrative purposes
        swiftLabelTwo.text = "Nothing Selected Yet"
        swiftLabelTwo.textAlignment = NSTextAlignment.Center
        swiftLabelTwo.backgroundColor = UIColor.clearColor()
        swiftLabelTwo.center.x = swiftLabel.center.x
        swiftLabelTwo.layer.borderColor = UIColor.orangeColor().CGColor
        swiftLabelTwo.layer.borderWidth = 2.0
        swiftLabelTwo.textColor = UIColor.orangeColor()
        swiftLabelTwo.numberOfLines = 1
        swiftLabelTwo.minimumScaleFactor = 0.5
        swiftLabelTwo.adjustsFontSizeToFitWidth = true
        
        swiftView.insertSubview(swiftLabelTwo, belowSubview: dropButton)
        
        // Create drop down checklist button with swift
        checkButton.center.x = swiftLabel.center.x
        checkButton.delegate = self
        checkButton.borderAndArrowColor(UIColor.orangeColor(), ofWidth: 2.0)
        checkButton.setTitle("Checklist", forState: UIControlState.Normal)
        checkButton.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
        checkButton.backgroundColor = UIColor.clearColor()
        checkButton.amountOfDrops = 4
        checkButton.setDataSource(dataArray, isCheckList: true)
        
        swiftView.insertSubview(checkButton, belowSubview: dropButton)
        
    }
    
    func setupButtonWithObjC() {
        /*
        // Creates dropdown button using obj-c files (Allowing 1 selection)
        dropButtonObjC.delegate = self
        dropButtonObjC.setBorderColor(UIColor.orangeColor())
        dropButtonObjC.setArrowColor(UIColor.whiteColor())
        dropButtonObjC.arrowWidth = 2.0
        dropButtonObjC.setTitle("1 Selection", forState: UIControlState.Normal)
        dropButtonObjC.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        dropButtonObjC.backgroundColor = UIColor.orangeColor()
        dropButtonObjC.amountOfDrops = 4
        dropButtonObjC.setDataSource(dataArray, isCheckList: false)
        
        self.view.addSubview(dropButtonObjC)
        
        // UILabel for demonstrative purposes
        objCLabelOne.text = "Nothing Selected Yet"
        objCLabelOne.textAlignment = NSTextAlignment.Center
        objCLabelOne.backgroundColor = UIColor.orangeColor()
        objCLabelOne.textColor = UIColor.whiteColor()
        
        self.view.insertSubview(objCLabelOne, belowSubview: dropButtonObjC)
        
        // Creates dropdown button using obj-c files (Allowing multiple selections)
        dropChecklistObjC.delegate = self
        dropChecklistObjC.setBorderAndArrowColor(UIColor.orangeColor(), ofWidth: 2.0)
        dropChecklistObjC.setTitle("Checklist", forState: UIControlState.Normal)
        dropChecklistObjC.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
        dropChecklistObjC.backgroundColor = UIColor.whiteColor()
        dropChecklistObjC.amountOfDrops = 4
        dropChecklistObjC.setDataSource(dataArray, isCheckList: true)
        
        self.view.insertSubview(dropChecklistObjC, belowSubview: dropButtonObjC)
        
        // UILabel for demonstrative purposes
        objCLabelTwo.text = "Nothing Selected Yet"
        objCLabelTwo.textAlignment = NSTextAlignment.Center
        objCLabelTwo.backgroundColor = UIColor.whiteColor()
        objCLabelTwo.layer.borderColor = UIColor.orangeColor().CGColor
        objCLabelTwo.layer.borderWidth = 2.0
        objCLabelTwo.textColor = UIColor.orangeColor()
        objCLabelTwo.numberOfLines = 1
        objCLabelTwo.minimumScaleFactor = 0.5
        objCLabelTwo.adjustsFontSizeToFitWidth = true
        
        self.view.insertSubview(objCLabelTwo, belowSubview: dropChecklistObjC)
        */

    }
    
    // Delegate call to check when the button is animating
    func dropDownButtonSwiftDidAnimate(dropDownButton: DropDownButtonSwift) {
        print("did animate")
    }
    
    // Delegate call returns index of selected object to check against array
    func dropDownButtonSwift(dropDownButton: DropDownButtonSwift, selectedButtonAtIndex index: NSInteger) {
        if dropDownButton.isEqual(dropButton) {
            let selection = dropDownButton.datArray[index]
            swiftLabelOne.text = "Selected: \(selection)"
        } else if dropDownButton.isEqual(checkButton) {
            if swiftLabelTwo.text == "Nothing Selected Yet" {
                let selection = dropDownButton.datArray[index]
                swiftLabelTwo.text = "Selected: \(selection)"
            } else {
                let selection = swiftLabelTwo.text
                let newSelection = dropDownButton.datArray[index]
                swiftLabelTwo.text = "\(selection!) \(newSelection)"
            }
        } else {
            // has to be the switch button
            if index == 0 {
                //obj c
                UIView.transitionFromView(swiftView, toView: objCView, duration: 1.0, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: { (finished) -> Void in
                    
                })
                
            } else {
                //swift
                UIView.transitionFromView(objCView, toView: swiftView, duration: 1.0, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: { (finished) -> Void in
                    
                })
            }
        }
    }
    
    // Delegate call returns index of deselected object to check against array
    func dropDownButtonSwift(dropDownButton: DropDownButtonSwift, deselectedButtonAtIndex index: NSInteger) {
        if dropDownButton.isEqual(checkButton) {
            
            let currentSelection = swiftLabelTwo.text!
            let eraseSelection = " \(dropDownButton.datArray[index])"
            var finalSelection = currentSelection.stringByReplacingOccurrencesOfString(eraseSelection, withString: "")
            
            if finalSelection == "Selected:" {
                finalSelection = "Nothing Selected Yet"
            }
            
            swiftLabelTwo.text = finalSelection
        }
    }
    
    // UITapGestureRecognizer used to close the button when user taps away from it
    func handleBackgroundTap(gestureRecognizer: UITapGestureRecognizer) {
        dropButton.closeWhenTapOff()
        checkButton.closeWhenTapOff()
    }
    
    // Must ignore taps to the drop down button to let dropdown selection occur
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        if touch.view!.isDescendantOfView(dropButton) {
            // Close any other buttons that are open
            checkButton.closeWhenTapOff()
            return false
        }
        if touch.view!.isDescendantOfView(checkButton) {
            // Close any other buttons that are open
            dropButton.closeWhenTapOff()
            return false
        }
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

