//
//  AKPageControl.m
//  AKListScrollView
//
//  Created by Ken M. Haggerty on 4/15/13.
//  Copyright (c) 2013 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Private) //

//  •  self.subviewForIcons snugly holds all icons and has struts and springs to keep it centered appropriately despite its own size
// [_] Figure out why drawing square is fuzzy
// [_] Make bigger icons

#pragma mark - // IMPORTS (Private) //

#import "AKPageControl.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import "AKPageControlIcon.h"
#import "CPAnimationStep.h"
#import "CPAnimationSequence.h"
#import "CPAnimationProgram.h"

#pragma mark - // DEFINITIONS (Private) //

#define ICON_DIMENSION 10.0
#define PAGE_ICON_WIDTH 6.0
#define ICON_SPACING 16.0
#define PAGE_ICON_STROKE_WIDTH 1.0
#define DEFAULT_COLOR [UIColor whiteColor]

@interface AKPageControl ()
@property (nonatomic, strong) UIView *subviewForIcons;
@property (nonatomic, strong) NSMutableOrderedSet *orderedSetOfIcons;
@property (nonatomic, strong) UIImageView *prefixImageView;
@property (nonatomic, strong) UIImageView *suffixImageView;

// GENERAL //

- (void)setup;
- (void)teardown;

// ANIMATIONS //

- (void)fadeInOrderedIconsInTime:(NSTimeInterval)secondsPerIcon startIndex:(NSUInteger)startIndex endIndex:(NSUInteger)endIndex;
- (void)fadeOutAndRemoveOrderedIconsInTime:(NSTimeInterval)secondsPerIcon startIndex:(NSUInteger)startIndex endIndex:(NSUInteger)endIndex;

@end

@implementation AKPageControl

#pragma mark - // SETTERS AND GETTERS //

@synthesize numberOfPages = _numberOfPages;
@synthesize currentPage = _currentPage;
@synthesize isVertical = _isVertical;
@synthesize color = _color;
@synthesize prefixIcon = _prefixIcon;
@synthesize suffixIcon = _suffixIcon;
@synthesize prefixIsVisible = _prefixIsVisible;
@synthesize suffixIsVisible = _suffixIsVisible;

@synthesize subviewForIcons = _subviewForIcons;
@synthesize orderedSetOfIcons = _orderedSetOfIcons;
@synthesize prefixImageView = _prefixImageView;
@synthesize suffixImageView = _suffixImageView;

- (void)setNumberOfPages:(NSUInteger)numberOfPages
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:@[AKD_UI] message:nil];
    
    if (numberOfPages == _numberOfPages) return;
    
    NSInteger addedPages = numberOfPages-_numberOfPages;
    if (addedPages)
    {
        [self insertPagesAtIndices:NSMakeRange(_numberOfPages, addedPages) inTime:0.0];
    }
    else
    {
        [self removePagesAtIndices:NSMakeRange(_numberOfPages+addedPages, -1*addedPages) inTime:0.0];
    }
    _numberOfPages = numberOfPages;
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:@[AKD_UI] message:nil];
    
    NSInteger minimumPage = 0;
    if (self.prefixIsVisible) minimumPage--;
    NSInteger maximumPage = self.numberOfPages-1;
    if (self.suffixIsVisible) maximumPage++;
    
    if ((currentPage < minimumPage) || (currentPage > maximumPage)) return;
    
    UIView *oldIcon = [self.orderedSetOfIcons objectAtIndex:_currentPage-minimumPage];
    UIView *newIcon = [self.orderedSetOfIcons objectAtIndex:currentPage-minimumPage];
    if ([oldIcon isKindOfClass:[AKPageControlIcon class]]) [((AKPageControlIcon *)oldIcon) setIsFilled:NO];
    if ([newIcon isKindOfClass:[AKPageControlIcon class]]) [((AKPageControlIcon *)newIcon) setIsFilled:YES];
    _currentPage = currentPage;
}

- (void)setIsVertical:(BOOL)isVertical
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:@[AKD_UI] message:nil];
    
    if (isVertical == _isVertical) return;
    
    _isVertical = isVertical;
    [self setNeedsDisplay];
}

