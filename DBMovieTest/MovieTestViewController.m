//
//  MovieTestViewController.m
//  MovieTest
//
//  Created by Mac on 26.10.20.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//
//-----------------------------------------------------------------------------------------

#import "MovieTestViewController.h"
#import "DetailedViewController.h"
#import "MoviesCatalog.h"
#import "MovieItem.h"


@interface MovieTestViewController() // Private Extension

	@property(nonatomic,retain) UITableViewController *tableViewController;
	@property(nonatomic,retain) NSArray *filteredEntries;

    - (MoviesCatalog*) moviesCatalog;

@end

///////////////////////////////////////////////////////////////////////////////////////////

@implementation MovieTestViewController

@synthesize tableViewController;
@synthesize filteredEntries = _filteredEntries;
@synthesize searchBar = _searchBar;
@synthesize tableView = _tableView;
@synthesize loadActivityView = _loadActivityView;
@synthesize itemsCountLabel = _itemsCountLabel;


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.moviesCatalog clear];
}

- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.tableView.rowHeight = 60;

	MoviesCatalog* moviesCatalog = self.moviesCatalog;

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(moviesCatalogLoadedChunk:)
												 name:MoviesCatalogDidLoadedChunkNotification
											   object:moviesCatalog];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(moviesCatalogDidFinishLoading:)
												 name:MoviesCatalogDidFinishLoadingNotification
											   object:moviesCatalog];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(movieItemDidLoadThumbIcon:)
												 name:MovieItemDidLoadedThumbIconImageNotification
											   object:nil];
	[moviesCatalog load];
	[_loadActivityView startAnimating];
	[_loadActivityView setHidden:NO];
}

- (MoviesCatalog*) moviesCatalog {

	id delegate = [UIApplication sharedApplication].delegate;
	if ([delegate respondsToSelector:@selector(moviesCatalog)])
		return [delegate performSelector:@selector(moviesCatalog)];
	else
		return nil;
}	

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (IBAction)stopLoadingCatalog:(id)sender
{
	[[self moviesCatalog] stopLoading];
}

- (void) moviesCatalogLoadedChunk: (NSNotification*)notification
{
	NSInteger moviesCount = self.moviesCatalog.movies.count;
	_itemsCountLabel.text = [NSString stringWithFormat:@"%ld movies", moviesCount];
	
	[self.tableView reloadData];
}

- (void) moviesCatalogDidFinishLoading: (NSNotification*)notification
{
	[_loadActivityView setHidden: YES];
	[_loadActivityView stopAnimating];
}

- (void) movieItemDidLoadThumbIcon: (NSNotification*)notification
{
	MovieItem* movieItem = (MovieItem*) notification.object;
	NSUInteger rowIndex = [self findRowForMovieItem: movieItem];
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
	UITableViewCell* cell = [self.tableView cellForRowAtIndexPath: indexPath];
	if (cell != nil)
		 cell.imageView.image = movieItem.thumbIcon;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (_filteredEntries == nil)
		return self.moviesCatalog.movies.count;
	else
		return _filteredEntries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									  reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    MovieItem* movieItem = [self movieItemForRow: indexPath.row];

    // Configure the cell.
    cell.textLabel.text = [NSString stringWithFormat:@"%ld - %@", indexPath.row + 1, movieItem.title];
	if (movieItem.thumbIcon != nil)
		cell.imageView.image = movieItem.thumbIcon;
	else
	{
		cell.imageView.image = [UIImage imageNamed:@"PlaceholderCell.png"];
		if (!tableView.decelerating)
			[movieItem loadThumbIcon];
	}
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    MovieItem* movieItem = [self movieItemForRow: indexPath.row];
    if (movieItem != nil)
        [self performSegueWithIdentifier: @"DetailedView" sender: movieItem];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"DetailedView"])
    {
        if ([segue.destinationViewController isKindOfClass:[DetailedViewController class]] &&
            [sender isKindOfClass:[MovieItem class]] )
        {
            DetailedViewController* detailController = (DetailedViewController*)segue.destinationViewController;
            MovieItem* movieItem = (MovieItem*)sender;
            detailController.movieItem = movieItem;
        }
    }
}

#pragma mark -
#pragma mark Search bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	
	// called when text changes (including clear)
	NSUInteger moviesCount = 0;
	
	if (searchText.length == 0)
	{
		self.filteredEntries = nil;
		moviesCount = self.moviesCatalog.movies.count;
	}
	else
	{
		NSMutableArray* newFilteredItems = [NSMutableArray new];
		for (MovieItem* movieItem in self.moviesCatalog.movies)
		{
			NSRange range = [movieItem.title rangeOfString: searchText options: NSCaseInsensitiveSearch];
			if (range.length > 0)
				[newFilteredItems addObject:movieItem];
		}
		self.filteredEntries = newFilteredItems;
		moviesCount = newFilteredItems.count;
	}
		
	[self.tableView reloadData];
	
	_itemsCountLabel.text = [NSString stringWithFormat:@"%ld movies", moviesCount];
}

#pragma mark -

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadVisibleImages];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadVisibleImages];
}

- (void) loadVisibleImages
{
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in visiblePaths)
	{
		MovieItem* movieItem = [self movieItemForRow: indexPath.row];
		if (movieItem != nil && movieItem.thumbIcon == nil)
			[movieItem loadThumbIcon];
	}
}

#pragma mark -

- (NSUInteger) findRowForMovieItem: (MovieItem*)movieItem
{
	NSArray* movies = _filteredEntries ? _filteredEntries : self.moviesCatalog.movies;
	NSUInteger row = [movies indexOfObject: movieItem];
	return row;
}

- (MovieItem*) movieItemForRow:(NSUInteger)row
{
    if (_filteredEntries == nil)
        return [self.moviesCatalog.movies objectAtIndex:row];
    else
        return [_filteredEntries objectAtIndex:row];
}

- (MovieItem*) queryPrevMovieItem:(MovieItem*)movieItem
{
	NSArray* movies = _filteredEntries ? _filteredEntries : self.moviesCatalog.movies;
	NSUInteger pos = [movies indexOfObject:movieItem];
	if (pos > 0)
		pos--;
	else
		pos = movies.count - 1;
	
	return [movies objectAtIndex:pos];
}

- (MovieItem*) queryNextMovieItem:(MovieItem*)movieItem
{
	NSArray* movies = _filteredEntries ? _filteredEntries : self.moviesCatalog.movies;
	NSUInteger pos = [movies indexOfObject:movieItem];
	pos++;
	if (pos >= movies.count)
		pos = 0;
	
	return [movies objectAtIndex:pos];
}


@end
