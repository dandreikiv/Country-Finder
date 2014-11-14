//
//  CountryModel.m
//  KML
//
//  Created by Dmytro Andreikiv on 12/11/14.
//  Copyright (c) 2014 mobile app. All rights reserved.
//

#import "CountryModel.h"
#import "KML.h"

NSString * const DidSelectCountryNotificaiton = @"DidSelectCountryNotificaiton";

@interface CountryModel()

@property (nonatomic, strong) NSMutableArray * internalFolders;
@property (nonatomic, strong) NSMutableDictionary * foldersDictionary;

@end

@implementation CountryModel

+ (CountryModel *)sharedModel
{
    static dispatch_once_t onceToken;
    static CountryModel * _instance;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [[self class] new];
        }
    });
    
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.internalFolders = [NSMutableArray new];
        self.foldersDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)reloadWithDataURL:(NSURL *)url completionHandler:(void(^)(void))completionHandler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        KMLRoot *root = [KMLParser parseKMLAtURL:url];
        
        KMLDocument * document = (KMLDocument *)[root feature];
        
        KMLFolder * rootFolder = nil;
        
        if ([document features].count > 0) {
            rootFolder = [document features][0];
        }
        
        for (id feature in rootFolder.features) {
            if ([feature isKindOfClass:[KMLAbstractContainer class]]) {
                [self processContainer:feature];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionHandler) { completionHandler();}
        });
    });
}

- (void)processContainer:(KMLAbstractContainer *)abstracContainer
{
    for (id feature in [abstracContainer features]) {
        
        if ([feature isKindOfClass:[KMLPlacemark class]]) {
            NSMutableArray * placemarks = [self.foldersDictionary objectForKey:[abstracContainer name]];
            if (nil == placemarks) {
                placemarks = @[].mutableCopy;
            }
            [placemarks addObject:feature];
            [self.foldersDictionary setObject:placemarks forKey:[abstracContainer name]];
        }
        else if ([feature isKindOfClass:[KMLFolder class]]) {
            [self processContainer:feature];
        }
    }
}

- (NSDictionary *)folders
{
    return self.foldersDictionary;
}

- (KMLPlacemark *)placemarkWithName:(NSString *)name
{
    for (NSArray * placemarks in self.folders.allValues) {
        for (KMLPlacemark * placemark in placemarks ) {
            if ([[placemark.name lowercaseString] isEqualToString:[name lowercaseString]]) {
                return placemark;
            }
        }
    }
    
    return nil;
}

@end
