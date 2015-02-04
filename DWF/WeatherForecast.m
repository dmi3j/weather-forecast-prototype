//
//  WeatherForecast.m
//  DWF
//
//  Created by Dmitry Beloborodov on 31/05/14.
//  Copyright (c) 2014 Mobile Solutions. All rights reserved.
//

#import "WeatherForecast.h"
#import <RestKit/RestKit.h>

@interface WeatherForecast ()

@property (nonatomic, strong) NSArray *weatherMainDetails;
@property (nonatomic, readonly) NSString *weatherIcon;

@end

@implementation WeatherForecast

#pragma mark - RestKit

+ (NSDictionary *)mappedProperties
{
    return @{
             @"weather" : @"weatherMainDetails",
             @"name" : @"cityName",
             @"main.humidity" : @"humidity",
             @"main.pressure" : @"pressure",
             @"main.temp" : @"temp",
             @"main.temp_max" : @"tempMax",
             @"main.temp_min" : @"tempMin",
             @"wind.speed" : @"windSpeed"
             };
}

+ (RKObjectMapping *)objectMapping
{
    RKObjectMapping *_objectMapping = [RKObjectMapping mappingForClass:self];
    [_objectMapping addAttributeMappingsFromDictionary:[[self class] mappedProperties]];
    
    return _objectMapping;
}

+ (RKResponseDescriptor *)responseDescriptor
{
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    return [RKResponseDescriptor responseDescriptorWithMapping:[[self class] objectMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:nil
                                                       keyPath:nil
                                                   statusCodes:statusCodes];
}

#pragma mark -

- (NSString *)mainCondition
{
    return [[self.weatherMainDetails firstObject] objectForKey:@"main"];
}

- (NSString *)briefDescription
{
    return [[self.weatherMainDetails firstObject] objectForKey:@"description"];
}

- (NSString *)weatherIcon
{
    return [[self.weatherMainDetails firstObject] objectForKey:@"icon"];
}

- (NSString *)weatherIconURL
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png", self.weatherIcon]];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.weatherMainDetails forKey:@"weatherMainDetails"];
    [encoder encodeObject:self.humidity forKey:@"humidity"];
    [encoder encodeObject:self.pressure forKey:@"pressure"];
    [encoder encodeObject:self.temp forKey:@"temp"];
    [encoder encodeObject:self.tempMax forKey:@"tempMax"];
    [encoder encodeObject:self.tempMin forKey:@"tempMin"];
    [encoder encodeObject:self.windSpeed forKey:@"windSpeed"];
    [encoder encodeObject:self.cityName forKey:@"cityName"];
}

- (id)initWithCoder:(NSCoder *)coder
{
	if (self = [super init])
	{
		self.weatherMainDetails = [coder decodeObjectForKey:@"weatherMainDetails"];
		self.humidity = [coder decodeObjectForKey:@"humidity"];
		self.pressure = [coder decodeObjectForKey:@"pressure"];
		self.temp = [coder decodeObjectForKey:@"temp"];
		self.tempMax = [coder decodeObjectForKey:@"tempMax"];
		self.tempMin = [coder decodeObjectForKey:@"tempMin"];
		self.windSpeed = [coder decodeObjectForKey:@"windSpeed"];
		self.cityName = [coder decodeObjectForKey:@"cityName"];
	}
	return self;
}

@end
