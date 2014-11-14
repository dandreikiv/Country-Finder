//
//  CountryDatasource.m
//  KML
//
//  Created by Dmytro Andreikiv on 12/11/14.
//  Copyright (c) 2014 mobile app. All rights reserved.
//

#import "CountryDatasource.h"
#import "KML.h"

@interface CountryDatasource()

@property (nonatomic, strong) NSDictionary * folders;
@property (nonatomic, strong) NSArray * sections;
@end

@implementation CountryDatasource

- (void)reloadWithData:(NSDictionary *)data
{
    if (data && [data isKindOfClass:[NSDictionary class]]) {
        self.folders = data;
        self.sections = [[self.folders allKeys] sortedArrayUsingSelector:@selector(compare:)];
    }
}

- (KMLPlacemark *)placeMarkWithIndexPath:(NSIndexPath *)indexPath
{
    NSString * key = self.sections[indexPath.section];
    KMLPlacemark *placemark = self.folders[key][indexPath.row];
    return placemark;
}

#pragma mark - UITableViewDataSource Methods - 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"CountyCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    KMLPlacemark * country = [self placeMarkWithIndexPath:indexPath];
    if (country) {
        cell.textLabel.text = [country name];
    }

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString * key = self.sections[section];
    return [self.folders[key] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sections[section];
}

#pragma mark - UITableViewDelegate Methods - 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(didSelectCountry:)]) {
        
        KMLPlacemark * country = [self placeMarkWithIndexPath:indexPath];
        if (country) {
            [self.delegate didSelectCountry:country];
        }
    }
}

@end

