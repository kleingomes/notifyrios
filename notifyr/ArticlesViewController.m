//
//  InterestArticlesViewController.m
//  notifyr
//
//  Created by Nelson Narciso on 2014-07-14.
//  Copyright (c) 2014 Nelson Narciso. All rights reserved.
//

#import "ArticlesViewController.h"
#import "Biz.h"
#import "Constants.h"
#import "ArticleCell.h"
#import "Article.h"
#import "ArticleWebViewController.h"
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import "UIViewController+ECSlidingViewController.h"
#import "ItemArticleFetcher.h"
@interface ArticlesViewController ()

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) id articleObserver;
@property (nonatomic, strong) NSString *sortOrder;
@property (nonatomic) NSInteger pageNumber;
@property (nonatomic) NSInteger pageSize;
@property (nonatomic) BOOL loading;
@property (nonatomic) BOOL loadedAllPages;
@property (weak, nonatomic) IBOutlet UIView *nothingFoundView;
@property (weak, nonatomic) IBOutlet UIView *popularNewestView;
@property (weak, nonatomic) IBOutlet UINavigationItem *topNavigationBar;

@end


@implementation ArticlesViewController

#define SORT_SEGMENTED_CONTROL_POPULAR 0
#define SORT_SEGMENTED_CONTROL_NEWEST 1


- (NSMutableArray *)items
{
    if (!_items)
    {
        _items = [[NSMutableArray alloc] init];
        [self initItems];
    }
    return _items;
}

- (void)initItems
{
    self.pageNumber = 0;
    [self loadArticles];
    
}

- (void)loadArticles
{
    
    [self startLoading];
    [self.delegate getArticlesWithSkip:self.pageNumber * self.pageSize take:self.pageSize sortBy:self.sortOrder completion:^(NSArray *articles, NSError *error) {
        if (self.pageNumber == 0)
        {
            [self.items removeAllObjects];
        }
        [self.items addObjectsFromArray:articles];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self endLoading];
            [self.tableView reloadData];
        });
    }];
}

- (void)startLoading {
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.frame  = CGRectInset(activityIndicatorView.frame, 0.0f, -20.0f);
    self.tableView.tableFooterView = activityIndicatorView;
    [activityIndicatorView startAnimating];
    self.loading = YES;
}

- (void)endLoading {
    self.loading = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.pageNumber++;
}

- (void)initObserver
{
    return;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    
    self.articleObserver = [center addObserverForName:ArticlesUpdateNotification object:nil
                                                 queue:mainQueue usingBlock:^(NSNotification *notification) {
                                                     NSArray *articles = notification.userInfo[@"articles"];
                                                     
                                                     NSLog(@"Got %lu articles", (unsigned long)[articles count]);
                                                     
                                                     [self.items addObjectsFromArray: articles];
                                                     [self.refreshControl endRefreshing];
                                                     [self.tableView reloadData];
                                                 }];
}


