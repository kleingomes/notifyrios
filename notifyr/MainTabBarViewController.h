//
//  MainTabBarViewController.h
//  notifyr
//
//  Created by Nelson Narciso on 2014-12-28.
//  Copyright (c) 2014 Nelson Narciso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@interface MainTabBarViewController : UITabBarController

- (void)showArticle:(Article *)article;

@end
