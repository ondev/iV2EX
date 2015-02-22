//
//  PurchaseViewController.m
//  v2ex
//
//  Created by Haven on 5/29/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "PurchaseViewController.h"
#import "UIViewController+V2ex.h"

@interface PurchaseViewController ()

@end

@implementation PurchaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (0 == [self.navigationController.viewControllers indexOfObject:self]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];//[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)restorePurchase:(id)sender {
    [self restorePurchase];
}

- (IBAction)startPurchase:(id)sender {
    [self upgradeToFullVersion];
}

@end
