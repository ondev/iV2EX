//
//  User.h
//  v2ex
//
//  Created by Haven on 7/4/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DataProtocol.h"


@interface DBUser : NSManagedObject<UserModel>

@property (nonatomic, strong) NSDate *cacheInforDate;
@end
