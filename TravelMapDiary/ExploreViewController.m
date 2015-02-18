//
//  ExploreViewController.m
//  TravelMapDiary
//
//  Created by HHWS on 15/2/15.
//  Copyright (c) 2015 Eugene Belinski. All rights reserved.
//

#import "ExploreViewController.h"

@interface ExploreViewController ()

@end

@implementation ExploreViewController

- (id)init {
    self = [super init];
    
    if (self) {
        self.title = @"Explore";
        self.tabBarItem.title = @"Explore";
        UIImage *tabBarImage = [UIImage imageNamed:@"globe-50.png"];
        self.tabBarItem.image = tabBarImage;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
