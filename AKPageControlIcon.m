//
//  AKPageControlIcon.m
//  AKListScrollView
//
//  Created by Ken M. Haggerty on 4/26/13.
//  Copyright (c) 2013 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AKPageControlIcon.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@interface AKPageControlIcon ()
- (void)setup;
- (void)teardown;
@end

@implementation AKPageControlIcon

#pragma mark - // SETTERS AND GETTERS //

@synthesize pageIconWidth = _pageIconWidth;
@synthesize pageIconStrokeWidth = _pageIconStrokeWidth;
@synthesize pageIconColor = _pageIconColor;
@synthesize isFilled = _isFilled;

- (void)setPageIconWidth:(CGFloat)pageIconWidth
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:@[AKD_UI] message:nil];
    
    if (pageIconWidth == _pageIconWidth) return;
    
    _pageIconWidth = pageIconWidth;
    [self setNeedsDisplay];
}

- (void)setPageIconStrokeWidth:(CGFloat)pageIconStrokeWidth
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:@[AKD_UI] message:nil];
    
    if (pageIconStrokeWidth == _pageIconStrokeWidth) return;
    
    _pageIconStrokeWidth = pageIconStrokeWidth;
    [self setNeedsDisplay];
}

- (void)setPageIconColor:(UIColor *)pageIconColor
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:@[AKD_UI] message:nil];
    
    if ([pageIconColor isEqual:_pageIconColor] || (!pageIconColor && !_pageIconColor)) return;
    
    _pageIconColor = pageIconColor;
    [self setNeedsDisplay];
}

- (void)setIsFilled:(BOOL)isFilled
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:@[AKD_UI] message:nil];
    
    if (isFilled == _isFilled) return;
    
    _isFilled = isFilled;
    [self setNeedsDisplay];
}

#pragma mark - // INITS AND LOADS //

- (id)initWithFrame:(CGRect)frame
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_UI] message:nil];
    
    self = [super initWithFrame:frame];
    if (!self)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeCritical methodType:AKMethodTypeSetup customCategories:@[AKD_UI] message:[NSString stringWithFormat:@"Could not initialize %@", stringFromVariable(self)]];
        return nil;
    }
    [self setup];
    return self;
}

- (void)awakeFromNib
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_UI] message:nil];
    
    [super awakeFromNib];
    [self setup];
}

- (void)dealloc
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_UI] message:nil];
    
    [self teardown];
}

#pragma mark - // PUBLIC METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)drawRect:(CGRect)rect
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_UI] message:nil];
    
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(myContext, NO);
    CGContextSetFillColorWithColor(myContext, [UIColor clearColor].CGColor);
    CGContextFillRect(myContext, self.bounds);
    CGRect pageIconRect = CGRectMake((self.bounds.size.width-self.pageIconWidth)/2.0, (self.bounds.size.height-self.pageIconWidth)/2.0, self.pageIconWidth, self.pageIconWidth);
    if (self.isFilled) CGContextSetFillColorWithColor(myContext, self.pageIconColor.CGColor);
    else CGContextSetFillColorWithColor(myContext, [UIColor clearColor].CGColor);
    CGContextFillRect(myContext, pageIconRect);
    CGContextSetStrokeColorWithColor(myContext, self.pageIconColor.CGColor);
    CGContextStrokeRectWithWidth(myContext, pageIconRect, self.pageIconStrokeWidth);
}

#pragma mark - // PRIVATE METHODS //

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_UI] message:nil];
    
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_UI] message:nil];
}

@end