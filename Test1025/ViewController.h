//
//  ViewController.h
//  Test1025
//
//  Created by Teddy Matinde on 4/28/17.
//  Copyright © 2017 Teddy Matinde. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet AGSMapView *mapView;
@property  (strong, nonatomic) AGSGraphicsLayer *graphicsLayer;


@end

