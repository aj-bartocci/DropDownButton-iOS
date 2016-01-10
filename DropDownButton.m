//
//  DropDownButton.m
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

#import "DropDownButton.h"

@interface DropDownButton ()

@property (nonatomic) UIColor *theBorderColor;
@property (nonatomic) UIColor *theBackgroundColor;
@property (nonatomic) UIColor *theArrowColor;
@property (nonatomic) UIView *arrowView;
@property (nonatomic) CAShapeLayer *arrowLayer;
@property (nonatomic) CAShapeLayer *leftBorder;
@property (nonatomic) CAShapeLayer *rightBorder;
@property (nonatomic) CAShapeLayer *bottomBorder;
@property (nonatomic) CAShapeLayer *topBorder;
@property (nonatomic) CAShapeLayer *backgroundShape;
@property (nonatomic) CAShapeLayer *arrowLeftHalf;
@property (nonatomic) CAShapeLayer *arrowRightHalf;
@property (nonatomic) NSArray *dataArray;
@property (nonatomic) NSMutableArray *indexPathArray;
@property (nonatomic) NSInteger dataArrayCount;
@property (nonatomic) int numSelections;
@property (nonatomic) BOOL isOpen;

@end

@implementation DropDownButton

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil) {
        return nil;
    }
    
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonPressed:)];
    tapGest.delegate = self;
    tapGest.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tapGest];
    
    //set default number of drops
    self.amountOfDrops = 2;
    
    //create the button background, layer 0
    self.backgroundShape = [[CAShapeLayer alloc] init];
    CGRect maskRect = CGRectMake(0, 0, frame.size.width, frame.size.height);
    CGPathRef path = CGPathCreateWithRect(maskRect, NULL);
    self.backgroundShape.path = path;
    CGPathRelease(path);
    self.backgroundShape.fillColor = self.backgroundColor.CGColor;
    [self.layer addSublayer:self.backgroundShape];
    
    //default to white color
    self.theBorderColor = [UIColor whiteColor];
    self.theArrowColor = [UIColor whiteColor];
    
    //layer 1
    self.leftBorder = [self drawLineFromPoint:CGPointMake(0.5, 0) toPoint:CGPointMake(0.5, frame.size.height) withColor:[UIColor whiteColor] ofWidth:1.0];
    [self.layer addSublayer:self.leftBorder];
    
    //layer 2
    self.rightBorder = [self drawLineFromPoint:CGPointMake(frame.size.width-0.5, 0) toPoint:CGPointMake(frame.size.width-0.5, frame.size.height) withColor:[UIColor whiteColor] ofWidth:1.0];
    [self.layer addSublayer:self.rightBorder];
    
    //layer 3
    self.bottomBorder = [self drawLineFromPoint:CGPointMake(0, frame.size.height) toPoint:CGPointMake(frame.size.width, frame.size.height) withColor:[UIColor whiteColor] ofWidth:1.0];
    [self.layer addSublayer:self.bottomBorder];
    
    //layer 4
    self.topBorder = [self drawLineFromPoint:CGPointMake(0, 0) toPoint:CGPointMake(frame.size.width, 0) withColor:[UIColor whiteColor] ofWidth:1.0];
    [self.layer addSublayer:self.topBorder];
    
    //make the arrow
    self.arrowLayer = [CAShapeLayer layer];
    [self.arrowLayer setPath:[[UIBezierPath bezierPathWithRect:CGRectMake(frame.size.width-50, frame.size.height/2-22.5, 45, 45)] CGPath]];
    
    self.arrowView = [[UIView alloc]initWithFrame:CGRectMake(frame.size.width-50, frame.size.height/2-22.5, 45, 45)];
    self.arrowView.userInteractionEnabled = NO;
    [self addSubview:self.arrowView];
    
    self.arrowLeftHalf = [self drawLineFromPoint:CGPointMake(10, 15) toPoint:CGPointMake(23, 30) withColor:[UIColor whiteColor] ofWidth:1.0];
    [self.arrowView.layer addSublayer:self.arrowLeftHalf];
    
    self.arrowRightHalf = [self drawLineFromPoint:CGPointMake(22, 30) toPoint:CGPointMake(35, 15) withColor:[UIColor whiteColor] ofWidth:1.0];
    [self.arrowView.layer addSublayer:self.arrowRightHalf];
    
    self.dataArray = [[NSArray alloc]init];
    
    //set bools to defaults
    self.isOpen = false;
    self.enabled = true;
    
    self.numSelections = 0;
    
    return self;
}

#pragma mark - Animation Methods

- (void)buttonPressed:(UITapGestureRecognizer *)tapGest {
    
    if (self.enabled) {
        [self animateButton];
    }
}

- (void)closeWhenTapOff {
    if (self.isOpen && self.enabled) {
        [self animateButton];
    }
}

