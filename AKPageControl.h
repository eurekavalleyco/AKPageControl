//
//  AKPageControl.h
//  AKListScrollView
//
//  Created by Ken M. Haggerty on 4/15/13.
//  Copyright (c) 2013 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Public) //

//     AKPageControl allows for the use of a custom UIImage for page icons in either a horizontal or vertical format,
//     along with a custom UIImage for a prefix and a custom UIImage for a suffix, both of which may be hidden.
//
//     The following public properties can be read and set:
//     
//     • isVertical   (instantaneous update)
//     • prefixIsVisible    (instantaneous update)
//     • suffixIsVisible    (instantaneous update)
//
//     The following methods are public:
//
//     - (void)setPageCount                                                 (instantaneous update)      
//     - (void)setCurrentPage                                               (instantaneous update)      
//     - (void)setImageForPrefix:inverse:                                   (instantaneous update)      If no image is set, displayed image will be blank
//     - (void)setImageForSuffix:inverse:                                   (instantaneous update)      If no image is set, displayed image will be blank
//     - (BOOL)addPageAtIndex:(NSUInteger)index inTime:(float)seconds       (animated update)           
//     - (BOOL)addPagesAtIndices:(NSRange)range inTime:(float)seconds       (animated update)           
//     - (BOOL)removePageAtIndex:(NSUInteger)index inTime:(float)seconds    (animated update)           
//     - (BOOL)removePagesAtIndices:(NSRange)range inTime:(float)seconds    (animated update)           
//
//     AKPageControl should be used only to *display* page state and not relied upon to divulge page state.
//
//     To set the current page to the prefix, use -1.
//     To set the current page to the suffix, use pageCount+1.

#pragma mark - // IMPORTS (Public) //

#import <UIKit/UIKit.h>

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

#define ICON_SEARCH [UIImage imageNamed:@"search.png"]
#define ICON_ADD [UIImage imageNamed:@"add.png"]

@interface AKPageControl : UIView
@property (nonatomic) NSUInteger numberOfPages;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) BOOL isVertical;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIImage *prefixIcon;
@property (nonatomic, strong) UIImage *suffixIcon;
@property (nonatomic) BOOL prefixIsVisible;
@property (nonatomic) BOOL suffixIsVisible;
- (void)insertPageAtIndex:(NSUInteger)index inTime:(NSTimeInterval)seconds;
- (void)insertPagesAtIndices:(NSRange)range inTime:(NSTimeInterval)seconds;
- (void)removePageAtIndex:(NSUInteger)index inTime:(NSTimeInterval)seconds;
- (void)removePagesAtIndices:(NSRange)range inTime:(NSTimeInterval)seconds;
@end