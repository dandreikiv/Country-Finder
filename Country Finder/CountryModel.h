//
//  CountryModel.h
//  KML
//
//  Created by Dmytro Andreikiv on 12/11/14.
//  Copyright (c) 2014 mobile app. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const DidSelectCountryNotificaiton;

@class KMLPlacemark;

@interface CountryModel : NSObject

+ (CountryModel *)sharedModel;

- (void)reloadWithDataURL:(NSURL *)url completionHandler:(void(^)(void))completionHandler;
- (NSDictionary *)folders;

- (KMLPlacemark *)placemarkWithName:(NSString *)name;

@end
