//
//  Config.h
//  v2ex
//
//  Created by Haven on 5/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DBConfig : NSManagedObject

@property (nonatomic, retain) NSString * tableOrService;
@property (nonatomic, retain) NSDate * lastModifyDate;

@end
