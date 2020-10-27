//
//  MovieItem.m
//  MovieTest
//
//  Created by Mac on 26.10.20.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//
//-----------------------------------------------------------------------------------------

#import "MovieItem.h"

NSString* const MovieItemDidLoadedPosterImageNotification = @"MovieItem_DidLoadedPosterImageNotification";
NSString* const MovieItemDidLoadedThumbIconImageNotification = @"MovieItem_DidLoadedThumbIconNotification";

//-----------------------------------------------------------------------------------------
//	* MovieItem
//-----------------------------------------------------------------------------------------

@implementation MovieItem

@synthesize title = _title;
@synthesize overview = _overview;
@synthesize thumbIcon = _thumbIcon;
@synthesize posterImage = _posterImage;
@synthesize posterPath = _posterPath;
@synthesize isFavorite = _isFavorite;
@synthesize voteRating = _voteRating;
@synthesize releaseDate = _releaseDate;


- (void)dealloc
{
}

- (id) initWithProperties: (NSDictionary*)inDict
{
    self = [super init];
	
    if (self) // Custom initialization
	{ 
		NSObject* value = [inDict valueForKey:@"title"];
		if ([value isKindOfClass:[NSString class]] )
			_title = (NSString*) value;
		
		value = [inDict valueForKey:@"overview"];
		if ([value isKindOfClass:[NSString class]] )
			_overview = (NSString*) value;
		
		value = [inDict valueForKey:@"release_date"];
		if ([value isKindOfClass:[NSString class]] )
			_releaseDate = (NSString*) value;

		value = [inDict valueForKey:@"poster_path"];
		if ([value isKindOfClass:[NSString class]] )
			_posterPath = (NSString*) value;

        value = [inDict valueForKey:@"vote_average"];
        if ([value isKindOfClass:[NSNumber class]] )
            _voteRating = (NSNumber*) value;
    }
    return self;
}

- (BOOL) loadPosterImage {
	
	if (_posterImage == nil && _posterPath.length > 0)
	{
		if (!_isDownloadingPoster)
		{
			_isDownloadingPoster = YES;
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
			^{
				NSString*		strRequest = @"https://image.tmdb.org/t/p/w500";
				strRequest = [strRequest stringByAppendingString: self->_posterPath];
				
				NSURL*			url = [NSURL URLWithString:strRequest];
				NSURLRequest*	request = [NSURLRequest requestWithURL: url];
				NSURLResponse*	response = nil;
				NSError*		error = nil;
				
				NSData*			downloadedData = [NSURLConnection sendSynchronousRequest: request
                                                                       returningResponse: &response
                                                                                   error: &error];
				dispatch_async(dispatch_get_main_queue(),
				^{
					NSLog(@"Loaded Image %@", self->_posterPath);
					
					UIImage*		image = [UIImage imageWithData:downloadedData];
					
					self->_posterImage = image;
					[[NSNotificationCenter defaultCenter] postNotificationName: MovieItemDidLoadedPosterImageNotification
																		object: self
																	  userInfo: nil];
				});
			});
		}
	}
	
	return TRUE;
}

- (BOOL) loadThumbIcon {
	
	if (_thumbIcon == nil && _posterPath.length > 0)
	{
		if (!_isDownloadingThumb)
		{
			_isDownloadingThumb = YES;
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
			^{
				NSString*		strRequest = @"https://image.tmdb.org/t/p/w185";
				strRequest = [strRequest stringByAppendingString: self->_posterPath];
				
				NSURL*			url = [NSURL URLWithString:strRequest];
				NSURLRequest*	request = [NSURLRequest requestWithURL: url];
				NSURLResponse*	response = nil;
				NSError*		error = nil;
				
				NSData*			downloadedData = [NSURLConnection  sendSynchronousRequest: request
																		returningResponse: &response
																					error: &error];
				dispatch_async(dispatch_get_main_queue(),
				^{
					NSLog(@"Loaded Thumb Image %@", self->_posterPath);
					
					UIImage*	image = [UIImage imageWithData:downloadedData];
					
					if (image.size.width != 48 && image.size.height != 48)
					{
						CGSize itemSize = CGSizeMake(48, 48);
						UIGraphicsBeginImageContext(itemSize);
						
							CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
							[image drawInRect:imageRect];
							self->_thumbIcon = UIGraphicsGetImageFromCurrentImageContext();
						
						UIGraphicsEndImageContext();
					}
					else
					{
						self->_thumbIcon = image;
					}
					
					[[NSNotificationCenter defaultCenter] postNotificationName: MovieItemDidLoadedThumbIconImageNotification
																		object: self
																	  userInfo: nil];
				});
			});
		}
	}
	
	return TRUE;
}


@end
