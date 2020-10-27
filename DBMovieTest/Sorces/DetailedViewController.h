//
//  DetailedViewController.h
//  MovieTest
//
//  Created by Mac on 26.10.20.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//
//-----------------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@class MoviesCatalog;
@class MovieItem;

@interface DetailedViewController : UIViewController

	@property (nonatomic, retain) IBOutlet UIImageView *posterImage;
	@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
    @property (nonatomic, retain) IBOutlet UILabel *releaseDateLabel;
    @property (nonatomic, retain) IBOutlet UILabel *rateLabel;
    @property (nonatomic, retain) IBOutlet UITextView *overviewTextView;
	@property (nonatomic, retain) IBOutlet UIButton *favoriteButton;
	@property (nonatomic, retain) MovieItem *movieItem;

	- (IBAction)closeMovieItem:(id)sender;
	- (IBAction)gotoNextMovieItem:(id)sender;
	- (IBAction)gotoPrevMovieItem:(id)sender;
	- (IBAction)toggleFavorite:(id)sender;

@end