- (UIColor *)color
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_UI] message:nil];
    
    if (!_color)  _color = DEFAULT_COLOR;
    return _color;
}

- (void)setPrefixIcon:(UIImage *)prefixIcon
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:@[AKD_UI] message:nil];
    
    _prefixIcon = prefixIcon;
    [self.prefixImageView setImage:prefixIcon];
}

- (void)setSuffixIcon:(UIImage *)suffixIcon
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:@[AKD_UI] message:nil];
    
    _suffixIcon = suffixIcon;
    [self.suffixImageView setImage:suffixIcon];
}

- (void)setPrefixIsVisible:(BOOL)prefixIsVisible
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:@[AKD_UI] message:nil];
    
    if (prefixIsVisible == _prefixIsVisible) return;
    
    _prefixIsVisible = prefixIsVisible;
    [self setNeedsDisplay];
}

- (void)setSuffixIsVisible:(BOOL)suffixIsVisible
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:@[AKD_UI] message:nil];
    
    if (suffixIsVisible == _suffixIsVisible) return;
    
    _suffixIsVisible = suffixIsVisible;
    [self setNeedsDisplay];
}

- (UIView *)subviewForIcons
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_UI] message:nil];
    
    if (!_subviewForIcons)
    {
        _subviewForIcons = [[UIView alloc] init];
        int additional = 0;
        if (self.prefixIsVisible) additional++;
        if (self.suffixIsVisible) additional++;
        CGFloat frameLong = ICON_SPACING*(self.numberOfPages+additional);
        CGFloat frameShort = ICON_DIMENSION;
        if (self.isVertical)
        {
            [_subviewForIcons setFrame:CGRectMake((self.bounds.size.width-frameShort)/2.0, (self.bounds.size.height-frameLong)/2.0, frameShort, frameLong)];
        }
        else
        {
            [_subviewForIcons setFrame:CGRectMake((self.bounds.size.width-frameLong)/2.0, (self.bounds.size.height-frameShort)/2.0, frameLong, frameShort)];
        }
        [_subviewForIcons setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
        if (![self.subviews containsObject:_subviewForIcons])
        {
            [self addSubview:_subviewForIcons];
        }
        [_subviewForIcons setBackgroundColor:[UIColor purpleColor]];
    }
    return _subviewForIcons;
}

- (NSMutableOrderedSet *)orderedSetOfIcons
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_UI] message:nil];
    
    if (!_orderedSetOfIcons)
    {
        _orderedSetOfIcons = [[NSMutableOrderedSet alloc] initWithObjects:self.prefixImageView, self.suffixImageView, nil];
    }
    return _orderedSetOfIcons;
}

- (UIImageView *)prefixImageView
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_UI] message:nil];
    
    if (!_prefixImageView)
    {
        _prefixImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, ICON_DIMENSION, ICON_DIMENSION)];
        [_prefixImageView setContentMode:UIViewContentModeScaleAspectFit];
        [_prefixImageView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin)];
        [_prefixImageView setImage:self.prefixIcon];
        [_prefixImageView setAlpha:1.0];
    }
    return _prefixImageView;
}

- (UIImageView *)suffixImageView
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_UI] message:nil];
    
    if (!_suffixImageView)
    {
        _suffixImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, ICON_DIMENSION, ICON_DIMENSION)];
        [_suffixImageView setContentMode:UIViewContentModeScaleAspectFit];
        [_suffixImageView setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin)];
        [_suffixImageView setImage:self.suffixIcon];
        [_suffixImageView setAlpha:1.0];
    }
    return _suffixImageView;
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

- (void)insertPageAtIndex:(NSUInteger)index inTime:(NSTimeInterval)seconds
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_UI] message:nil];
    
    [self insertPagesAtIndices:NSMakeRange(index, 1) inTime:seconds];
}

