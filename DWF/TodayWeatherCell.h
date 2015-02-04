//
//  TodayWeatherCell.h
//  DWF
//
//  Created by Dmitry Beloborodov on 31/05/14.
//  Copyright (c) 2014 Mobile Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WeatherForecast;

@interface TodayWeatherCell : UITableViewCell

@property (nonatomic, strong) WeatherForecast *weatherForecast;
@property (nonatomic, strong) NSDate *lastSyncDate;

@end
