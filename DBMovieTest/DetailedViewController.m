//
//  DetailedViewController.m
//  MovieTest
//
//  Created by Mac on 26.10.20.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//
//-----------------------------------------------------------------------------------------

#import "DetailedViewController.h"
#import "MoviesCatalog.h"
#import "MovieItem.h"


@interface DetailedViewController (Private)
	- (MoviesCatalog*) moviesCatalog;
	- (void) focusMovieItem: (MovieItem*)movieItem;
    - (UIImage*) favoriteImageFor: (BOOL)isFavorite;
@end

/////////////////////////////////////////////////////////////////////////////////////////////

@implementation DetailedViewController

@synthesize posterImage = _posterImage;
@synthesize titleLabel = _titleLabel;
@synthesize overviewTextView = _overviewTextView;
@synthesize favoriteButton = _favoriteButton;
@synthesize movieItem = _movieItem;
@synthesize releaseDateLabel = _releaseDateLabel;
@synthesize rateLabel = _rateLabel;


- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [super loadView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
	_titleLabel.text = _movieItem.title;
    _releaseDateLabel.text = _movieItem.releaseDate;
    _rateLabel.text = _movieItem.voteRating.description;
    _overviewTextView.text = _movieItem.overview;
    [_overviewTextView setContentOffset:CGPointZero animated:NO];

    [_favoriteButton setImage: [self favoriteImageFor: _movieItem.isFavorite] forState:UIControlStateNormal];

    _posterImage.image = _movieItem.posterImage;

	if (_movieItem.posterImage == nil)
	{
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(posterImageLoaded:)
													 name: MovieItemDidLoadedPosterImageNotification
												   object: _movieItem ];
		[_movieItem loadPosterImage];
	}
}

- (MoviesCatalog*) moviesCatalog {

	id delegate = [UIApplication sharedApplication].delegate;
	if ([delegate respondsToSelector:@selector(moviesCatalog)])
		return [delegate performSelector:@selector(moviesCatalog)];
	else
		return nil;
}	

- (void) posterImageLoaded: (NSNotification*)notification
{
    if (notification.object == _movieItem)
        _posterImage.image = _movieItem.posterImage;
}

- (IBAction)closeMovieItem:(id)sender
{
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (IBAction)gotoNextMovieItem:(id)sender
{
	if ([self.presentingViewController respondsToSelector:@selector(queryNextMovieItem:)])
	{
		MovieItem* prevMovieItem = [self.presentingViewController performSelector: @selector(queryNextMovieItem:)
																   withObject: _movieItem];
		[self focusMovieItem: prevMovieItem];
	}
}

- (IBAction)gotoPrevMovieItem:(id)sender
{
	if ([self.presentingViewController respondsToSelector:@selector(queryPrevMovieItem:)])
	{
		MovieItem* prevMovieItem = [self.presentingViewController performSelector: @selector(queryPrevMovieItem:)
																   withObject: _movieItem];
		[self focusMovieItem: prevMovieItem];
	}
}

- (void) focusMovieItem: (MovieItem*)inMovieItem
{
	if (inMovieItem == _movieItem)
		return;
	
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	self.movieItem = inMovieItem;

	_titleLabel.text = _movieItem.title;
    _releaseDateLabel.text = _movieItem.releaseDate;
    _rateLabel.text = _movieItem.voteRating.description;
    _overviewTextView.text = _movieItem.overview;
    [_overviewTextView setContentOffset:CGPointZero animated:NO];

    [_favoriteButton setImage: [self favoriteImageFor: _movieItem.isFavorite] forState:UIControlStateNormal];

	if (_movieItem.posterImage == nil)
	{
        _posterImage.image = [UIImage imageNamed:@"PlaceholderLarge.png"];

		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(posterImageLoaded:)
													 name: MovieItemDidLoadedPosterImageNotification
												   object: _movieItem ];
		[_movieItem loadPosterImage];
	}
    else
    {
        _posterImage.image = _movieItem.posterImage;
    }
}

- (IBAction)toggleFavorite:(id)sender
{
	_movieItem.isFavorite = !_movieItem.isFavorite;
    [_favoriteButton setImage: [self favoriteImageFor: _movieItem.isFavorite] forState:UIControlStateNormal];

	if (_movieItem.isFavorite)
		[[self moviesCatalog] addMovieToFavorites:_movieItem];
	else
		[[self moviesCatalog] removeMovieFromFavorites:_movieItem];
}

- (UIImage*) favoriteImageFor: (BOOL)isFavorite
{
    UIImage* image = [UIImage imageNamed:isFavorite ? @"Star_marked_256.png" : @"Star_empty_256.png"];
    return image;
}

@end
