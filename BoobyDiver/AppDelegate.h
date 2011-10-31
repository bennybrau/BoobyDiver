//
//  AppDelegate.h
//  BoobyDiver
//
//  Created by Jonathan Arme on 10/6/11.
//  Copyright Rovi Corporation 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
