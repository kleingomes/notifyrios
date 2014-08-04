//
//  ReceivedNotificationViewController.m
//  Notifyr
//
//  Created by Nelson Narciso on 2014-04-18.
//  Copyright (c) 2014 Nelson Narciso. All rights reserved.
//

#import "InterestsViewController.h"
#import "Interest.h"
#import "InterestCell.h"
#import "Biz.h"
#import "ArticlesViewController.h"
#import "Constants.h"
#import "UIImage+ImageEffects.h"
#import "UIViewController+ECSlidingViewController.h"


@interface InterestsViewController ()

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) id interestObserver;

@end


@implementation InterestsViewController

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
    [[Biz sharedBiz] getInterests];
}

- (IBAction)menuAction:(id)sender {
    //[self makeBlurredScreenshot];
    
    if ([self.slidingViewController currentTopViewPosition] == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.slidingViewController resetTopViewAnimated:YES];
    }
    else
    {
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
        self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGesturePanning | ECSlidingViewControllerAnchoredGestureTapping;
    }
}

- (void)makeBlurredScreenshot
{
    //UIGraphicsBeginImageContext(self.view.window.bounds.size);
    //[self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *lightImage = [newImage applyLightEffect];

    [self.view addSubview:[[UIImageView alloc] initWithImage:lightImage]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"ShowInterestArticles"])
    {
        ArticlesViewController *vc = (ArticlesViewController *)segue.destinationViewController;
        Interest *interest = self.items[[self.tableView indexPathForSelectedRow].row];
        vc.interest = interest;
    }
}


- (void)initObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    
    self.interestObserver = [center addObserverForName:InterestsUpdateNotification object:nil
                                                     queue:mainQueue usingBlock:^(NSNotification *notification) {
                                                         NSArray *interests = notification.userInfo[@"interests"];
                                                         
                                                         NSLog(@"Got %lu interests", (unsigned long)[interests count]);
                                                         
                                                         [self updateInterests:interests];
                                                         [self.refreshControl endRefreshing];
                                                         [self.tableView reloadData];
                                                     }];
}

- (void)updateInterests:(NSArray *)updatedInterests
{
    for (Interest *updatedInterest in updatedInterests)
    {
        Interest *foundInterest = nil;
        for (Interest *interest in self.items)
        {
            if ([updatedInterest.interestId isEqualToNumber:interest.interestId])
            {
                foundInterest = interest;
                break;
            }
        }
        if (foundInterest)
        {
            //todo: update interest
        }
        else
        {
            [self.items addObject:updatedInterest];
        }
    }
}

- (void)refreshAction
{
    [[Biz sharedBiz] getInterests];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    if (!_interestObserver)
    {
        [self initObserver];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appTiles2.png"]];
    imageView.frame = self.tableView.frame;
    self.tableView.backgroundView = imageView;
}


- (void)viewWillAppear:(BOOL)animated
{
    //[self refreshAction];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    //[center removeObserver:self.interestObserver];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InterestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InterestCell" forIndexPath:indexPath];
    
    // Configure the cell...
    Interest *interest = self.items[indexPath.row];
    //cell.titleLabel.text = interest.title ? interest.title : @"[No company]";
    cell.companyNameLabel.text = interest.companyName ? interest.companyName : @"[No company]";
    cell.productNameLabel.text = interest.productName ? interest.productName : @"";
    cell.eventTypeLabel.text = [NSString stringWithFormat:@"Type: %@", interest.eventTypeName ? interest.eventTypeName : @"[No Event Type]"];
    
    static NSNumberFormatter *numberFormatter = nil;
    if (!numberFormatter)
    {
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numberFormatter setGroupingSeparator:@","];
    }
    
    cell.stockQuote.text = [numberFormatter stringFromNumber:interest.stockQuote];
    
    //Set image. Check image cache first
    Biz *biz = [Biz sharedBiz];
    if (biz.imageCache[interest.logoUrl])
    {
        cell.logoImageView.image = biz.imageCache[interest.logoUrl];
    }
    else
    {
        //cell.logoImageView = nil; //todo: replace with default image
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:interest.logoUrl]];
            if (imgData) {
                UIImage *image = [UIImage imageWithData:imgData];
                if (image) {
                    //biz.imageCache[interest.logoUrl] = image;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        InterestCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell)
                        {
                            updateCell.logoImageView.image = image;
                        }
                    });
                }
            }
        });
    }
    
    
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    UIView *whiteRoundedCornerView = [[UIView alloc] initWithFrame:CGRectMake(10,10,300,70)];
    whiteRoundedCornerView.backgroundColor = [UIColor whiteColor];
    whiteRoundedCornerView.layer.masksToBounds = NO;
    whiteRoundedCornerView.layer.cornerRadius = 3.0;
    whiteRoundedCornerView.layer.shadowOffset = CGSizeMake(-1, 1);
    whiteRoundedCornerView.layer.shadowOpacity = 0.5;
    [cell.contentView addSubview:whiteRoundedCornerView];
    [cell.contentView sendSubviewToBack:whiteRoundedCornerView];
    
    return cell;
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
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        Interest *interest = self.items[indexPath.row];
        [[Biz sharedBiz] deleteInterest:interest withCompletionHandler:^(NSError *error) {
            NSLog(@"deleted");
        }];
        
        [self.items removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

@end
