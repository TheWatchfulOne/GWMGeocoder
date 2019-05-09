//
//  GWMGeocoderController.h
//  GWMKit
//
//  Created by Gregory Moore on 5/26/15.
//  Copyright (c) 2015 Gregory Moore, Inc. All rights reserved.
//

@import Foundation;
@import CoreLocation;

#if TARGET_IPHONE_SIMULATOR
@import UIKit;
#elif TARGET_OS_IPHONE
@import UIKit;
#elif TARGET_OS_MAC
@import AppKit;
#endif

NS_ASSUME_NONNULL_BEGIN

#pragma mark Notification Names
///@brief Posted when a placemark is returned from a reverse geocoding process.
extern NSNotificationName const GWMGeocoderControllerDidUpdatePlacemarkNotification;
///@brief Posted when a location is returned from a forward geocoding process.
extern NSNotificationName const GWMGeocoderControllerDidUpdateLocationNotification;
///@brief Posted when a geocoder error occurs.
extern NSNotificationName const GWMGeocoderControllerDidFailWithErrorNotification;
#pragma mark Notification UserInfo Keys
///@brief A NSString key for retrieving the current CLPlacemark from a NSNotification userInfo dictionary.
extern NSString * const GWMGeocoderControllerCurrentPlacemark;
///@brief A NSString key for retrieving the previous CLPLacemark from a NSNotification userInfo dictionary.
extern NSString * const GWMGeocoderControllerPreviousPlacemark;
///@brief A NSString key for retrieving the current CLLocation from a NSNotification userInfo dictionary.
extern NSString * const GWMGeocoderControllerCurrentLocation;
///@brief A NSString key for retrieving the NSError from a NSNotification userInfo dictionary.
extern NSString * const GWMGeocoderControllerError;
/*!
 * @brief This block gets called when a geocoding request is completed.
 * @param placemarks A NSArray of CLPlacemark ojects representing the most recent result of the geocoding request. This parameter will be nil if there is an error.
 * @param error A NSError object. This parameter will be nil if there is no error.
 */
typedef void (^GWMGeocoderCompletionBlock)(NSArray<CLPlacemark*> *_Nullable placemarks, NSError *_Nullable error);
/*!
 * @class GWMGeocoderController
 * @discussion Use an instance of this class to interact with an instance of CLGeocoder. This class also  contains some convenience methods for determining any differences between the previous and current placemarks.
 */
@interface GWMGeocoderController : NSObject {
    
    CLGeocoder *_geocoder;

}
///@brief A CLPlacemark object representing the most recent successful geocode result.
@property (nonatomic, readonly) CLPlacemark *_Nullable currentPlacemark;
///@brief A CLPlacemark object representing the previous successful geocode result.
@property (nonatomic, readonly) CLPlacemark *_Nullable previousPlacemark;
///@brief A CLLocation object representing the most recently acquired location.
@property (nonatomic, readonly) CLLocation *_Nullable location;

#pragma mark - Life Cycle

///@discussion The shared GWMGeocoderController instance.
+(instancetype)sharedController;
/*!
 * @brief Forward geocode a street address to get a location.
 * @discussion Passing nil to the completion parameter will cause a NSNotification to be posted when the geocode process finishes. The posted notification's userInfo dictionary will contain the results of the geocode. If the completion paramter is not nil, then a NSNotification will not be posted.
 * @param addressDictionary A NSDictionary object whose entries represent components of the street address to get a location.
 * @param completion A GWMGeocoderCompletionBlock. This block takes a NSArray of CLPlacemarks and a NSError object as arguments and returns void.
 */
-(void)geocodeAddressDictionary:(NSDictionary *)addressDictionary completion:(
GWMGeocoderCompletionBlock _Nullable)completion;
/*!
 * @brief Forward geocode a street address to get a location.
 * @discussion Passing nil to the completion parameter will cause a NSNotification to be posted when the geocode process finishes. The posted notification's userInfo dictionary will contain the results of the geocode. If the completion paramter is not nil, then a NSNotification will not be posted.
 * @param addressString A NSString representation of a street address to get a location for.
 * @param completion A GWMGeocoderCompletionBlock. This block takes a NSArray of CLPlacemarks and a NSError object as arguments and returns void.
 */
-(void)geocodeAddressString:(NSString *)addressString completion:(GWMGeocoderCompletionBlock _Nullable)completion;
/*!
 * @brief Reverse geocode a location to get a street address.
 * @discussion Passing nil to the completion parameter will cause a NSNotification to be posted when the geocode process finishes. The posted notification's userInfo dictionary will contain the results of the geocode. If the completion paramter is not nil, then a NSNotification will not be posted.
 * @param location A CLLocation object representing the location to get a street address for.
 * @param completion A GWMGeocoderCompletionBlock. This block takes a NSArray of CLPlacemarks and a NSError object as arguments and returns void.
 */
-(void)reverseGeocodeLocation:(CLLocation *)location completion:(GWMGeocoderCompletionBlock _Nullable)completion;
///@discussion Cancels the current pending geocode request.
-(void)cancelGeocode;

#pragma mark - Convenience
/*!
 *@brief Compares the administrativeArea property of the current and previous placemarks.
 *@return A BOOL value. YES if the values are differnet.
 */
-(BOOL)didAdministrativeAreaChange;
/*!
 *@brief Compares the subAdministrativeArea property of the current and previous placemarks.
 *@return A BOOL value. YES if the values are differnet.
 */
-(BOOL)didSubAdministrativeAreaChange;
/*!
 *@brief Compares the locality property of the current and previous placemarks.
 *@return A BOOL value. YES if the values are differnet.
 */
-(BOOL)didLocalityChange;
/*!
 *@brief Compares the postalCode property of the current and previous placemarks.
 *@return A BOOL value. YES if the values are differnet.
 */
-(BOOL)didPostalCodeChange;

-(BOOL)isSubAdministrativeAreaEqualToString:(NSString *)string;
-(BOOL)isAdministrativeAreaEqualToString:(NSString *)string;
-(BOOL)isLocalityEqualToString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
