//
//  CustomMKPointAnnotation.h
//  TravelMapDiary
//
//  Created by HHWS on 17/2/15.
//  Copyright (c) 2015 Eugene Belinski. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface CustomMKPointAnnotation : MKPointAnnotation

@property (strong, nonatomic) PFObject *object;

@end