- (void)refreshAction
{
    [self initItems];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"ShowArticle"])
    {
        ArticleWebViewController *vc = (ArticleWebViewController *)segue.destinationViewController;
        Article *article = self.items[[self.tableView indexPathForSelectedRow].row];
        vc.article = article;
    }
}
- (UIColor *)getUIColorObjectFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha
{
    // Convert hex string to an integer
    unsigned int hexint = [self intFromHexString:hexStr];
    
    // Create color object, specifying alpha as well
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:alpha];
    
    return color;
}
- (unsigned int)intFromHexString:(NSString *)hexStr
{
    unsigned int hexInt = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    
    // Scan hex value
    [scanner scanHexInt:&hexInt];
    
    return hexInt;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    

    

    
    self.pageSize = 20;
    

    
    if ([self.navigationController.viewControllers count] > 1)
    {
       self.navigationItem.leftBarButtonItem = nil;
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.sortOrder = kInterestsSortOrderPublishDate;
        
    self.navigationItem.title = [self.delegate getTitle];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.tableView.estimatedRowHeight = 350;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"  " style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    if([self.delegate isKindOfClass:[ItemArticleFetcher class]])
    {
        ItemArticleFetcher *itemArticleFetcher  = (ItemArticleFetcher *) self.delegate;
        if(itemArticleFetcher.item.primaryBackgroundColour != nil && itemArticleFetcher.item.primaryBackgroundColourAlt != nil)
        {
            NSLog(itemArticleFetcher.item.primaryBackgroundColour);
            UIColor *lightColoir = [self getUIColorObjectFromHexString:itemArticleFetcher.item.primaryBackgroundColour alpha:1];
            UIColor *darkColour = [self getUIColorObjectFromHexString:itemArticleFetcher.item.primaryBackgroundColourAlt alpha:1];
            self.navigationController.navigationBar.barTintColor = lightColoir;
            //   self.navigationController.navigationBar.tintColor = darkColour;
            self.navigationController.navigationBar.translucent = NO;
            _popularNewestView.backgroundColor = darkColour;
        }
       
    }
    //// TODO: get this from database
//    UIColor *darkColour;
//    UIColor *lightColoir;
//    if([[self.delegate getTitle] isEqualToString:@"nVidia"]){
//        lightColoir = [self getUIColorObjectFromHexString:@"66B003" alpha:1];
//        darkColour = [self getUIColorObjectFromHexString:@"66A003" alpha:1];
//        self.navigationController.navigationBar.barTintColor = lightColoir;
//        //   self.navigationController.navigationBar.tintColor = darkColour;
//        self.navigationController.navigationBar.translucent = NO;
//        _popularNewestView.backgroundColor = darkColour;
//    }
//    if([[self.delegate getTitle] isEqualToString:@"Xiaomi"]){
//        lightColoir = [self getUIColorObjectFromHexString:@"f1641a" alpha:1];
//        darkColour = [self getUIColorObjectFromHexString:@"cc4e0c" alpha:1];
//        self.navigationController.navigationBar.barTintColor = lightColoir;
//        //   self.navigationController.navigationBar.tintColor = darkColour;
//        self.navigationController.navigationBar.translucent = NO;
//        _popularNewestView.backgroundColor = darkColour;
//    }
//    if([[self.delegate getTitle] isEqualToString:@"Nintendo"]){
//        lightColoir = [self getUIColorObjectFromHexString:@"ff0000" alpha:1];
//        darkColour = [self getUIColorObjectFromHexString:@"cc0000" alpha:1];
//        self.navigationController.navigationBar.barTintColor = lightColoir;
//        //   self.navigationController.navigationBar.tintColor = darkColour;
//        self.navigationController.navigationBar.translucent = NO;
//        _popularNewestView.backgroundColor = darkColour;
//    }
//    if([[self.delegate getTitle] isEqualToString:@"Baidu"]){
//        lightColoir = [self getUIColorObjectFromHexString:@"3333ff" alpha:1];
//        darkColour = [self getUIColorObjectFromHexString:@"ff0000" alpha:1];
//        self.navigationController.navigationBar.barTintColor = lightColoir;
//        //   self.navigationController.navigationBar.tintColor = darkColour;
//        self.navigationController.navigationBar.translucent = NO;
//        _popularNewestView.backgroundColor = darkColour;
//    }
//    if([[self.delegate getTitle] isEqualToString:@"Alibaba"]){
//        lightColoir = [self getUIColorObjectFromHexString:@"E37F2B" alpha:1];
//        darkColour = [self getUIColorObjectFromHexString:@"D2691E" alpha:1];
//        self.navigationController.navigationBar.barTintColor = lightColoir;
//        //   self.navigationController.navigationBar.tintColor = darkColour;
//        self.navigationController.navigationBar.translucent = NO;
//        _popularNewestView.backgroundColor = darkColour;
//    }
//    if([[self.delegate getTitle] isEqualToString:@"Apple"]){
//        lightColoir = [self getUIColorObjectFromHexString:@"cccccc" alpha:1];
//        darkColour = [self getUIColorObjectFromHexString:@"666666" alpha:1];
//        self.navigationController.navigationBar.barTintColor = lightColoir;
//        //   self.navigationController.navigationBar.tintColor = darkColour;
//        self.navigationController.navigationBar.translucent = NO;
//        _popularNewestView.backgroundColor = darkColour;
//    }
//    if([[self.delegate getTitle] isEqualToString:@"AMD"]){
//        lightColoir = [self getUIColorObjectFromHexString:@"338533" alpha:1];
//        darkColour = [self getUIColorObjectFromHexString:@"292c29" alpha:1];
//        self.navigationController.navigationBar.barTintColor = lightColoir;
//        //   self.navigationController.navigationBar.tintColor = darkColour;
//        self.navigationController.navigationBar.translucent = NO;
//        _popularNewestView.backgroundColor = darkColour;
//    }
    [self initObserver];
}

- (void)viewWillDisappear:(BOOL)animated
{
   UIColor *lightColour = [self getUIColorObjectFromHexString:@"346ADC" alpha:1];
   UIColor *darkColour = [self getUIColorObjectFromHexString:@"5197E9" alpha:1];
    self.navigationController.navigationBar.barTintColor = lightColour;
    //   self.navigationController.navigationBar.tintColor = darkColour;
    self.navigationController.navigationBar.translucent = NO;
    _popularNewestView.backgroundColor = darkColour;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self.articleObserver];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.items.count == 0)
    {

        
        self.tableView.backgroundView = _nothingFoundView;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Article *article = self.items[indexPath.row];
    ArticleCell *cell;

    BOOL hasImage = (article.iUrl && [article.iUrl length] > 0);
    if (hasImage)
    {
        BOOL isSmallImage = NO; //[article.iUrl containsString:@"gstatic"]; //TODO: replace this with a property in the article set by the server
        if (isSmallImage)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SmallImageCell" forIndexPath:indexPath];
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NoImageCell" forIndexPath:indexPath];
    }
    
    cell.titleLabel.text = article.title ? article.title : @"[No Title]";
    cell.descriptionLabel.text = article.articleDescription;
    cell.authorLabel.text = article.author ? article.author : @"[No Author]";
    cell.sourceLabel.text = article.source ? article.source : @"[No Source]";
    cell.score.text = [NSString stringWithFormat:@"%.1f", [article.score floatValue]];
    cell.dateLabel.text = [self convertDateToString:article.publishDate];
    //cell.mainImageView.image = nil; //todo replace with default image
    
    if (hasImage)
    {
        [cell.mainImageView setImageWithURL:[NSURL URLWithString:article.iUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error)
            {
                NSLog(@"Invalid Image %@: %@", article.iUrl, [error localizedDescription]);
            }
        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    // Remove the border for the first cell
    if(indexPath.row == 0)
    {
        cell.borderLineView.hidden = true;
    }
    
    return cell;
}

- (NSString *)convertDateToString:(NSDate *)date
{
    NSTimeInterval secondsInDay = 60 * 60 * 24;
    NSTimeInterval secondsInHour = 60 * 60;
    NSTimeInterval secondsInMinute = 60;
    double gmtOffset = 18000;
    NSTimeInterval age = fabs(date.timeIntervalSinceNow-gmtOffset);
    if (age > secondsInDay)
    {
        NSInteger daysAgo = round(age / secondsInDay);
        if(daysAgo > 1)
        {
            return [NSString stringWithFormat:@"%.0f days ago", round(age / secondsInDay)];
        }
        else
        {
            return [NSString stringWithFormat:@"%.0f day ago", round(age / secondsInDay)];
        }
    }
    else
    {
        if (age > secondsInHour)
        {
            NSInteger hoursAgo = round(age / secondsInHour);
            if(hoursAgo > 1)
            {
                return [NSString stringWithFormat:@"%.0f hours ago", round(age / secondsInHour)];
            }
            else
            {
                return [NSString stringWithFormat:@"%.0f hour ago", round(age / secondsInHour)];
            }
            
        }
        else
        {
            NSInteger minutesAgo = round(age / secondsInMinute);
            if(minutesAgo > 1)
            {
                return [NSString stringWithFormat:@"%.0f minutes ago", round(age / secondsInMinute)];
            }
            else
            {
                return [NSString stringWithFormat:@"%.0f minute ago", round(age / secondsInMinute)];
            }
            
        }
    }
}


- (IBAction)menuAction:(id)sender {
    //[self makeBlurredScreenshot];
    
    //self.slidingViewController.delegate = self.zoomController;
    
    
    if ([self.slidingViewController currentTopViewPosition] == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.slidingViewController resetTopViewAnimated:YES];
    }
    else
    {
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
        self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGesturePanning | ECSlidingViewControllerAnchoredGestureTapping;
        
        self.slidingViewController.topViewController.view.layer.shadowOpacity = 0.75f;
        self.slidingViewController.topViewController.view.layer.shadowRadius = 10.0f;
        self.slidingViewController.topViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    }
    
}

- (IBAction)sortChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == SORT_SEGMENTED_CONTROL_POPULAR)
    {
        self.sortOrder = kInterestsSortOrderScore;
    }
    else if (sender.selectedSegmentIndex == SORT_SEGMENTED_CONTROL_NEWEST)
    {
        self.sortOrder = kInterestsSortOrderPublishDate;
    }
    [self initItems];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Add Favourite" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        Article *article = self.items[indexPath.row];
        [[Biz sharedBiz] addFavourite:article withCompletionHandler:^(NSError *error) {
            NSLog(@"added");
        }];
        NSLog(@"action 1 pressed");
        [tableView setEditing:NO animated:YES];
        
    }];
    
    UITableViewRowAction *action2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Remove Favourite" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        Article *article = self.items[indexPath.row];
        [[Biz sharedBiz] deleteFavourite:article withCompletionHandler:^(NSError *error) {
            NSLog(@"added");
        }];
        NSLog(@"action 2 pressed");
        [tableView setEditing:NO animated:YES];
        
    }];
    action2.backgroundColor = [UIColor blueColor];
    
    return @[action1, action2];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGPoint offset = sender.contentOffset;
    CGRect bounds = sender.bounds;
    CGSize size = sender.contentSize;
    UIEdgeInsets inset = sender.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    float reloadDistance = 10.0f;
    if (y > h + reloadDistance && !self.loading && !self.loadedAllPages)
    {
        [self loadArticles];
    }
}


@end
