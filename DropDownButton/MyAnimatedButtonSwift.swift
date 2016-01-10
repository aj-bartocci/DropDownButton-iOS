//
//  MyAnimatedButtonSwift.swift
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

@objc protocol MyAnimatedButtonSwiftDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool
    
    optional
    func myAnimatedButtonSwiftDidAnimate(myAnimatedButton: MyAnimatedButtonSwift)
    func myAnimatedButtonSwift(myAnimatedButton:MyAnimatedButtonSwift, selectedButtonAtIndex index:NSInteger)
    func myAnimatedButtonSwift(myAnimatedButton:MyAnimatedButtonSwift, deselectedButtonAtIndex index:NSInteger)
    
}

class MyAnimatedButtonSwift: UIButton, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // Public
    var amountOfDrops = CGFloat()
    var tableView = UITableView()
    var isChecklist = false
    weak var delegate: MyAnimatedButtonSwiftDelegate?
    // Readonly to public
    private(set) internal var datArray = NSArray()
    private(set) internal var dataArrayCount = NSInteger()
    private(set) internal var isOpen = false
    
    // Hidden from public
    private var borderWidth = Float()
    private var arrowWidth = Float()
    private var borderColor = UIColor()
    private var arrowColor = UIColor()
    private var arrowView = UIView()
    private var arrowLayer = CAShapeLayer()
    private var leftBorder = CAShapeLayer()
    private var rightBorder = CAShapeLayer()
    private var bottomBorder = CAShapeLayer()
    private var topBorder = CAShapeLayer()
    private var backgroundShape = CAShapeLayer()
    private var arrowLeftHalf = CAShapeLayer()
    private var arrowRightHalf = CAShapeLayer()
    private var indexPathArray = NSMutableArray()
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        setupButton()
    }

    required init?(coder aDecoder: NSCoder) {
        //no at this time
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupButton() {
        
        // Add a tapgesture for button animation
        let tapGest = UITapGestureRecognizer(target: self, action: "buttonPressed")
        tapGest.delegate = self
        tapGest.cancelsTouchesInView = false
        self.addGestureRecognizer(tapGest)
        
        // Set default number of drops to the smallest possible
        amountOfDrops = 2
        
        // Create the default background
        
        backgroundShape.path = UIBezierPath(rect: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)).CGPath
        backgroundShape.fillColor = backgroundColor?.CGColor
        self.layer.addSublayer(backgroundShape)
        
        // Default colors to white
        borderColor = UIColor.whiteColor()
        arrowColor = UIColor.whiteColor()
        
        // Create the borders of the button
        leftBorder = drawLine(CGPointMake(0, 0), toPoint: CGPointMake(0, self.frame.size.height), withColor: UIColor.whiteColor(), ofWidth: 1.0)
        self.layer.addSublayer(leftBorder)
        
        rightBorder = drawLine(CGPointMake(self.frame.size.width, 0), toPoint: CGPointMake(self.frame.size.width, self.frame.size.height), withColor: UIColor.whiteColor(), ofWidth: 1.0)
        self.layer.addSublayer(rightBorder)
        
        bottomBorder = drawLine(CGPointMake(0, self.frame.size.height), toPoint: CGPointMake(self.frame.size.width, self.frame.size.height), withColor: UIColor.whiteColor(), ofWidth: 1.0)
        self.layer.addSublayer(bottomBorder)
        
        topBorder = drawLine(CGPointMake(0, 0), toPoint: CGPointMake(self.frame.size.width, 0), withColor: UIColor.whiteColor(), ofWidth: 1.0)
        self.layer.addSublayer(topBorder)
        
        // Create the arrow
        arrowLayer.path = UIBezierPath(rect: CGRectMake(self.frame.size.width-50, self.frame.size.height/2-22.5, 45, 45)).CGPath
        
        arrowView = UIView(frame: CGRectMake(self.frame.size.width-50, self.frame.size.height/2-22.5, 45, 45))
        arrowView.userInteractionEnabled = false
        self.addSubview(arrowView)
        
        arrowLeftHalf = drawLine(CGPointMake(10, 15), toPoint: CGPointMake(23, 30), withColor: UIColor.whiteColor(), ofWidth: 1.0)
        arrowView.layer.addSublayer(arrowLeftHalf)
        
        arrowRightHalf = drawLine(CGPointMake(22, 30), toPoint: CGPointMake(35, 15), withColor: UIColor.whiteColor(), ofWidth: 1.0)
        arrowView.layer.addSublayer(arrowRightHalf)
        
        isOpen = false
        self.enabled = true
        
    }
    
    // MARK: Animation Methods
    
    func buttonPressed() {
        if self.enabled {
            animateButton()
        }
    }
    
    func closeWhenTapOff() {
        if isOpen && self.enabled {
            animateButton()
        }
    }
    
    // Animate the button open and closed
    func animateButton() {
        if amountOfDrops < 2 {
            // Can't have it drop less than twice or there is no point in a drop down
            amountOfDrops = 2
        }
        if !isOpen {
            arrowView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            self.enabled = false
            
            let origRect = self.frame
            let scaleTrans = CATransform3DMakeScale(1.0, self.amountOfDrops, 1.0)
            
            UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseOut, animations: {
                
                self.backgroundShape.transform = scaleTrans
                self.leftBorder.transform = scaleTrans
                self.rightBorder.transform = scaleTrans
                
                let dy = CGFloat((self.amountOfDrops-1)*self.frame.size.height)
                let posTrans = CATransform3DMakeTranslation(0.0, dy, 0.0)
                self.bottomBorder.transform = posTrans
                
                self.tableView.frame.size.height = (self.amountOfDrops-1)*self.frame.size.height
                
                }, completion: { finished in
                    
                    self.isOpen = true
                    self.enabled = true
                    
                    self.frame.size.height *= self.amountOfDrops
                    
                    let topEdge = -self.frame.size.height+origRect.size.height
                    self.titleEdgeInsets = UIEdgeInsetsMake(topEdge, 0.0, 0.0, 0.0)
                    
                    // Tell delegate that the animation has ended
                    self.delegate?.myAnimatedButtonSwiftDidAnimate!(self)

            })
            
        } else {
            
            arrowView.transform = CGAffineTransformMakeRotation(0)
            self.enabled = false
            let scaleTrans = CATransform3DMakeScale(1.0, 1.0, 1.0)
            
            UIView .animateWithDuration(0.25, delay: 0.0, options: .CurveEaseOut, animations: {
                
                self.tableView.frame.size.height = 0.0
                
                self.leftBorder.transform = scaleTrans
                self.rightBorder.transform = scaleTrans
                self.backgroundShape.transform = scaleTrans
                
                let posTrans = CATransform3DMakeTranslation(0.0, 0.0, 0.0)
                self.bottomBorder.transform = posTrans
                
                }, completion: { finished in
                    
                    self.isOpen = false
                    self.enabled = true
                    
                    self.frame.size.height /= self.amountOfDrops
                    
                    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
                    
                    // Tell delegate that the animation has ended
                    self.delegate?.myAnimatedButtonSwiftDidAnimate!(self)
            })
        }
        
    }
    
    // Override UIButton's background color property
    private var _backgroundColor: UIColor? = nil
    override var backgroundColor: UIColor? {
        get {
            return self._backgroundColor
        }
        set {
            backgroundShape.fillColor = backgroundColor?.CGColor
            self._backgroundColor = newValue
            backgroundShape.fillColor = backgroundColor?.CGColor
        }
    }
    
    // MARK: Border and Arrow Methods
    
    func borderColor(color:UIColor) {
        borderColor = color;
        
        topBorder.strokeColor = color.CGColor;
        bottomBorder.strokeColor = color.CGColor;
        rightBorder.strokeColor = color.CGColor;
        leftBorder.strokeColor = color.CGColor;
    }
    
    func arrowColor(color:UIColor) {
        arrowColor = color;
        
        arrowLeftHalf.strokeColor = color.CGColor;
        arrowRightHalf.strokeColor = color.CGColor;
    }
    
    func arrowWidth(width:CGFloat) {
        if arrowWidth >= 0 {
            arrowLeftHalf.lineWidth = width
            arrowRightHalf.lineWidth = width
        }
    }
    
    func borderWidth(width:CGFloat) {
        if  width >= 0 {
            topBorder.lineWidth = width
            bottomBorder.lineWidth = width
            rightBorder.lineWidth = width
            leftBorder.lineWidth = width
            
            leftBorder.frame.origin.x = 0.5
            rightBorder.frame.origin.x = topBorder.frame.size.width-0.5
            bottomBorder.frame.origin.y = rightBorder.frame.size.height-width/2
            topBorder.frame.origin.y = width/2
        }
    }
    
    func borderAndArrowColor(color:UIColor, ofWidth width:CGFloat) {
        borderColor = color;
        arrowColor = color;
        
        topBorder.strokeColor = color.CGColor;
        bottomBorder.strokeColor = color.CGColor;
        rightBorder.strokeColor = color.CGColor;
        leftBorder.strokeColor = color.CGColor;
        arrowLeftHalf.strokeColor = color.CGColor;
        arrowRightHalf.strokeColor = color.CGColor;
        
        if  width >= 0 {
            topBorder.lineWidth = width
            bottomBorder.lineWidth = width
            rightBorder.lineWidth = width
            leftBorder.lineWidth = width
            
            leftBorder.frame.origin.x = 0.5
            rightBorder.frame.origin.x = topBorder.frame.size.width-0.5
            bottomBorder.frame.origin.y = rightBorder.frame.size.height-width/2
            topBorder.frame.origin.y = width/2
            
            arrowLeftHalf.lineWidth = width;
            arrowRightHalf.lineWidth = width;
        }
    }
    
    // MARK: TableView Methods
    
    func setDataSource(array: NSArray, isCheckList checkList:Bool) {
        // Check if tableview has been added to the view yet
        if !tableView.isDescendantOfView(self) {
            tableView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 0)
            tableView.backgroundColor = UIColor.clearColor()
            tableView.separatorColor = UIColor.whiteColor()
            
            if checkList {
                isChecklist = true
                tableView.allowsMultipleSelection = true
            }
            self.addSubview(tableView)
        }
        datArray = array
        dataArrayCount = datArray.count
        
        tableView.separatorColor = arrowColor
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return datArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let simpleTableIdentifier = "SimpleTableItem"
        var cell = tableView.dequeueReusableCellWithIdentifier(simpleTableIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: simpleTableIdentifier)
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
            cell?.backgroundColor = UIColor.clearColor()
        }
        
        if tableView.respondsToSelector("setSeparatorInset:") {
            tableView.separatorInset = UIEdgeInsetsZero
        }
        
        if tableView.respondsToSelector("setLayoutMargins:") {
            tableView.layoutMargins = UIEdgeInsetsZero
        }
        
        if cell!.respondsToSelector("setLayoutMargins:") {
            cell?.layoutMargins = UIEdgeInsetsZero
        }
        
        if isChecklist {
            if let indexPaths = tableView.indexPathsForSelectedRows {
                if indexPaths.contains(indexPath) {
                    cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
                } else {
                    cell?.accessoryType = UITableViewCellAccessoryType.None
                }
            }
        }
        
        cell?.separatorInset = UIEdgeInsetsZero
        cell?.tintColor = arrowColor
        cell?.textLabel?.text = datArray[indexPath.row] as? String
        cell?.textLabel?.textColor = arrowColor
        cell?.textLabel?.textAlignment = NSTextAlignment.Center
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if isChecklist {
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            let string = datArray[indexPath.row] as? String
            self.setTitle(string, forState: .Normal)
            animateButton()
        }
        delegate?.myAnimatedButtonSwift(self, selectedButtonAtIndex: indexPath.row)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        if isChecklist {
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = UITableViewCellAccessoryType.None
        }
        delegate?.myAnimatedButtonSwift(self, deselectedButtonAtIndex: indexPath.row)
    }
    
    // Gesture recgognizer for opening and closing
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        if touch.view!.isDescendantOfView(tableView) {
            return false
        }
        
        return true
    }
    
    // MARK: Helper Methods
    
    func drawLine(fromPoint:CGPoint, toPoint:CGPoint, withColor:UIColor, ofWidth:CGFloat) -> CAShapeLayer {
        
        let lineShape = CAShapeLayer()
        
        let path = UIBezierPath()
        path.moveToPoint(fromPoint)
        path.addLineToPoint(toPoint)
        
        lineShape.path = path.CGPath
        lineShape.strokeColor = withColor.CGColor
        lineShape.lineWidth = ofWidth
        
        return lineShape
    }

}

