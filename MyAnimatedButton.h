//
//  MyAnimatedButton.h
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

#import <UIKit/UIKit.h>

@class MyAnimatedButton;

@protocol MyAnimatedButtonDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;

@optional
- (void)myAnimatedButtonDidAnimate:(MyAnimatedButton *)myAnimatedButton;
- (void)myAnimatedButton:(MyAnimatedButton *)button selectedButtonAtIndex:(NSInteger)index;
- (void)myAnimatedButton:(MyAnimatedButton *)button deselectedButtonAtIndex:(NSInteger)index;

@end

@interface MyAnimatedButton : UIButton <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic) float amountOfDrops;
@property (nonatomic) float borderWidth;
@property (nonatomic) float arrowWidth;
@property (nonatomic, readonly) NSInteger dataArrayCount;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic) BOOL isCheckList;
@property (nonatomic, readonly) BOOL isOpen;
@property (nonatomic, readonly) NSArray *dataArray;

@property (nonatomic, assign) id  delegate;

- (void)closeWhenTapOff;
- (void)setBorderColor:(UIColor *)color;
- (void)setArrowColor:(UIColor *)color;
- (void)setBorderAndArrowColor:(UIColor *)color ofWidth:(float)width;
- (void)setDataSource:(NSArray *)tableArray isCheckList:(BOOL)isCheckList;

@end
