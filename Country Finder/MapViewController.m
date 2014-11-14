//
//  ViewController.m
//  KML
//
//  Created by Dmytro Andreikiv on 12/11/14.
//  Copyright (c) 2014 mobile app. All rights reserved.
//

#import "MapViewController.h"
#import "KML.h"
#import "CountryModel.h"
#import "CountySelectorViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "KML+MapKit.h"

@interface KMLPlacemark (LocationHelper)

- (BOOL)containsLocation:(CLLocation *)location;

@end

@implementation KMLPlacemark(LocationHelper)

- (BOOL)containsLocation:(CLLocation *)location
{
    if ([self.geometry isKindOfClass:[KMLMultiGeometry class]]) {
        
        KMLMultiGeometry * multyGeomentry = (KMLMultiGeometry *)self.geometry;
        
        for (KMLAbstractGeometry * geometry in multyGeomentry.geometries) {
            BOOL result = [geometry constainsLocation:location];
            return result;
        }
        
    } else {
        BOOL result = [self.geometry constainsLocation:location];
        return result;
    }
    
    return NO;
}

@end

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet MKMapView * mapView;
@property (nonatomic, weak) IBOutlet UIButton * countryButton;
@property (nonatomic, strong) CLLocationManager * locationManager;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    
    if (NO == [CLLocationManager locationServicesEnabled]) {
#ifdef __IPHONE_8_0
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
#endif
    }
    
    [self.locationManager startUpdatingLocation];
    
    [self.mapView setShowsUserLocation:YES];
    
    CountryModel * model = [CountryModel sharedModel];
    
    NSString * kmlSourcePath = [[NSBundle mainBundle] pathForResource:@"world-stripped" ofType:@"kml"];
    
    [self.countryButton setTitle:@"Processing..." forState:UIControlStateNormal];
    [self.countryButton sizeToFit];
    
    __weak typeof(self) __self = self;
    [model reloadWithDataURL:[NSURL fileURLWithPath:kmlSourcePath] completionHandler:^{
        [__self.countryButton setEnabled:YES];
        [__self.countryButton setTitle:@"Country" forState:UIControlStateNormal];
        
        [self decodeUserLocation:self.mapView.userLocation.location];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCountrySelectedNotification:)
                                                 name:DidSelectCountryNotificaiton
                                               object:nil];
}

- (void)reloadMapWithCountry:(KMLPlacemark *)placemark
{
    KMLAbstractGeometry * geometry = [placemark geometry];
    
    NSMutableArray * shapes = [NSMutableArray new];
    
    if ([geometry isKindOfClass:[KMLMultiGeometry class]]) {
        
        KMLMultiGeometry * multyGeomentry = (KMLMultiGeometry *)geometry;
        
        for (KMLAbstractGeometry * geometry in multyGeomentry.geometries) {
            [shapes addObject:[geometry mapkitShape]];
        }
        
    } else {
        [shapes addObject:[geometry mapkitShape]];
    }
    
    MKMapRect mapRect;
    
    for (id shape in shapes) {
        if ([shape conformsToProtocol:@protocol(MKOverlay)]) {
            mapRect = [(id<MKOverlay>)shape boundingMapRect];
        }
    }
    
    [self.mapView setVisibleMapRect:mapRect animated:YES];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView addOverlays:shapes];

}

- (void)handleCountrySelectedNotification:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[KMLPlacemark class]]) {
        KMLPlacemark * placemark = (KMLPlacemark *)notification.object;
        [self reloadMapWithCountry:placemark];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MKMapViewDelegate Methods -

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        return [(MKPolyline *)overlay overlayViewForMapView:mapView];
    }
    else if ([overlay isKindOfClass:[MKPolygon class]]) {
        return [(MKPolygon *)overlay overlayViewForMapView:mapView];
    }
    
    return nil;
}

- (void)decodeUserLocation:(CLLocation *)location
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             NSString *identifier = [NSLocale localeIdentifierFromComponents:
                                     [NSDictionary dictionaryWithObject: placemark.ISOcountryCode forKey: NSLocaleCountryCode]];
             NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
             NSString *country = [usLocale displayNameForKey: NSLocaleIdentifier value: identifier];
             
             KMLPlacemark * countryPlacemark = [[CountryModel sharedModel] placemarkWithName:country];
             if (countryPlacemark) {
                 [self reloadMapWithCountry:countryPlacemark];
             }
         }
         else
         {
             NSLog(@"Geocode failed with error %@", error);
             NSLog(@"\nCurrent Location Not Detected\n");
         }
     }];
}


@end

