//
//  MoviesCatalog.h
//  MovieTest
//
//  Created by Mac on 26.10.20.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//
//-----------------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@class MovieItem;

@interface MoviesCatalog : NSObject {

	NSInteger			_lastRequestedPage;
	BOOL				_isDownloading;
	NSMutableArray*		_movies;
	NSMutableSet*		_favoriteMovieNames;
	NSOperationQueue*	_downloadQueue;
}

	- (BOOL) load;
	- (void) stopLoading;
    - (void) clear;

    - (NSString*) favoritesLocation;
	- (void) saveFavorites;
	- (void) loadFavorites;
	- (void) addMovieToFavorites: (MovieItem*) movie;
	- (void) removeMovieFromFavorites: (MovieItem*) movie;

	@property(nonatomic,readonly,copy) NSArray *movies;

@end


extern NSString* const MoviesCatalogDidLoadedChunkNotification;
extern NSString* const MoviesCatalogDidFinishLoadingNotification;