- (void)insertPagesAtIndices:(NSRange)range inTime:(NSTimeInterval)seconds
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_UI] message:nil];
    
    if (range.location > self.numberOfPages)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified customCategories:@[AKD_UI] message:[NSString stringWithFormat:@"Could not insert %lu pages at index %lu", range.length, range.location]];
        return;
    }
    
    // CONSTANTS //
    
    int prefixConstant = 0;
    if (self.prefixIsVisible) prefixConstant++;
    int suffixConstant = 0;
    if (self.suffixIsVisible) suffixConstant++;
    
    // ADD NEW PAGE ICONS TO ORDERED SET AND SUBVIEW //
    
    for (int i = 0; i < range.length; i++)
    {
        AKPageControlIcon *newPageIcon = [[AKPageControlIcon alloc] initWithFrame:CGRectMake(0.0, 0.0, ICON_DIMENSION, ICON_DIMENSION)];
        [newPageIcon setPageIconWidth:PAGE_ICON_WIDTH];
        [newPageIcon setPageIconStrokeWidth:PAGE_ICON_STROKE_WIDTH];
        [newPageIcon setPageIconColor:[UIColor whiteColor]];
        [newPageIcon setIsFilled:NO];
        [newPageIcon setAlpha:0.0];
        if (self.isVertical) [newPageIcon setCenter:CGPointMake(self.subviewForIcons.bounds.size.width/2.0, (0.5+prefixConstant+range.location+i)*ICON_SPACING)];
        else [newPageIcon setCenter:CGPointMake((0.5+prefixConstant+range.location+i)*ICON_SPACING, self.subviewForIcons.bounds.size.height/2.0)];
        [self.subviewForIcons addSubview:newPageIcon];
        [self.orderedSetOfIcons insertObject:newPageIcon atIndex:prefixConstant+range.location+i];
    }
    
    // DISPLACE EXISTING PAGE ICONS ANIMATIONS (CPAnimationStep) //
    
    CPAnimationStep *displacePageIconsAnimation = [CPAnimationStep after:0.0 for:seconds animate:^{
        for (int i = prefixConstant+(int)range.location+(int)range.length; i < self.orderedSetOfIcons.count; i++)
        {
            if (self.isVertical) [[self.orderedSetOfIcons objectAtIndex:i] setCenter:CGPointMake(self.subviewForIcons.bounds.size.width/2.0, (0.5+i)*ICON_SPACING)];
            else [[self.orderedSetOfIcons objectAtIndex:i] setCenter:CGPointMake((0.5+i)*ICON_SPACING, self.subviewForIcons.bounds.size.height/2.0)];
        }
    }];
    
    // RESIZE self.subviewForIcons AND RECENTER ANIMATION (CPAnimationStep) //
    
    CGFloat newLengthForAKPageControl = (self.orderedSetOfIcons.count)*ICON_SPACING;
    CPAnimationStep *resizeSubviewForIconsAnimation = [CPAnimationStep after:0.0 for:seconds animate:^{
        if (self.isVertical) [self.subviewForIcons setFrame:CGRectMake(self.subviewForIcons.frame.origin.x, (self.bounds.size.height-newLengthForAKPageControl)/2.0, self.subviewForIcons.bounds.size.width, newLengthForAKPageControl)];
        else [self.subviewForIcons setFrame:CGRectMake((self.bounds.size.width-newLengthForAKPageControl)/2.0, self.frame.origin.y, newLengthForAKPageControl, self.subviewForIcons.bounds.size.height)];
    }];
    
    // ANIMATE //
    
    [[CPAnimationSequence sequenceWithSteps:displacePageIconsAnimation, nil] runAnimated:YES];
    [[CPAnimationSequence sequenceWithSteps:resizeSubviewForIconsAnimation, nil] runAnimated:YES];
    [self fadeInOrderedIconsInTime:seconds/range.length startIndex:prefixConstant+range.location endIndex:prefixConstant+range.location+range.length-1];
    
    if (self.currentPage >= range.location) _currentPage = self.currentPage+range.length;
}

- (void)removePageAtIndex:(NSUInteger)index inTime:(NSTimeInterval)seconds
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_UI] message:nil];
    
    [self removePagesAtIndices:NSMakeRange(index, 1) inTime:seconds];
}

