//
//  JOMasterViewController.m
//  Oracle
//
//  Created by Joshua Oldenburg on 10/7/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

#import "JOMasterViewController.h"
#import "JODetailViewController.h"
#import "JOImageDetailCell.h"
#import "JONewsFeed.h"
#import "JONewsItem.h"
#import "JONewsFeedInfo.h"
#import "NSString+JOUtilAdditions.h"
#import "UIImageView+AFNetworking.h"

@interface JOMasterViewController () <JONewsFeedDelegate>
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSArray *previousItems;
@property (nonatomic, strong) JONewsFeed *feedParser;
@property (nonatomic, assign) BOOL shouldDoNothing; // Always NO unless testing
@end

@implementation JOMasterViewController

- (void)awakeFromNib {
	if (NSClassFromString(@"JONewsFeedTests")) {
		self.shouldDoNothing = YES;
		return;
	}
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    self.preferredContentSize = CGSizeMake(320.0, 600.0);
		self.clearsSelectionOnViewWillAppear = NO;
	}
	
	self.items = [NSMutableArray array];
	self.tableView.rowHeight = 88.0;
	[self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
	self.navigationItem.title = @"Steinbrenner Oracle";
	self.detailViewController = (JODetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
	[super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.feedURL = [NSURL URLWithString:@"http://oraclenewspaper.com/feed/atom/"];
	self.detailViewController = (JODetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setFeedURL:(NSURL *)feedURL {
	_feedURL = feedURL;
	[self jo_setUpFeedParser];
	[self refreshData];
}

- (void)jo_setUpFeedParser {
	if (!self.feedURL || self.shouldDoNothing) return;
	
	self.feedParser = [[JONewsFeed alloc] initWithFeedURL:self.feedURL delegate:self];
}

- (void)refreshData {
	if (self.shouldDoNothing) return;
	self.previousItems = self.items.copy;
	[self.items removeAllObjects];
	[self.tableView reloadData];
	[self.feedParser start];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	self.detailViewController = segue.destinationViewController;
	self.detailViewController.newsItem = self.items[self.tableView.indexPathForSelectedRow.row];
}

#pragma mark - Util
+ (UIImage *)jo_faviconImage {
	static UIImage *faviconImage;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		faviconImage = [UIImage imageNamed:@"Favicon"];
	});
	return faviconImage;
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.items.count > 0 ? self.items.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	JOImageDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsEntry"];
    if (cell == nil) {
        cell = [[JOImageDetailCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"NewsEntry"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	if (self.items.count == 0) {
		cell.titleLabel.text = @"Loading...";
		cell.textView.text = @"";
		cell.largeImageView.image = self.class.jo_faviconImage;
		return cell;
	}
	
    JONewsItem *item = self.items[indexPath.row];
	cell.titleLabel.text = item.title.stringByDecodingHTMLEntities;
	cell.textView.text = item.summary.stringByDecodingHTMLEntities;
	cell.largeImageView.contentMode = UIViewContentModeScaleAspectFit;
	JOMasterViewController *_self = self;
	[item getImageURLsWithCallback:^(NSArray *imageURLs) {
		JOImageDetailCell *_cell = (JOImageDetailCell *)[_self.tableView cellForRowAtIndexPath:indexPath];
		if (!_cell || !imageURLs || imageURLs.count == 0) return;
		[_cell.largeImageView setImageWithURL:[NSURL URLWithString:[(NSString *)imageURLs[0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:_self.class.jo_faviconImage]; // This caches for us, and jo_faviconImage is lazy loading and caching
	}];
    return cell;
}

#pragma mark - NSTableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		self.detailViewController.newsItem = self.items[indexPath.row];
	}
}

#pragma mark - MWFeedParserDelegate
- (void)newsFeed:(JONewsFeed *)newsFeed didParseItem:(JONewsItem *)newsItem {
	// No-op, heavy lifting with animations and such is done in newsFeedDidFinishParsing:
}

- (void)newsFeedDidStartDownload:(JONewsFeed *)newsFeed {
	[self.refreshControl beginRefreshing];
	[self.tableView beginUpdates];
}
- (void)newsFeedDidFinishParsing:(JONewsFeed *)newsFeed {
	[self.refreshControl endRefreshing];
	
	[self.items setArray:self.feedParser.newsItems];
	for (JONewsItem *newsItem in self.items) {
		if (self.previousItems.count == 0) {
			[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
		} else {
			[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.items indexOfObjectIdenticalTo:newsItem] inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
		}
	}
	
	[self.tableView endUpdates];
}
- (void)newsFeed:(JONewsFeed *)newsFeed didFailWithError:(NSError *)error {
	[self.refreshControl endRefreshing];
	[self.tableView endUpdates];
	NSLog(@"Failed with error: %@", error);
}

@end
