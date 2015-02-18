//
//  MapViewController.h
//  TravelMapDiary
//
//  Created by HHWS on 14/2/15.
//  Copyright (c) 2015 Eugene Belinski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

//- (IBAction)zoomIn:(id)sender;
- (void)setUserLocation;
- (void)displayAllMoments;

@end