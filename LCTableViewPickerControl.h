//
//  LCTableViewPickerControl.h
//  InsurancePig
//
//  Created by Leo Chang on 10/21/13.
//  Copyright (c) 2013 Good-idea Consunting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPickerControlWidth 320
#define kPickerControlAgeHeight 300
#define kAnimationDuration 0.4
//#define kPickerTitleBarColor [UIColor colorWithRed:89/255.0f green:196/255.0f blue:90/255.0f alpha:1.0f]
#define kPickerTitleBarColor [UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f]

typedef void (^LCPickerCallback) (id sender, id item);

@class LCTableViewPickerControl;
@protocol LCItemPickerDelegate <NSObject>

- (void)selectControl:(LCTableViewPickerControl*)view didSelectWithItem:(id)item;
- (void)selectControl:(LCTableViewPickerControl *)view didCancelWithItem:(id)item;

@end


@interface LCTableViewPickerControl : UIView <UITableViewDataSource, UITableViewDelegate>

@property (weak) id <LCItemPickerDelegate> delegate;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, strong) NSString *key;
@property (copy, readwrite) LCPickerCallback callback;

- (id)initWithFrame:(CGRect)frame title:(NSString*)title value:(id)value items:(NSArray*)array offset:(CGPoint)offset;

- (void)showInView:(UIView*)view;
- (void)showInView:(UIView*)view block:(LCPickerCallback)callback;
- (void)dismiss;

@end
