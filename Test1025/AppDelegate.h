//
//  AppDelegate.h
//  Test1025
//
//  Created by Teddy Matinde on 4/28/17.
//  Copyright © 2017 Teddy Matinde. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

