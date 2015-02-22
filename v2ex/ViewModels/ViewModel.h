//
//  ViewModel.h
//  v2ex
//
//  Created by Haven on 8/25/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "RVMViewModel.h"
#import "DataModel.h"

@interface ViewModel : RVMViewModel
@property (nonatomic, readonly, getter=isLoading) BOOL loading;
@property (nonatomic, strong) DataModel *fetchAction;
- (void)fetchData;
@end
