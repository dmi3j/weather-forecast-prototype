//
//  TodayWeatherCell.m
//  DWF
//
//  Created by Dmitry Beloborodov on 31/05/14.
//  Copyright (c) 2014 Mobile Solutions. All rights reserved.
//

#import "TodayWeatherCell.h"
#import "WeatherForecast.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface TodayWeatherCell ()

@property (weak, nonatomic) IBOutlet UILabel *conditionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *conditionIcon;
@property (weak, nonatomic) IBOutlet UILabel *currentTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *minMaxTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastSynLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityTitleLabel;

@end

@implementation TodayWeatherCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    
    self.conditionLabel.hidden =
    self.conditionIcon.hidden =
    self.currentTempLabel.hidden =
    self.minMaxTempLabel.hidden = YES;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.conditionLabel.hidden =
    self.conditionIcon.hidden =
    self.currentTempLabel.hidden =
    self.lastSynLabel.hidden =
    self.cityTitleLabel.hidden =
    self.minMaxTempLabel.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setWeatherForecast:(WeatherForecast *)newWeatherForecast
{
    if (newWeatherForecast && ![newWeatherForecast isEqual:_weatherForecast]) {
        _weatherForecast = newWeatherForecast;
        
        self.conditionLabel.alpha =
        self.conditionIcon.alpha =
        self.currentTempLabel.alpha =
        self.lastSynLabel.alpha =
        self.cityTitleLabel.alpha =
        self.minMaxTempLabel.alpha = 0;
        
        self.conditionLabel.hidden =
        self.conditionIcon.hidden =
        self.currentTempLabel.hidden =
        self.lastSynLabel.hidden =
        self.cityTitleLabel.hidden =
        self.minMaxTempLabel.hidden = NO;
        
        self.conditionLabel.text = _weatherForecast.mainCondition;
        self.cityTitleLabel.text = _weatherForecast.cityName;
        [self.conditionIcon setImageWithURL:_weatherForecast.weatherIconURL];
        self.currentTempLabel.text = [NSString stringWithFormat:@"%.0f°", _weatherForecast.temp.floatValue];
        self.minMaxTempLabel.text = [NSString stringWithFormat:@"%.0f° / %.0f°",
                                     _weatherForecast.tempMin.floatValue,
                                     _weatherForecast.tempMax.floatValue];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"dd.MM.yyyy";
        self.lastSynLabel.text = [NSString stringWithFormat:@"Last sync: %@", [formatter stringFromDate:self.lastSyncDate]];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.conditionLabel.alpha =
            self.conditionIcon.alpha =
            self.currentTempLabel.alpha =
            self.lastSynLabel.alpha =
            self.cityTitleLabel.alpha =
            self.minMaxTempLabel.alpha = 1.0;
        }];
    }
}

@end
