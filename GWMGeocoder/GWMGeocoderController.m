//
//  GWMGeocoderController.m
//  GWMKit
//
//  Created by Gregory Moore on 5/26/15.
//  Copyright (c) 2015 Gregory Moore, Inc. All rights reserved.
//

#import "GWMGeocoderController.h"

#pragma mark Notification Names
NSNotificationName const GWMGeocoderControllerDidUpdatePlacemarkNotification = @"GWMGeocoderControllerDidUpdatePlacemarkNotification";
NSNotificationName const GWMGeocoderControllerDidUpdateLocationNotification = @"GWMGeocoderControllerDidUpdateLocationNotification";
NSNotificationName const GWMGeocoderControllerDidFailWithErrorNotification = @"GWMGeocoderControllerDidFailWithErrorNotification";
#pragma mark Notification UserInfo Keys
NSString * const GWMGeocoderControllerCurrentPlacemark = @"GWMGeocoderControllerCurrentPlacemark";
NSString * const GWMGeocoderControllerPreviousPlacemark = @"GWMGeocoderControllerPreviousPlacemark";
NSString * const GWMGeocoderControllerCurrentLocation = @"GWMGeocoderControllerCurrentLocation";
NSString * const GWMGeocoderControllerError = @"GWMGeocoderControllerError";

@interface GWMGeocoderController()

@property (nonatomic, strong) CLPlacemark *currentPlacemark;
@property (nonatomic, strong) CLPlacemark *previousPlacemark;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, readonly) CLGeocoder *geocoder;

@end

@implementation GWMGeocoderController

#pragma mark - Life Cycle

+(instancetype)sharedController
{
    static GWMGeocoderController *_sharedGeocoderController = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        _sharedGeocoderController = [[self alloc] init];
        //NSLog(@"...dispatched once...");
    });
    return _sharedGeocoderController;
}

-(instancetype)init
{
    if (self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

-(CLGeocoder *)geocoder
{
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

-(void)applicationDidReceiveMemoryWarning
{
    [self cancelGeocode];
    _geocoder = nil;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    _geocoder = nil;
}

#pragma mark - Error Handling

-(void)handleError:(NSError *)error
{
    NSString *errorString = nil;
    
    switch (error.code) {
        case kCLErrorLocationUnknown:
        {
            errorString = @"A location could not be determined at this time.";
            break;
        }
        case kCLErrorDenied:
        {
            errorString = @"A location could not be determined because access to Location Services was denied by the user";
            break;
        }
        case kCLErrorNetwork:
        {
            errorString = @"A location could not be determined because the network is unavailable or there was a network error.";
            break;
        }
        case kCLErrorGeocodeFoundNoResult:
        {
            errorString = @"The Geocoder did not find a result. Please make sure the network is available and try again.";
            break;
        }
        default:
            errorString = @"Unknown Error.";
            break;
    }
    
    NSLog(@"*** Geocoding Error: %@ ***", errorString);
    
    NSDictionary *userInfo = @{GWMGeocoderControllerError: error};
    [[NSNotificationCenter defaultCenter] postNotificationName:GWMGeocoderControllerDidFailWithErrorNotification object:self userInfo:userInfo];
}

#pragma mark - Geocoding

-(void)geocodeAddressDictionary:(NSDictionary *)addressDictionary completion:(GWMGeocoderCompletionBlock)completion
{
    [self.geocoder geocodeAddressDictionary:addressDictionary completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error) {
            
            if (completion)
                completion(nil, error);
            else
                [self handleError:error];
            
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            
            self.previousPlacemark = [[CLPlacemark alloc] initWithPlacemark:self.currentPlacemark];
            self.currentPlacemark = [[CLPlacemark alloc] initWithPlacemark:placemark];
            self.location = placemark.location;
            
            if (completion)
                completion(placemarks, nil);
            else {
                NSDictionary *userInfo = @{GWMGeocoderControllerCurrentPlacemark:self.currentPlacemark,
                                           GWMGeocoderControllerPreviousPlacemark:self.previousPlacemark,
                                           GWMGeocoderControllerCurrentLocation:self.location};
                
                [[NSNotificationCenter defaultCenter] postNotificationName:GWMGeocoderControllerDidUpdateLocationNotification object:self userInfo:userInfo];
            }
        }
    }];
}

-(void)geocodeAddressString:(NSString *)addressString completion:(GWMGeocoderCompletionBlock)completion
{
    [self.geocoder geocodeAddressString:addressString completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error) {
            
            if (completion)
                completion(nil, error);
            else
                [self handleError:error];
            
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            
            self.previousPlacemark = [[CLPlacemark alloc] initWithPlacemark:self.currentPlacemark];
            self.currentPlacemark = [[CLPlacemark alloc] initWithPlacemark:placemark];
            self.location = placemark.location;
            
            if (completion)
                completion(placemarks, nil);
            else {
                NSDictionary *userInfo = @{GWMGeocoderControllerCurrentPlacemark:self.currentPlacemark,
                                           GWMGeocoderControllerPreviousPlacemark:self.previousPlacemark,
                                           GWMGeocoderControllerCurrentLocation:self.location};
                
                [[NSNotificationCenter defaultCenter] postNotificationName:GWMGeocoderControllerDidUpdateLocationNotification object:self userInfo:userInfo];
            }
        }
        
    }];
}

-(void)reverseGeocodeLocation:(CLLocation *)location completion:(GWMGeocoderCompletionBlock)completion
{
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error) {
            
            if (completion)
                completion(nil, error);
            else
                [self handleError:error];
            
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            
            self.previousPlacemark = [[CLPlacemark alloc] initWithPlacemark:self.currentPlacemark];
            self.currentPlacemark = [[CLPlacemark alloc] initWithPlacemark:placemark];
            self.location = placemark.location;
            
            if (completion)
                completion(placemarks, nil);
            else {
                NSDictionary *userInfo = @{GWMGeocoderControllerCurrentPlacemark:self.currentPlacemark,
                                           GWMGeocoderControllerPreviousPlacemark:self.previousPlacemark,
                                           GWMGeocoderControllerCurrentLocation:self.location};
                
                [[NSNotificationCenter defaultCenter] postNotificationName:GWMGeocoderControllerDidUpdatePlacemarkNotification object:self userInfo:userInfo];
            }
        }
    }];
}

#pragma mark - Cancel the Geocode

-(void)cancelGeocode
{
    [self.geocoder cancelGeocode];
}

#pragma mark - Testing placemark properties for changes

-(BOOL)didAdministrativeAreaChange
{
    return ![self.currentPlacemark.administrativeArea isEqualToString: self.previousPlacemark.administrativeArea];
}

-(BOOL)didSubAdministrativeAreaChange
{
    return ![self.currentPlacemark.subAdministrativeArea isEqualToString: self.previousPlacemark.subAdministrativeArea];
}

-(BOOL)didLocalityChange
{
    return ![self.currentPlacemark.locality isEqualToString: self.previousPlacemark.locality];
}

-(BOOL)didPostalCodeChange
{
    return ![self.currentPlacemark.postalCode isEqualToString: self.previousPlacemark.postalCode];
}

-(BOOL)isAdministrativeAreaEqualToString:(NSString *)string
{
    return [self.currentPlacemark.administrativeArea isEqualToString: string];
}

-(BOOL)isSubAdministrativeAreaEqualToString:(NSString *)string
{
    return [self.currentPlacemark.subAdministrativeArea isEqualToString: string];
}

-(BOOL)isLocalityEqualToString:(NSString *)string
{
    return [self.currentPlacemark.locality isEqualToString:string];
}

@end
