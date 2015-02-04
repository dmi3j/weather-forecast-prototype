//
//  WeatherForecast.h
//  DWF
//
//  Created by Dmitry Beloborodov on 31/05/14.
//  Copyright (c) 2014 Mobile Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;
@class RKResponseDescriptor;

/*!
 *  A class for storing weather forecast.
 */
@interface WeatherForecast : NSObject <NSCoding>

+ (RKObjectMapping *)objectMapping;
+ (RKResponseDescriptor *)responseDescriptor;

@property (nonatomic, copy) NSString *cityName;
@property (nonatomic, strong) NSNumber *humidity;
@property (nonatomic, strong) NSNumber *pressure;
@property (nonatomic, strong) NSNumber *temp;
@property (nonatomic, strong) NSNumber *tempMax;
@property (nonatomic, strong) NSNumber *tempMin;
@property (nonatomic, strong) NSNumber *windSpeed;

@property (nonatomic, readonly) NSString *mainCondition;
@property (nonatomic, readonly) NSString *briefDescription;
@property (nonatomic, readonly) NSURL *weatherIconURL;

@end
