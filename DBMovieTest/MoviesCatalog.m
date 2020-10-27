//
//  MoviesCatalog.m
//  MovieTest
//
//  Created by Mac on 26.10.20.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//
//-----------------------------------------------------------------------------------------

#import "MoviesCatalog.h"
#import "MovieItem.h"


NSString* const MoviesCatalogDidLoadedChunkNotification = @"MoviesCatalog_DidLoadedChunkNotification";
NSString* const MoviesCatalogDidFinishLoadingNotification = @"MoviesCatalog_DidFinishLoadingNotification";


@interface MoviesCatalog (Private)

    - (NSBlockOperation*) schedulePageDownload: (NSUInteger) pageIdx;
	- (void) scheduleCatalogPagesDownload: (NSRange) range;
	- (void) onCatalogFinishLoading;

@end

///////////////////////////////////////////////////////////////////////////////////////////

@implementation MoviesCatalog

@synthesize movies = _movies;


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
    }

    return self;
}

- (void)dealloc {
}

///////////////////////////////////////////////////////////////////////////////////////////

- (NSString*) favoritesLocation {

    NSArray*  paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* doumentsFolder = [paths objectAtIndex:0];
    NSString* pathName = [doumentsFolder stringByAppendingString:@"/Favorites.txt"];

    return pathName;
}

- (void) loadFavorites {

	NSError* error = nil;
	NSString* allFavoritesText = [NSString stringWithContentsOfFile: self.favoritesLocation
														   encoding: NSUTF8StringEncoding
															  error: &error];
	NSArray* favorites = [allFavoritesText componentsSeparatedByString: @"\r\n"];

	_favoriteMovieNames = [NSMutableSet new];
	[_favoriteMovieNames addObjectsFromArray: favorites];
	[_favoriteMovieNames removeObject:@""];
}

- (void) saveFavorites {
	
	NSArray* favorites = [_favoriteMovieNames allObjects];
	NSString* allFavoritesText = [favorites componentsJoinedByString:@"\r\n"];
	NSError* error = nil;
	
	[allFavoritesText writeToFile: self.favoritesLocation
					   atomically: YES
						 encoding: NSUTF8StringEncoding
							error: &error];
}

- (void) addMovieToFavorites:(MovieItem*)movie
{
	[_favoriteMovieNames addObject:movie.title];
}

- (void) removeMovieFromFavorites:(MovieItem*)movie
{
	[_favoriteMovieNames removeObject:movie.title];
}

///////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)load {
	
	if (!_isDownloading)
	{
		_isDownloading = YES;
		_downloadQueue = [[NSOperationQueue alloc] init];
		[_downloadQueue setMaxConcurrentOperationCount: 10];

		NSBlockOperation *blockOp = [self schedulePageDownload:1];
		[_downloadQueue addOperation:blockOp];
	}
	
	return TRUE;
}

- (void)stopLoading {

    if (_isDownloading) {
        [_downloadQueue cancelAllOperations];
        [self onCatalogFinishLoading];
    }
}

- (void)clear {

    [_movies removeAllObjects];

    if (_isDownloading) {
        [_downloadQueue cancelAllOperations];
        [self onCatalogFinishLoading];
    }
}


- (void)onCatalogPageLoaded: (NSUInteger) pageIdx withData: (NSData*) theData
{
	if (!_isDownloading)
	{
		NSLog(@"Ignoring Loaded Page %ld", pageIdx);
		return;
	}

    NSLog(@"Loaded Page %ld", pageIdx);

    NSObject*       jsonData = [NSJSONSerialization JSONObjectWithData: theData
                                                               options: 0
                                                                 error: nil];

	NSDictionary*	inLoadedJsonData = [jsonData isKindOfClass:[NSDictionary class]] ? (NSDictionary*)jsonData : nil;
	
	if (_movies == nil)
		_movies = [[NSMutableArray alloc] init];
	
	NSArray* loadedMovies = [inLoadedJsonData valueForKey:@"results"];
	for (NSDictionary* movieProperties in loadedMovies)
	{
		MovieItem* movieItem = [[MovieItem alloc] initWithProperties: movieProperties];
		if (movieItem != nil)
		{
			movieItem.isFavorite = [_favoriteMovieNames containsObject: movieItem.title];
			[_movies addObject: movieItem];
		}
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName: MoviesCatalogDidLoadedChunkNotification
														object: self
													  userInfo: nil];
	
	if (pageIdx == 1) // Did we Downloaded 1st page ?
	{
		NSInteger totalPages = [[inLoadedJsonData valueForKey:@"total_pages"] integerValue];
		
		if (totalPages > 1)
			[self scheduleCatalogPagesDownload: NSMakeRange(2, totalPages - 1)];
		else
			[self onCatalogFinishLoading];
	}
}

- (void)scheduleCatalogPagesDownload: (NSRange) range {

	if (!_isDownloading || _downloadQueue == nil) // Sanity Check
	{
		return;
	}

	NSLog(@"Scheduling Pages Download %ld..%ld", range.location, range.location + range.length - 1);

	[_downloadQueue setMaxConcurrentOperationCount: 1];
	
	NSBlockOperation *finishBlockOp = [[NSBlockOperation alloc] init];
	
	for (NSUInteger idx = range.location; idx < range.location + range.length; idx++)
	{
		NSBlockOperation* pageOp = [self schedulePageDownload: idx];
		[finishBlockOp addDependency:pageOp];
		[_downloadQueue addOperation:pageOp];
	}

	[finishBlockOp addExecutionBlock: 
	^{
		dispatch_async(dispatch_get_main_queue(),
		^{
			[self onCatalogFinishLoading];
		});
	 }];
	[_downloadQueue addOperation:finishBlockOp];
}

- (NSBlockOperation*) schedulePageDownload: (NSUInteger) pageIdx
{
	NSBlockOperation *blockOp = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakBlockOp = blockOp;

	[blockOp addExecutionBlock: // Download Page (Async)
	^{
		if ([weakBlockOp isCancelled])
		{
			NSLog(@"- (A) skipping Cancelled operation for (Page %ld)", pageIdx);
			return;
		}

		NSString*		strRequest = @"https://api.themoviedb.org/3/movie/now_playing?api_key=1a2bd7afcda9244d7c306f54aae8b459";
		if (pageIdx > 1)
			strRequest = [strRequest stringByAppendingFormat:@"&page=%ld", pageIdx];
		
		NSURL*			url = [NSURL URLWithString:strRequest];
		NSURLRequest*	request = [NSURLRequest requestWithURL: url];
		NSURLResponse*	response = nil;
		NSError*		error = nil;
		NSData*			outData = [NSURLConnection sendSynchronousRequest: request
                                                        returningResponse: &response
                                                                    error: &error];
		if ([weakBlockOp isCancelled])
		{
			NSLog(@"- (B) skipping Cancelled operation for (Page %ld)", pageIdx);
			return;
		}

        // [NSThread sleepForTimeInterval:0.2f]; // for Debug

		dispatch_async(dispatch_get_main_queue(),
		^{
			if ([weakBlockOp isCancelled])
			{
				NSLog(@"- (C) skipping Cancelled operation for (Page %ld)", pageIdx);
				return;
			}
			
			[self onCatalogPageLoaded: pageIdx withData: outData];
		});
	}];
	
	return blockOp;
}

- (void)onCatalogFinishLoading {
	
	if (_isDownloading)
	{
		NSLog(@"Catalog Loaded !");
		_isDownloading = NO;
		[[NSNotificationCenter defaultCenter] postNotificationName: MoviesCatalogDidFinishLoadingNotification
															object: self
														  userInfo: nil];
	}
}


@end
