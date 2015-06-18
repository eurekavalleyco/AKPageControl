//
//  AKPageControlIcon.h
//  AKListScrollView
//
//  Created by Ken M. Haggerty on 4/26/13.
//  Copyright (c) 2013 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <UIKit/UIKit.h>

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface AKPageControlIcon : UIView
@property (nonatomic) CGFloat pageIconWidth;
@property (nonatomic) CGFloat pageIconStrokeWidth;
@property (nonatomic, strong) UIColor *pageIconColor;
@property (nonatomic) BOOL isFilled;
@end