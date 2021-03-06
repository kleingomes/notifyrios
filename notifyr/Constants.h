//
//  Constants.h
//  notifyr
//
//  Created by Nelson Narciso on 2014-05-18.
//  Copyright (c) 2014 Nelson Narciso. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

FOUNDATION_EXPORT NSString *const InterestsUpdateNotification;
FOUNDATION_EXPORT NSString *const DeleteInterestNotification;

FOUNDATION_EXPORT NSString *const CompaniesUpdateNotification;
FOUNDATION_EXPORT NSString *const ProductsUpdateNotification;
FOUNDATION_EXPORT NSString *const ArticlesUpdateNotification;

FOUNDATION_EXPORT NSString *const kInterestsSortOrderScore;
FOUNDATION_EXPORT NSString *const kInterestsSortOrderPublishDate;

FOUNDATION_EXPORT NSString *const favouritesNotFoundTopText;
FOUNDATION_EXPORT NSString *const favouritesNotFoundBottomText;
@end
