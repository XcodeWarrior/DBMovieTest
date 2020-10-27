//
//  AppDelegate.h
//  MovieTest
//
//  Created by Mac on 26.10.20.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//
//-----------------------------------------------------------------------------------------

#import <UIKit/UIKit.h>
@class MoviesCatalog;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

    @property (strong, nonatomic) UIWindow *window;
    @property (nonatomic, retain) MoviesCatalog *moviesCatalog;

    - (IBAction)openNowPlayingScene: sender;

@end

