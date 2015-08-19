//  Copyright (c) 2015 Outware Mobile. All rights reserved.

#import "OMSwitchingController.h"

static const NSTimeInterval OMSwitchingAnimationDuration = 0.5;

@interface OMSwitchingController ()
@property (nonatomic, readonly) RACSignal *viewControllersSignal;
@property (nonatomic) UIViewController *visibleViewController;
@property (nonatomic, getter=isAnimating) BOOL animating;
@end

@implementation OMSwitchingController

#pragma mark Lifecycle

- (instancetype)initWithViewControllers:(RACSignal *)viewControllers {
  self = [super initWithNibName:nil bundle:nil];
  if (!self) return nil;

  _viewControllersSignal = viewControllers;

  return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  return [self initWithViewControllers:[RACSignal return:[UIViewController new]]];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  [self doesNotRecognizeSelector:_cmd];
  return [self initWithViewControllers:[RACSignal return:[UIViewController new]]];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  @weakify(self);
  RACSignal *visibleViewController = [[[[self.viewControllersSignal
    distinctUntilChanged]
    throttle:OMSwitchingAnimationDuration valuesPassingTest:^(id _) {
      @strongify(self);
      return self.isAnimating;
    }]
    catchTo:[RACSignal empty]]
    deliverOnMainThread];

  [self rac_liftSelector:@selector(setNextViewController:animated:)
             withSignals:visibleViewController, [RACSignal return:@YES], nil];
}

#pragma mark Accessors

- (UIViewController *)currentViewController {
  return self.childViewControllers.lastObject;
}

#pragma mark Child view controller transitions

- (void)setNextViewController:(UIViewController *)nextViewController animated:(BOOL)animated {
  NSParameterAssert([NSThread isMainThread]);
  if (!nextViewController) return;

  if (animated) {
    self.animating = YES;
  }

  UIViewController *previousViewController = [self currentViewController];
  UIViewAnimationOptions options = (animated ? UIViewAnimationOptionTransitionCrossDissolve
                                             : UIViewAnimationOptionTransitionNone);
  NSTimeInterval duration = (animated ? OMSwitchingAnimationDuration : 0);

  [self addChildViewController:nextViewController];
  nextViewController.view.frame = self.view.bounds;

  if (previousViewController) {
    [previousViewController willMoveToParentViewController:nil];
    [self transitionFromViewController:previousViewController
                      toViewController:nextViewController
                              duration:duration
                               options:options
                            animations:nil
                            completion:^(BOOL finished) {
                              self.animating = NO;
                              [nextViewController didMoveToParentViewController:self];
                              [previousViewController removeFromParentViewController];
                            }];
  } else {
    [self.view addSubview:nextViewController.view];
    nextViewController.view.alpha = 0;

    [UIView animateWithDuration:duration
                     animations:^{
                       nextViewController.view.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                       self.animating = NO;
                       [nextViewController didMoveToParentViewController:self];
                     }];
  }
}

- (UIViewController *)childViewControllerForStatusBarStyle {
  return self.visibleViewController;
}

@end
