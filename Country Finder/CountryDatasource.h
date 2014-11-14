//
//  CountryDatasource.h
//  KML
//
//  Created by Dmytro Andreikiv on 12/11/14.
//  Copyright (c) 2014 mobile app. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KMLPlacemark;

@protocol CountryDatasourceDelegate <NSObject>

- (void)didSelectCountry:(KMLPlacemark *)country;

@end

@interface CountryDatasource : NSObject <UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, weak) id<CountryDatasourceDelegate> delegate;

/**
 Data is array of Folders. Each folder represents a range of countries, A - B, C - D, etc.
 Folderes will be shown as list of sections with range ("A-B") in title and list of countries within a section.
 */
- (void)reloadWithData:(NSArray *)data;

@end
