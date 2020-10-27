//
//  MovieItem.h
//  MovieTest
//
//  Created by Mac on 26.10.20.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//
//-----------------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

///////////////////////////////////////////////////////////////////////////////////////////

@interface MovieItem : NSObject {
	
	BOOL			_isDownloadingPoster;
	BOOL			_isDownloadingThumb;
	BOOL			_isFavorite;
	NSString *		_title;
	NSString *		_description;
    NSString *      _releaseDate;
    NSNumber *      _voteRating;
	NSString *		_posterPath;
	UIImage *		_posterImage;
	UIImage *		_thumbIcon;
}

	@property(nonatomic,readonly,copy) NSString *title;
	@property(nonatomic,readonly,copy) NSString *overview;
    @property(nonatomic,readonly,copy) NSString *releaseDate;
    @property(nonatomic,readonly,copy) NSNumber *voteRating;
	@property(nonatomic,readonly,copy) NSString *posterPath;
	@property(nonatomic,readonly,retain) UIImage *thumbIcon;
	@property(nonatomic,readonly,retain) UIImage *posterImage;
	@property(nonatomic) BOOL isFavorite;

	- (id) initWithProperties: (NSDictionary*)inDict;
	- (BOOL) loadPosterImage;
	- (BOOL) loadThumbIcon;

@end


extern NSString* const MovieItemDidLoadedPosterImageNotification;
extern NSString* const MovieItemDidLoadedThumbIconImageNotification;