- (void)animateButton {
    
    if (self.amountOfDrops < 2) {
        // Can't have it drop less than twice or there is no point in a drop down
        self.amountOfDrops = 2;
    }
    
    if (!self.isOpen) {
        self.arrowView.transform = CGAffineTransformMakeRotation(M_PI);
        self.enabled = false;
        
        CGRect origRect = self.frame;
        
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            CATransform3D scaleTrans = CATransform3DMakeScale(1.0, self.amountOfDrops, 1.0);
            self.leftBorder.transform = scaleTrans;
            self.rightBorder.transform = scaleTrans;
            self.backgroundShape.transform = scaleTrans;
            
            float dy = (self.amountOfDrops-1)*self.frame.size.height;
            CATransform3D posTrans = CATransform3DMakeTranslation(0.0, dy, 0.0);
            self.bottomBorder.transform = posTrans;
            
            CGRect tableRect = self.tableView.frame;
            tableRect.size.height = (self.amountOfDrops-1)*self.frame.size.height;
            self.tableView.frame = tableRect;
            
        } completion:^(BOOL finished){
            self.isOpen = true;
            self.enabled = true;
            
            CGRect butRect = self.frame;
            butRect.size.height = self.frame.size.height*self.amountOfDrops;
            self.frame = butRect;
            
            float topEdge = -self.frame.size.height+origRect.size.height;
            [self setTitleEdgeInsets:UIEdgeInsetsMake(topEdge, 0.0, 0.0, 0.0)];
            
            //tell delegate animation ended if the method is being implemented
            if ([delegate respondsToSelector:@selector(dropDownButtonDidAnimate:)]) {
                [delegate dropDownButtonDidAnimate:self];
            }
        }];
        
    }
    else {
        self.arrowView.transform = CGAffineTransformMakeRotation(0);
        self.enabled = false;
        
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            CGRect tableRect = self.tableView.frame;
            tableRect.size.height = 0.0;
            self.tableView.frame = tableRect;
            
            CATransform3D scaleTrans = CATransform3DMakeScale(1.0, 1.0, 1.0);
            self.leftBorder.transform = scaleTrans;
            self.rightBorder.transform = scaleTrans;
            self.backgroundShape.transform = scaleTrans;
            
            CATransform3D posTrans = CATransform3DMakeTranslation(0.0, 0.0, 0.0);
            self.bottomBorder.transform = posTrans;
            
        } completion:^(BOOL finished){
            self.isOpen = false;
            self.enabled = true;
            
            CGRect butRect = self.frame;
            butRect.size.height = self.frame.size.height/self.amountOfDrops;
            self.frame = butRect;
            
            [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
            
            self.titleLabel.layer.opacity = 1.0;
            //tell delegate animation ended if the method is being implemented
            if ([delegate respondsToSelector:@selector(dropDownButtonDidAnimate:)]) {
                [delegate dropDownButtonDidAnimate:self];
            }
        }];
    }
}

#pragma mark - Border and Arrow Methods

- (void)setBorderWidth:(float)width {
    if (width >= 0) {
        self.topBorder.lineWidth = width;
        self.bottomBorder.lineWidth = width;
        self.rightBorder.lineWidth = width;
        self.leftBorder.lineWidth = width;
    }
    
    CGRect leftRect = self.leftBorder.frame;
    leftRect.origin.x = 0.5;
    self.leftBorder.frame = leftRect;
    
    CGRect rightRect = self.rightBorder.frame;
    rightRect.origin.x = self.topBorder.frame.size.width-(0.5);
    self.rightBorder.frame = rightRect;
    
    CGRect bottomRect = self.bottomBorder.frame;
    bottomRect.origin.y = self.rightBorder.frame.size.height-width*0.5;
    self.bottomBorder.frame = bottomRect;
    
    CGRect topRect = self.topBorder.frame;
    topRect.origin.y = width*0.5;
    self.topBorder.frame = topRect;
}

- (void)setArrowWidth:(float)arrowWidth {
    if (arrowWidth >= 0) {
        self.arrowLeftHalf.lineWidth = arrowWidth;
        self.arrowRightHalf.lineWidth = arrowWidth;
    }
}

- (void)setBorderColor:(UIColor *)color {
    self.theBorderColor = color;
    
    self.topBorder.strokeColor = color.CGColor;
    self.bottomBorder.strokeColor = color.CGColor;
    self.rightBorder.strokeColor = color.CGColor;
    self.leftBorder.strokeColor = color.CGColor;
}

- (void)setArrowColor:(UIColor *)color {
    self.theArrowColor = color;
    
    self.arrowLeftHalf.strokeColor = color.CGColor;
    self.arrowRightHalf.strokeColor = color.CGColor;
}

