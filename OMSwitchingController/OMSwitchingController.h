//  Copyright (c) 2015 Outware Mobile. All rights reserved.

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <UIKit/UIKit.h>

//! Project version number for OMSwitchingController.
FOUNDATION_EXPORT double OMSwitchingControllerVersionNumber;

//! Project version string for OMSwitchingController.
FOUNDATION_EXPORT const unsigned char OMSwitchingControllerVersionString[];

NS_ASSUME_NONNULL_BEGIN

@interface OMSwitchingController : UIViewController

/// Creates a switching controller that will display the latest view controller sent on the view
/// controllers signal.
///
/// The viewControllers signal will be throttled by the duration of the switching animation to
/// ensure that the correct view controller is shown.
- (instancetype)initWithViewControllers:(RACSignal *)viewControllers NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
