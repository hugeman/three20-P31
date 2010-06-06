//
//  TTBaseNavigationControllerCategory.m
//  P31-Additions
//
//  Created by Mike on 6/5/10.
//  Copyright 2010 Prime31 Studios. All rights reserved.
//

#import "TTBaseNavigationControllerCategory.h"


@implementation TTBaseNavigationController(Category)

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark TTBaseNavigationController overrides

- (void)pushViewController:(UIViewController*)controller animatedWithTransition:(UIViewAnimationTransition)transition
{
	[self pushViewController:controller animated:NO];
	
	// Are we adding a standard UIViewAnimationTransition or custom? (custom will be 10 or greater)
	if( transition < 10 )
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:ttkDefaultFlipTransitionDuration];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(pushAnimationDidStop)];
		[UIView setAnimationTransition:transition forView:self.view cache:YES];
		[UIView commitAnimations];
	}
	else
	{
		switch( transition )
		{
			case kUIViewAnimationTransitionZoomIn:
			{
				// Create a keyframe animation to zoom in/out
				CAKeyframeAnimation *zoomIn = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
				zoomIn.delegate = self;
				NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];
				zoomIn.values = values;
				zoomIn.duration = ttkDefaultFastTransitionDuration;
				[controller.view.layer addAnimation:zoomIn forKey:@"transformScale"];
				
				break;
			}
			case kUIViewAnimationTransitionZoomOut:
			{
				// Create a keyframe animation to zoom in/out
				CAKeyframeAnimation *zoomOut = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
				zoomOut.delegate = self;
				NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1.0], [NSNumber numberWithFloat:0.0], nil];
				zoomOut.values = values;
				zoomOut.duration = ttkDefaultFastTransitionDuration;
				[controller.view.layer addAnimation:zoomOut forKey:@"transformScale"];
				
				break;
			}
			case kUIViewAnimationTransitionFadeIn:
			{
				// Create a fade animation and apply it to the superview's layer
				CATransition *animation = [CATransition animation];
				[animation setType:kCATransitionFade];
				[self.view.superview.layer addAnimation:animation forKey:@"layerAnimation"];
				
				break;
			}
			case kUIViewAnimationTransitionFadeOut:
			{
				// Create a fade animation and apply it to the superview's layer
				CATransition *animation = [CATransition animation];
				[animation setType:kCATransitionFade];
				[self.view.superview.layer addAnimation:animation forKey:@"layerAnimation"];
				
				break;
			}
		}
	}
}


- (UIViewController*)popViewControllerAnimatedWithTransition:(UIViewAnimationTransition)transition
{
	UIViewController *poppedController = [self.viewControllers lastObject];
	
	// Are we popping a standard UIViewAnimationTransition or custom? (custom will be 10 or greater)
	if( transition < 10 )
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:ttkDefaultFlipTransitionDuration];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(pushAnimationDidStop)];
		[UIView setAnimationTransition:transition forView:self.view cache:NO];
		[UIView commitAnimations];
	}
	else
	{
		switch( transition )
		{
			case kUIViewAnimationTransitionZoomIn:
			{
				// Create a keyframe animation to zoom in/out
				CAKeyframeAnimation *zoomIn = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
				zoomIn.delegate = self;
				NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.01], [NSNumber numberWithFloat:1.0], nil];
				zoomIn.values = values;
				zoomIn.duration = ttkDefaultFastTransitionDuration;
				[poppedController.view.layer addAnimation:zoomIn forKey:@"transformScale"];
				
				break;
			}
			case kUIViewAnimationTransitionZoomOut:
			{
				// Create a keyframe animation to zoom in/out
				CAKeyframeAnimation *zoomOut = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
				zoomOut.delegate = self;
				NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1.0], [NSNumber numberWithFloat:0.0], nil];
				zoomOut.values = values;
				zoomOut.duration = ttkDefaultFastTransitionDuration;
				[poppedController.view.layer addAnimation:zoomOut forKey:@"transformScale"];

				break;
			}
			case kUIViewAnimationTransitionFadeIn:
			{
				// Create a fade animation and apply it to the superview's layer
				CATransition *animation = [CATransition animation];
				[animation setType:kCATransitionFade];
				[poppedController.view.layer addAnimation:animation forKey:@"layerAnimation"];

				break;
			}
			case kUIViewAnimationTransitionFadeOut:
			{
				// Create a fade animation and apply it to the superview's layer
				CATransition *animation = [CATransition animation];
				[animation setType:kCATransitionFade];
				[self.view.superview.layer addAnimation:animation forKey:@"layerAnimation"];
				
				break;
			}
		}
	}
	
	// We will do the actual viewController popping after a short delay for zooms
	if( transition == kUIViewAnimationTransitionZoomIn || transition == kUIViewAnimationTransitionZoomOut )
	{
		[self performSelector:@selector(popViewControllerAnimated:) withObject:nil afterDelay:ttkDefaultFastTransitionDuration];
		return poppedController;
	}
	
	return [self popViewControllerAnimated:NO];
}


- (UIViewAnimationTransition)invertTransition:(UIViewAnimationTransition)transition
{
	switch( transition )
	{
		case UIViewAnimationTransitionCurlUp:
			return UIViewAnimationTransitionCurlDown;
		case UIViewAnimationTransitionCurlDown:
			return UIViewAnimationTransitionCurlUp;
		case UIViewAnimationTransitionFlipFromLeft:
			return UIViewAnimationTransitionFlipFromRight;
		case UIViewAnimationTransitionFlipFromRight:
			return UIViewAnimationTransitionFlipFromLeft;
		
		case kUIViewAnimationTransitionZoomOut:
			return kUIViewAnimationTransitionZoomIn;
		case kUIViewAnimationTransitionZoomIn:
			return kUIViewAnimationTransitionZoomOut;
		case kUIViewAnimationTransitionFadeOut:
			return kUIViewAnimationTransitionFadeIn;
		case kUIViewAnimationTransitionFadeIn:
			return kUIViewAnimationTransitionFadeOut;
			
		default:
			return UIViewAnimationTransitionNone;
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark CAAnimation Delegate

- (void)animationDidStop:(CAAnimation*)theAnimation finished:(BOOL)flag
{
	// If this is a CAKeyframeAnimation we might have to manually pop
	if( [theAnimation isKindOfClass:[CAKeyframeAnimation class]] )
	{
		NSArray *values = ((CAKeyframeAnimation*)theAnimation).values;
		NSNumber *lastValue = [values lastObject];
		
		// Is this a zoomOut?  If so, pop the viewController here
		//if( [lastValue floatValue] == 0.0 )
		//	[self popViewControllerAnimated:NO];
	}
	
	// Call the standard, UIViewTransition didStop selector
	[self pushAnimationDidStop];
}


@end
