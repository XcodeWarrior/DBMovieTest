//
//  MovieTestViewController.h
//  MovieTest
//
//  Created by Mac on 26.10.20.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//
//-----------------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@class MoviesCatalog;
@class MovieItem;

@interface MovieTestViewController : UIViewController<
											UITableViewDelegate,
											UITableViewDataSource,
											UISearchBarDelegate,
											UIScrollViewDelegate >

	@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
	@property (nonatomic, retain) IBOutlet UITableView *tableView;
	@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadActivityView;
	@property (nonatomic, retain) IBOutlet UILabel *itemsCountLabel;

	- (MovieItem*) queryPrevMovieItem:(MovieItem*)movieItem;
	- (MovieItem*) queryNextMovieItem:(MovieItem*)movieItem;
	- (NSUInteger) findRowForMovieItem: (MovieItem*)movieItem;
	- (MovieItem*) movieItemForRow:(NSUInteger)row;
	- (void) loadVisibleImages;

	- (IBAction)stopLoadingCatalog:(id)sender;
    - (IBAction)close:(id)sender;

@end


