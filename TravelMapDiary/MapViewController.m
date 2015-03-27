//
//  MapViewController.m
//  TravelMapDiary
//
//  Created by HHWS on 14/2/15.
//  Copyright (c) 2015 Eugene Belinski. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "MapViewController.h"
#import "AppDelegate.h"
#import "MomentViewController.h"
#import "CustomMKPointAnnotation.h"

@interface MapViewController () <CLLocationManagerDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addPinButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;

@end

@implementation MapViewController

- (id)init {
    self = [super init];
    
    if (self) {
        self.title = @"Map";
        self.tabBarItem.title = @"Map";
        UIImage *tabBarImage = [UIImage imageNamed:@"map-50.png"];
        self.tabBarItem.image = tabBarImage;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.addPinButton.tintColor = appDelegate.globalColor1;
    self.shareButton.tintColor = appDelegate.globalColor1;
    self.deleteButton.tintColor = appDelegate.globalColor1;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    self.navigationItem.leftBarButtonItem = refreshButton;
    
    self.mapView.delegate = self;
    
    [self setUserLocation];
    
    [self displayAllMoments];
}

- (IBAction)sendFeedback:(id)sender {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"My Trip"];
        [mail setMessageBody:@"Come check out my trip: http://tripgist.com/fd78sf7ew9k" isHTML:NO];
//        [mail setToRecipients:@[@"mountainpeakapp@gmail.com"]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if (result == MFMailComposeResultSent)
    {
        NSLog(@"\n\n Email Sent");
        //        [AppDelegate showAlert:@"Email Sent"];
        
    }
    if([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)])
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
    //    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)refresh:(id)sender {
    [self displayAllMoments];
}

- (void)displayAllMoments {
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Moment"];
    if ([PFUser currentUser]) {
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Received %lu moments.", [objects count]);
            for (PFObject *moment in objects) {
                PFGeoPoint *geoPoint = [moment objectForKey:@"location"];
                
                CustomMKPointAnnotation *myAnnotation = [[CustomMKPointAnnotation alloc] init];
                myAnnotation.coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
                NSLog([NSString stringWithFormat:@"Hello: %@", [moment objectForKey:@"message"]]);
                if ([[moment objectForKey:@"message"] isEqualToString:@""] || [moment objectForKey:@"message"] == nil) {
                    myAnnotation.title = @"Untitled Pin";
                } else {
                    myAnnotation.title = [moment objectForKey:@"message"];
                }
                myAnnotation.object = moment;
                
                [self.mapView addAnnotation:myAnnotation];
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)setUserLocation {
    //    NSLog(@"Going to try to set the user location now.");
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            
            appDelegate.userLocation = geoPoint;
            NSLog(@"Set location to %f %f", geoPoint.latitude, geoPoint.longitude);
            
            appDelegate.userLocationSet = YES;
            
            self.mapView.showsUserLocation = YES;
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude), 2000, 2000);
            
            [self.mapView setRegion:region animated:YES];
            
        } else {
            NSLog(@"Error getting location");
            
            appDelegate.userLocationSet = NO;
            
            UIAlertController *pictureAlertController = [UIAlertController alertControllerWithTitle:@"Location Unknown" message:@"TripGist was unable to retrieve your location. You may need to enable in by going to Settings > Privacy > Location Services > Travel Map Diary > and select While Using the App." preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            
            [pictureAlertController addAction:okAction];
            [self presentViewController:pictureAlertController animated:YES completion:nil];
        }
    }];
}

- (IBAction)addPin:(id)sender {
    CLLocationCoordinate2D coord = [self.mapView centerCoordinate];
    
    CustomMKPointAnnotation *myAnnotation = [[CustomMKPointAnnotation alloc] init];
    myAnnotation.coordinate = coord;
    
    myAnnotation.title = @"New Pin";
    
    [self.mapView addAnnotation:myAnnotation];
    
    NSLog(@"We're going to save now.");
    
    PFObject *object = [PFObject objectWithClassName:@"Moment"];
    
    NSUUID *oNSUUID = [[UIDevice currentDevice] identifierForVendor];
    [object setObject:[NSString stringWithString:[oNSUUID UUIDString]] forKey:@"userDeviceID"];
    PFUser *user = [PFUser currentUser];
    [object setObject:user forKey:@"user"];
    
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:coord.latitude longitude:coord.longitude];
    [object setObject:geoPoint forKey:@"location"];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"We saved the moment successfully.");
            myAnnotation.object = object;
        } else {
//            NSLog([error localizedDescription]);
            NSLog(@"Saving the new pin failed.");
        }
    }];
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
//    id <MKAnnotation> annotation = [view annotation];
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Disclosure Pressed" message:@"Click Cancel to Go Back" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//    [alertView show];
    
    
    CustomMKPointAnnotation *pinView = (CustomMKPointAnnotation *)[view annotation];
    
    MomentViewController *moment = [[MomentViewController alloc] initWithObject:pinView.object];
    
    [self.navigationController pushViewController:moment animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[CustomMKPointAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.canShowCallout = YES;
            
            // Add a detail disclosure button to the callout.
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            
            pinView.rightCalloutAccessoryView = rightButton;
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