- (void)removePagesAtIndices:(NSRange)range inTime:(NSTimeInterval)seconds
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_UI] message:nil];
    
    if (range.location+range.length-1 < self.numberOfPages)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified customCategories:@[AKD_UI] message:[NSString stringWithFormat:@"Could not remove %lu pages at index %lu", range.length, range.location]];
        return;
    }
    
    // CONSTANTS //
    
    int prefixConstant = 0;
    if (self.prefixIsVisible) prefixConstant++;
    int suffixConstant = 0;
    if (self.suffixIsVisible) suffixConstant++;
    
    // DISPLACE EXISTING PAGE ICONS ANIMATIONS (CPAnimationStep) //
    
    CPAnimationStep *displacePageIconsAnimation = [CPAnimationStep after:0.0 for:seconds animate:^{
        for (int i = prefixConstant+(int)range.location+(int)range.length; i < self.orderedSetOfIcons.count; i++)
        {
            if (self.isVertical) [[self.orderedSetOfIcons objectAtIndex:i] setCenter:CGPointMake(self.subviewForIcons.bounds.size.width/2.0, (0.5+i-range.length)*ICON_SPACING)];
            else [[self.orderedSetOfIcons objectAtIndex:i] setCenter:CGPointMake((0.5+i-range.length)*ICON_SPACING, self.subviewForIcons.bounds.size.height/2.0)];
        }
    }];
    
    // RESIZE self.subviewForIcons AND RECENTER ANIMATION (CPAnimationStep) //
    
    CGFloat newLengthForAKPageControl = (prefixConstant+self.numberOfPages-range.length+suffixConstant)*ICON_SPACING;
    CPAnimationStep *resizeSubviewForIconsAnimation = [CPAnimationStep after:0.0 for:seconds animate:^{
        if (self.isVertical) [self.subviewForIcons setFrame:CGRectMake(self.subviewForIcons.frame.origin.x, (self.bounds.size.height-newLengthForAKPageControl)/2.0, self.subviewForIcons.bounds.size.width, newLengthForAKPageControl)];
        else [self.subviewForIcons setFrame:CGRectMake((self.bounds.size.width-newLengthForAKPageControl)/2.0, self.frame.origin.y, newLengthForAKPageControl, self.subviewForIcons.bounds.size.height)];
    }];
    
    // ANIMATE //
    
    [[CPAnimationSequence sequenceWithSteps:displacePageIconsAnimation, nil] runAnimated:YES];
    [[CPAnimationSequence sequenceWithSteps:resizeSubviewForIconsAnimation, nil] runAnimated:YES];
    [self fadeOutAndRemoveOrderedIconsInTime:seconds/(range.length+1) startIndex:prefixConstant+range.location+range.length-1 endIndex:prefixConstant+range.location];
    
    if (self.currentPage >= range.location+range.length) _currentPage = self.currentPage-range.length;
}

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)layoutSubviews
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_UI] message:nil];
    
    [super layoutSubviews];
    
    // SUBVIEW SIZING //
    
    CGFloat lengthForAKPageControl = self.orderedSetOfIcons.count*ICON_SPACING;
    UIView *iconToInsert;
    if (self.isVertical)
    {
        // VERTICAL LAYOUT //
        
        [self.subviewForIcons setFrame:CGRectMake((self.bounds.size.width-ICON_DIMENSION)/2.0, (self.bounds.size.height-lengthForAKPageControl)/2.0, ICON_DIMENSION, lengthForAKPageControl)];
        for (int i = 0; i < self.orderedSetOfIcons.count; i++)
        {
            iconToInsert = [self.orderedSetOfIcons objectAtIndex:i];
            [iconToInsert setCenter:CGPointMake(self.subviewForIcons.bounds.size.width/2.0, (0.5+i)*ICON_SPACING)];
            if (![self.subviewForIcons.subviews containsObject:iconToInsert])
            {
                [self.subviewForIcons addSubview:iconToInsert];
            }
        }
    }
    else
    {
        // HORIZONTAL LAYOUT //
        
        [self.subviewForIcons setFrame:CGRectMake((self.bounds.size.width-lengthForAKPageControl)/2.0, (self.bounds.size.height-ICON_DIMENSION)/2.0, lengthForAKPageControl, ICON_DIMENSION)];
        for (int i = 0; i < self.orderedSetOfIcons.count; i++)
        {
            iconToInsert = [self.orderedSetOfIcons objectAtIndex:i];
            [iconToInsert setCenter:CGPointMake((0.5+i)*ICON_SPACING, self.subviewForIcons.bounds.size.height/2.0)];
            if (![self.subviewForIcons.subviews containsObject:iconToInsert])
            {
                [self.subviewForIcons addSubview:iconToInsert];
            }
        }
    }
}

