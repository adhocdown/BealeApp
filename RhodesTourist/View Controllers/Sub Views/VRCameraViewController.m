//
//  VRCameraViewController.m
//  BealeApp
//
//  Created by Will Cobb on 1/14/15.
//  Copyright (c) 2015 Apprentice Media LLC. All rights reserved.
//

#import "VRCameraViewController.h"

@interface VRCameraViewController ()

@end

@implementation VRCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.layer.shadowRadius = 5;
    self.view.layer.shadowOpacity = 0.5;
    self.view.layer.shadowOffset = CGSizeMake(-5, 0);
    
    //Camera
    
    
    buildingNameView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1000, 1000)];
    buildingNameView.center = cameraViewController.view.center;
    [self.view addSubview:buildingNameView];
    
    //Blur
    /*blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    blurView.frame = cameraViewController.view.bounds;
    blurView.alpha = 0;*/
    //[cameraViewController.view addSubview:blurView];
    
    //progressCircle = [[ProgressView alloc] initAtLocation:CGPointZero Progress:0 Delegate:self];
    //[buildingNameView addSubview:progressCircle];
    NSLog(@"Done1");
    [cameraViewController viewDidLoad];
    [self.view bringSubviewToFront:buildingNameView];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    cameraViewController = [[AVCamViewController alloc] init];
    cameraViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:cameraViewController.view];
    [cameraViewController viewWillAppear:animated];
    NSLog(@"Done2");
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    cameraViewController = nil;
    NSLog(@"Gone");
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    progressCircle.progress = 0;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; //Whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
    
    //Motion
    
    //[motionManager startDeviceMotionUpdates];
    //motionManager.deviceMotionUpdateInterval = 0.3;
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
            withHandler:^(CMDeviceMotion *motion, NSError *error)
            {
                CGFloat angle = -(atan2(motion.gravity.y, motion.gravity.x) + M_PI_2);
                CGFloat deviceRotationVelocity = cos(angle) * motion.rotationRate.y + sin(angle) * motion.rotationRate.x;
                currentHeading -= deviceRotationVelocity * 57.296 * 0.011; //(Radians/sec) to degrees * (seconds between frames)

                [buildingNameView setTransform:CGAffineTransformMakeRotation(angle)];
                for (Building * building in self.locations)
                {
                    [building updateBuildingLabelWithUserLocation:self.locationManager.location Heading:currentHeading Motion:motion];
                }
                
            }
     
     
     
    ];
    [cameraViewController viewDidAppear:animated];
    //[self loadNearbyBuildings];
}
-(void) loadedNewBuildings
{
    //takes the json data and creates the respective objects for each building
    //Then puts each building into a list "locations"
    for (Building * building in self.locations) {
        NSLog(@"%@", building.name);
        [self.view addSubview:building.buildingLabel];
        //[buildingNameView addSubview:building.distanceLabel];
        [self.view addSubview:building.distanceLabel];
    }
    NSLog(@"Loaded");
}

-(void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    //NSLog(@"Heading Updated");
    //If the calculated heading differs by too much, reset the heading to the compass
    if (fabs (currentHeading -  newHeading.trueHeading) > 10)
        currentHeading = newHeading.trueHeading;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