- (void)setBorderAndArrowColor:(UIColor *)color ofWidth:(float)width {
    self.theBorderColor = color;
    self.theArrowColor = color;
    
    self.topBorder.strokeColor = color.CGColor;
    self.bottomBorder.strokeColor = color.CGColor;
    self.rightBorder.strokeColor = color.CGColor;
    self.leftBorder.strokeColor = color.CGColor;
    self.arrowLeftHalf.strokeColor = color.CGColor;
    self.arrowRightHalf.strokeColor = color.CGColor;
    
    if (width >= 0) {
        self.topBorder.lineWidth = width;
        self.bottomBorder.lineWidth = width;
        self.rightBorder.lineWidth = width;
        self.leftBorder.lineWidth = width;
    }
    
    CGRect leftRect = self.leftBorder.frame;
    leftRect.origin.x = 0.5;
    self.leftBorder.frame = leftRect;
    
    CGRect rightRect = self.rightBorder.frame;
    rightRect.origin.x = self.topBorder.frame.size.width-(0.5);
    self.rightBorder.frame = rightRect;
    
    CGRect bottomRect = self.bottomBorder.frame;
    bottomRect.origin.y = self.rightBorder.frame.size.height-width*0.5;
    self.bottomBorder.frame = bottomRect;
    
    CGRect topRect = self.topBorder.frame;
    topRect.origin.y = width*0.5;
    self.topBorder.frame = topRect;
    
    self.arrowLeftHalf.lineWidth = width;
    self.arrowRightHalf.lineWidth = width;
    
}

// Override background color to keep button clear, then set background shape to the color
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.backgroundShape.fillColor = backgroundColor.CGColor;
}

#pragma mark - TableView Methods

- (void)setDataSource:(NSArray *)tableArray isCheckList:(BOOL)isCheckList {
    
    if (self.tableView == nil) {
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 0.0) style:UITableViewStylePlain];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorColor = [UIColor whiteColor];
        if (isCheckList) {
            self.isCheckList = true;
            self.tableView.allowsMultipleSelection = true;
        }
        [self addSubview:self.tableView];
    }
    
    self.dataArray = tableArray;
    self.tableView.separatorColor = self.theArrowColor;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.dataArrayCount = [tableArray count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.dataArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
    }
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    /*
     NSIndexPath* selection = [tableView indexPathForSelectedRow];
     if (selection && selection.row == indexPath.row) {
     cell.accessoryType = UITableViewCellAccessoryCheckmark;
     } else {
     cell.accessoryType = UITableViewCellAccessoryNone;
     }
     */
    
    if (self.isCheckList) {
        if([[tableView indexPathsForSelectedRows] containsObject:indexPath]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    [cell setSeparatorInset:UIEdgeInsetsZero];
    cell.tintColor = self.theArrowColor;
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.textColor = self.theArrowColor;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isCheckList) {
        /*
        self.numSelections += 1;
        if (self.numSelections > 1) {
            NSString *titleString = [NSString stringWithFormat:@"%d Selections",self.numSelections];
            [self setTitle:titleString forState:UIControlStateNormal];
        } else {
            [self setTitle:@"1 Selection" forState:UIControlStateNormal];
        }
         */
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        NSString *string = [self.dataArray objectAtIndex:indexPath.row];
        [self setTitle:string forState:UIControlStateNormal];
        [self animateButton];
    }
    if ([delegate respondsToSelector:@selector(dropDownButton:selectedButtonAtIndex:)]) {
        [delegate dropDownButton:self selectedButtonAtIndex:indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isCheckList) {
        /*
        self.numSelections -= 1;
        
        if (self.numSelections > 1) {
            NSString *titleString = [NSString stringWithFormat:@"%d Selections",self.numSelections];
            [self setTitle:titleString forState:UIControlStateNormal];
        } else if (self.numSelections == 1) {
            [self setTitle:@"1 Selection" forState:UIControlStateNormal];
        } else {
            [self setTitle:@"No Selections" forState:UIControlStateNormal];
        }
         */
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if ([delegate respondsToSelector:@selector(dropDownButton:deselectedButtonAtIndex:)]) {
            [delegate dropDownButton:self deselectedButtonAtIndex:indexPath.row];
        }
    }
}

//allows taps to go through to the tableview
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([touch.view isDescendantOfView:self.tableView]) {
        return NO;
    }
    return YES;
}


#pragma mark - Helper Methods

-(CAShapeLayer *)drawLineFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint withColor:(UIColor *)color ofWidth:(CGFloat)lineWidth{
    
    CAShapeLayer *lineShape = [CAShapeLayer layer];
    CGMutablePathRef linePath = CGPathCreateMutable();
    
    lineShape.lineWidth = lineWidth;
    lineShape.strokeColor = color.CGColor;
    
    CGPathMoveToPoint(linePath, nil, fromPoint.x, fromPoint.y);
    CGPathAddLineToPoint(linePath, nil, toPoint.x, toPoint.y);
    
    lineShape.path = linePath;
    CGPathRelease(linePath);
    
    return lineShape;
    
}

@end

