//
//  MomentViewController.h
//  TravelMapDiary
//
//  Created by HHWS on 15/2/15.
//  Copyright (c) 2015 Eugene Belinski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "CustomMKPointAnnotation.h"

@interface MomentViewController : UIViewController

@property (retain, nonatomic) UIImage *originalImage;
@property (retain, nonatomic) UIImage *thumbnailImage;
@property (strong, nonatomic) id parentView;
@property (strong, nonatomic) PFGeoPoint *userLocation;
@property (strong, nonatomic) PFObject *object;
@property (assign) BOOL didMakeChanges;

- (id)initWithObject:(PFObject *)object;

@end
