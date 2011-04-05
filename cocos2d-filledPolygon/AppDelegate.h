//
//  AppDelegate.h
//  cocos2d-filledPolygon
//
//  Created by Andy Sinesio on 4/4/11.
//  Copyright Precognitive Research, LLC 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
