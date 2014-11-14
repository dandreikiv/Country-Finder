//
//  CountySelectorViewController.m
//  KML
//
//  Created by Dmytro Andreikiv on 12/11/14.
//  Copyright (c) 2014 mobile app. All rights reserved.
//

#import "CountySelectorViewController.h"
#import "CountryModel.h"
#import "CountryDatasource.h"
#import "KML.h"

@interface CountySelectorViewController () <CountryDatasourceDelegate>

@property (nonatomic, weak) IBOutlet CountryDatasource * datasource;
@property (nonatomic, weak) IBOutlet UITableView * tableView;

@end

@implementation CountySelectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datasource.delegate = self;
    
    // Do any additional setup after loading the view.
    [self.datasource reloadWithData:[CountryModel sharedModel].folders];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CountryDatasourceDelegate Methods -

- (void)didSelectCountry:(KMLPlacemark *)country
{
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [[NSNotificationCenter defaultCenter] postNotificationName:DidSelectCountryNotificaiton
                                                                                     object:country];
                             }];
}

@end
