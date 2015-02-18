//
//  AppDelegate.h
//  TravelMapDiary
//
//  Created by HHWS on 14/2/15.
//  Copyright (c) 2015 Eugene Belinski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSString *userDeviceID;
@property (strong, nonatomic) PFUser *currentUser;
@property (nonatomic, retain) PFGeoPoint *userLocation;
@property (nonatomic) BOOL userLocationSet;
@property (nonatomic) BOOL onSimulator;
@property (nonatomic, retain) UIColor *globalColor1;
@property (nonatomic) UIBarStyle globalBarStyle;

@end

