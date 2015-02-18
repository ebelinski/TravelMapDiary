//
//  MomentViewController.m
//  TravelMapDiary
//
//  Created by HHWS on 15/2/15.
//  Copyright (c) 2015 Eugene Belinski. All rights reserved.
//

#import "MomentViewController.h"
#import "AppDelegate.h"

@interface MomentViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *addNewImageButton;
@property (weak, nonatomic) IBOutlet UIButton *existingButton;
@property (weak, nonatomic) IBOutlet UITextField *textView;

@end

@implementation MomentViewController

- (id)initWithObject:(PFObject *)object {
    self = [super init];
    
    if (self) {
        self.title = @"Moment";
        self.object = object;
        self.didMakeChanges = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSLog([NSString stringWithFormat:@"%@", [self.object objectId]]);
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.addNewImageButton.tintColor = appDelegate.globalColor1;
    self.existingButton.tintColor = appDelegate.globalColor1;
    
    self.textView.text = [self.object objectForKey:@"message"];
    
    NSData *imageData = [[self.object objectForKey:@"file"] getData];
    UIImage *fullSizeImage = [UIImage imageWithData:imageData];
    
    CGSize newSize = CGSizeMake(1000, 1000);
    UIGraphicsBeginImageContext( newSize );
    [fullSizeImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.imageView.image = newImage;
}

- (IBAction)selectNewImage:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (IBAction)selectExistingImage:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get the image from controller
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    CGSize uncroppedSize = CGSizeMake(1000, (int)(1000*(image.size.height/image.size.width)));
    UIGraphicsBeginImageContext(uncroppedSize);
    
    
    CGRect uncroppedRect = CGRectMake(0, 0, 0, 0);
    uncroppedRect.origin = CGPointMake(0.0,0.0);
    uncroppedRect.size.width  = uncroppedSize.width;
    uncroppedRect.size.height = uncroppedSize.height;
    
    [image drawInRect:uncroppedRect];
    
    UIImage *uncroppedImage = UIGraphicsGetImageFromCurrentImageContext();;
    
    UIGraphicsEndImageContext();
    
    //    CGSize imageSize = uncroppedRect.size;
    CGFloat width = uncroppedSize.width;
    CGFloat height = uncroppedSize.height;
    NSLog(@"%f %f", width, height);
    if (width != height) {
        CGFloat newDimension = MIN(width, height);
        CGFloat widthOffset = (width - newDimension) / 2;
        CGFloat heightOffset = (height - newDimension) / 2;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(newDimension, newDimension), NO, 0.);
        [uncroppedImage drawAtPoint:CGPointMake(-widthOffset, -heightOffset)
                          blendMode:kCGBlendModeCopy
                              alpha:1.];
        self.originalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    //    self.imageView.image = self.originalImage;
    
    
    // Make the medium image to display in this view
    CGSize viewSize = CGSizeMake(640, 640);
    UIGraphicsBeginImageContext(viewSize);
    
    CGRect viewRect = CGRectMake(0, 0, 0, 0);
    viewRect.origin = CGPointMake(0.0,0.0);
    viewRect.size.width  = viewSize.width;
    viewRect.size.height = viewSize.height;
    
    [self.originalImage drawInRect:viewRect];
    
    self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    
    // Now make the thumbnail to save
    
    
    
    CGSize thumbSize = CGSizeMake(320, 320);
    UIGraphicsBeginImageContext(thumbSize);
    
    CGRect thumbRect = CGRectMake(0, 0, 0, 0);
    thumbRect.origin = CGPointMake(0.0,0.0);
    thumbRect.size.width  = thumbSize.width;
    thumbRect.size.height = thumbSize.height;
    
    [self.originalImage drawInRect:thumbRect];
    
    self.thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    self.didMakeChanges = YES;
    
    
    // NOW GOING TO SAVE IMAGE TO PARSE SERVER
    
    
    
    NSData *imageData = UIImageJPEGRepresentation(self.originalImage, 0.5);
    PFFile *imageFile = [PFFile fileWithName:@"photo.jpg" data:imageData];
    
    [self.object setObject:imageFile forKey:@"file"];
    [self.object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"We saved the moment image successfully.");
        } else {
            NSLog(@"Saving the moment image failed.");
        }
    }];
}

- (IBAction)textViewEditingDidEnd:(id)sender {
    [self.object setObject:self.textView.text forKey:@"message"];
    [self.object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"We saved the moment message successfully.");
        } else {
            NSLog(@"Saving the moment message failed.");
        }
    }];
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
