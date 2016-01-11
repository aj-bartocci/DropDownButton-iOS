//
//  ObjCImplementation.m
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

#import "ObjCImplementation.h"

@interface ObjCImplementation()

@property (nonatomic, retain) DropDownButton *dropButton;
@property (nonatomic, retain) UILabel *dropLabel;
@property (nonatomic, retain) DropDownButton *checkButton;
@property (nonatomic, retain) UILabel *checkLabel;

@end

@implementation ObjCImplementation

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil) {
        return nil;
    }
    return self;
}

- (void)createDropDownButtons {
    
    //DISCLAIMER: I am hard coding a lot of values which you shouldn't do. This is only meant
    // to be a demonstration of the button functionality. This is not how I actually program.
    
    UIColor *mainColor = [UIColor colorWithRed:253.0/255.0 green:227.0/255.0 blue:167.0/255.0 alpha:1.0];
    self.backgroundColor = mainColor;
    
    // Sample array to use for drop down objects
    NSArray *dataArray = @[@"object 1",@"object 2",@"object 3",@"object 4",@"object 5",@"and so on..."];
    
    // TapGesture for when user taps the background in order to close the button
    // When using tap gestures they must ignore touches on the animated button (See Readme)
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleBackgroundTap)];
    tapGest.delegate = self;
    [self addGestureRecognizer:tapGest];
    
    // UILabel for demonstrative purposes
    _dropLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width/2-150, 105, 300, 40)];
    _dropLabel.text = @"Nothing Selected Yet";
    _dropLabel.textAlignment = NSTextAlignmentCenter;
    _dropLabel.backgroundColor = [UIColor orangeColor];
    _dropLabel.textColor = mainColor;
    
    [self addSubview:_dropLabel];
    
    // Creates dropdown button using obj-c files (Allowing 1 selection)
    _dropButton = [[DropDownButton alloc]initWithFrame:CGRectMake(self.frame.size.width/2-100, 150, 200, 40)];
    _dropButton.delegate = self;
    [_dropButton setBorderColor:[UIColor orangeColor] ofWidth:2.0];
    [_dropButton setArrowColor:mainColor ofWidth:2.0];
    [_dropButton setTitle:@"Drop Button" forState:UIControlStateNormal];
    [_dropButton setTitleColor:mainColor forState:UIControlStateNormal];
    [_dropButton setBackgroundColor:[UIColor orangeColor]];
    _dropButton.amountOfDrops = 4;
    [_dropButton setDataSource:dataArray isCheckList:false];
    
    [self addSubview:_dropButton];
    
    UILabel *objCLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width/2-100, 210, 200, 40)];
    objCLabel.text = @"Objective-C";
    objCLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22];
    objCLabel.textAlignment = NSTextAlignmentCenter;
    objCLabel.textColor = [UIColor orangeColor];
    
    [self insertSubview:objCLabel belowSubview:_dropButton];
    
    // UILabel for demonstrative purposes
    _checkLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width/2-150, 270, 300, 40)];
    _checkLabel.text = @"Nothing Selected Yet";
    _checkLabel.textAlignment = NSTextAlignmentCenter;
    _checkLabel.layer.borderColor = [UIColor orangeColor].CGColor;
    _checkLabel.layer.borderWidth = 2.0;
    _checkLabel.textColor = [UIColor orangeColor];
    _checkLabel.numberOfLines = 1;
    _checkLabel.minimumScaleFactor = 0.5;
    _checkLabel.adjustsFontSizeToFitWidth = true;
    
    [self insertSubview:_checkLabel belowSubview:_dropButton];
    
    // Creates dropdown button using obj-c files (Allowing multiple selections)
    _checkButton = [[DropDownButton alloc]initWithFrame:CGRectMake(_dropButton.frame.origin.x, 315, 200, 40)];
    _checkButton.delegate = self;
    [_checkButton setBorderAndArrowColor:[UIColor orangeColor] ofWidth:2.0];
    [_checkButton setTitle:@"Checklist" forState:UIControlStateNormal];
    [_checkButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [_checkButton setBackgroundColor:[UIColor clearColor]];
    _checkButton.amountOfDrops = 4;
    _checkButton.animationDuration = 0.25;
    [_checkButton setDataSource:dataArray isCheckList:true];
    
    [self insertSubview:_checkButton belowSubview:_dropButton];

}

// Delegate call returns index of selected object to check against array
- (void)dropDownButton:(DropDownButton *)button selectedButtonAtIndex:(NSInteger)index {
    if ([button isEqual:_dropButton]) {
        _dropLabel.text = button.dataArray[index];
    } else if ([button isEqual:_checkButton]) {
        if ([_checkLabel.text isEqualToString:@"Nothing Selected Yet"]) {
            NSString *string = [NSString stringWithFormat:@"Selected: %@",button.dataArray[index]];
            _checkLabel.text = string;
        } else {
            NSString *string = [NSString stringWithFormat:@"%@ %@",_checkLabel.text,button.dataArray[index]];
            _checkLabel.text = string;
        }
    }
}

// Delegate call returns index of deselected object to check against array
- (void)dropDownButton:(DropDownButton *)button deselectedButtonAtIndex:(NSInteger)index    {
    if ([button isEqual:_checkButton]) {
        NSString *currentSelection = _checkLabel.text;
        NSString *eraseSelection = [NSString stringWithFormat:@" %@",button.dataArray[index]];
        NSString *finalSelection = [currentSelection stringByReplacingOccurrencesOfString:eraseSelection withString:@""];
        if ([finalSelection isEqualToString:@"Selected:"]) {
            finalSelection = @"Nothing Selected Yet";
        }
        _checkLabel.text = finalSelection;
    }
}

// UITapGestureRecognizer used to close the button when user taps away from it
- (void)handleBackgroundTap {
    [_dropButton closeWhenTapOff];
    [_checkButton closeWhenTapOff];
}

// Must ignore taps to the drop down button to let dropdown selection occur
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([touch.view isDescendantOfView:_dropButton]) {
        // Close any other buttons that are open
        [_checkButton closeWhenTapOff];
        return false;
    }
    if ([touch.view isDescendantOfView:_checkButton]) {
        // Close any other buttons that are open
        [_dropButton closeWhenTapOff];
        return false;
    }

    return true;
}

@end