#pragma mark - // PRIVATE METHODS (General) //

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_UI] message:nil];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_UI] message:nil];
}

#pragma mark - // PRIVATE METHODS (Animations) //

- (void)fadeInOrderedIconsInTime:(NSTimeInterval)secondsPerIcon startIndex:(NSUInteger)startIndex endIndex:(NSUInteger)endIndex
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_UI] message:nil];
    
    if (endIndex >= self.orderedSetOfIcons.count)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified customCategories:@[AKD_UI] message:[NSString stringWithFormat:@"Invalid %@", stringFromVariable(endIndex)]];
        return;
    }
    
    int directionMultiple = 1;
    if (startIndex > endIndex) directionMultiple = -1;
    [UIView animateWithDuration:secondsPerIcon animations:^{
        [[self.orderedSetOfIcons objectAtIndex:startIndex] setAlpha:1.0];
    } completion:^(BOOL finished){
        if (!finished)
        {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified customCategories:@[AKD_UI] message:[NSString stringWithFormat:@"Could not complete animation"]];
            return;
        }
        
        if (directionMultiple*(startIndex+directionMultiple) > directionMultiple*endIndex)
        {
            int fixAdjust = 0;
            if (self.prefixIsVisible) fixAdjust++;
            if (self.suffixIsVisible) fixAdjust++;
            _numberOfPages = self.orderedSetOfIcons.count-fixAdjust;
            return;
        }
        
        [self fadeInOrderedIconsInTime:secondsPerIcon startIndex:startIndex+directionMultiple endIndex:endIndex];
    }];
}

- (void)fadeOutAndRemoveOrderedIconsInTime:(NSTimeInterval)secondsPerIcon startIndex:(NSUInteger)startIndex endIndex:(NSUInteger)endIndex
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_UI] message:nil];
    
    if (endIndex >= self.orderedSetOfIcons.count)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified customCategories:@[AKD_UI] message:[NSString stringWithFormat:@"Invalid %@", stringFromVariable(endIndex)]];
        return;
    }
    
    int directionMultiple = 1;
    if (startIndex > endIndex) directionMultiple = -1;
    [UIView animateWithDuration:secondsPerIcon animations:^{
        [[self.orderedSetOfIcons objectAtIndex:startIndex] setAlpha:0.0];
    } completion:^(BOOL finished){
        if (!finished)
        {
            [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified customCategories:@[AKD_UI] message:[NSString stringWithFormat:@"Could not complete animation"]];
            return;
        }
        
        [[self.orderedSetOfIcons objectAtIndex:startIndex] removeFromSuperview];
        [self.orderedSetOfIcons removeObjectAtIndex:startIndex];
        if (directionMultiple*(startIndex+directionMultiple) > directionMultiple*endIndex)
        {
            int fixAdjust = 0;
            if (self.prefixIsVisible) fixAdjust++;
            if (self.suffixIsVisible) fixAdjust++;
            _numberOfPages = self.orderedSetOfIcons.count-fixAdjust;
            return;
        }
        
        [self fadeOutAndRemoveOrderedIconsInTime:secondsPerIcon startIndex:startIndex+(directionMultiple-1)/2 endIndex:endIndex-1*(directionMultiple+1)/2];
    }];
}

@end