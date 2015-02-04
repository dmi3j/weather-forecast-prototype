//
//  ViewController.m
//  DWF
//
//  Created by Dmitry Beloborodov on 31/05/14.
//  Copyright (c) 2014 Mobile Solutions. All rights reserved.
//

#import "ViewController.h"
#import "TodayWeatherCell.h"
#import <RestKit/RestKit.h>
#import "WeatherForecast.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundWallpaper;
@property (weak, nonatomic) IBOutlet UIImageView *blurredImageView;
@property (weak, nonatomic) IBOutlet UITableView *weatherTableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) RKObjectManager *weatherObjectManager;
@property (nonatomic, strong) WeatherForecast *weatherForecast;
@property (nonatomic, strong) NSDate *lastSyncDate;

@end

#define IS_IPHONE_5         ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define WeakObject(o) __typeof__(o) __weak
#define WeakSelf WeakObject(self)

#define BASE_URL            @"http://api.openweathermap.org/data/2.5"
#define ARCHIVE_FILE        @"WeatherForecast.archive"
#define LAST_SYNC_DATE      @"last-sync-date"

@implementation ViewController

@synthesize lastSyncDate = _lastSyncDate;

#pragma mark - Properties

/*!
 *  Object manager to perform all the HTTP operations with REST objects.
 *
 *  @return RKObjectManager
 */
- (RKObjectManager *)weatherObjectManager
{
    if (!_weatherObjectManager) {
        
        RKLogConfigureByName("RestKit/Network*", RKLogLevelOff);
        RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelOff);
        
        NSURL *baseURL = [NSURL URLWithString:BASE_URL];
        AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
        _weatherObjectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
        
        [_weatherObjectManager addResponseDescriptor:[WeatherForecast responseDescriptor]];
    }
    return _weatherObjectManager;
}

- (UIRefreshControl *)refreshControl
{
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        _refreshControl.tintColor = [UIColor whiteColor];
        [_refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

- (void)setLastSyncDate:(NSDate *)newLastSyncDate
{
    if (![newLastSyncDate isEqualToDate:_lastSyncDate]) {
        _lastSyncDate = newLastSyncDate;

        // save "last synchronized" date
        [[NSUserDefaults standardUserDefaults] setObject:_lastSyncDate forKey:LAST_SYNC_DATE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSDate *)lastSyncDate
{
    if (!_lastSyncDate) {
        // read "last synchronized" date
        [[NSUserDefaults standardUserDefaults] synchronize];
        _lastSyncDate = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_SYNC_DATE];
    }
    return _lastSyncDate;
}

#pragma makr - Lyfecycle 

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    // add refresh element (rotating star) for table view
    [self.weatherTableView addSubview:self.refreshControl];
    
    // add backgrond image based on phone screen size
    NSString *launchImageFileName = IS_IPHONE_5 ? @"LaunchImage-700-568h" : @"LaunchImage-700";
    self.backgroundWallpaper.image = [UIImage imageNamed:launchImageFileName];
    
    // request initial data
    [self.refreshControl beginRefreshing];
    // explicitly start "refresh UI" rotation
    [self handleRefresh:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // show nothing if no "foirecast" available
    return self.weatherForecast ? 1 : 0;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // make the single cell of screen size based on iPhone screen size
    return IS_IPHONE_5 ? 568.0 : 480.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TodayWeatherCell *cell = (TodayWeatherCell *)[tableView dequeueReusableCellWithIdentifier:@"TodayWeatherCell" forIndexPath:indexPath];
    // IMPORTANT: set "last sync" date before weather forecast
    cell.lastSyncDate = self.lastSyncDate;
    cell.weatherForecast = self.weatherForecast;
    
    return cell;
}

#pragma mark - 

- (void)displayWarning
{
    /// TODO: localise message
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                    message:@"Sorry, no data available. Try later."
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)handleRefresh:(id)sender
{
    WeakSelf weakSelf = self;

    [self getForecastForDublinWithsuccess:^(WeatherForecast *forecast) {
        
        if (forecast) {
            weakSelf.weatherForecast = forecast;
            [weakSelf.weatherTableView reloadData];
        } else {
            [self displayWarning];
        }
        [weakSelf.refreshControl endRefreshing];
        
    } failure:^(NSError *error) {
        
        [self displayWarning];
        [weakSelf.refreshControl endRefreshing];
    }];
}

/*!
 *  Get forecast from network (if avaialble) or from cache
 *
 *  @param success Returns forecast from network or cache
 *  @param failure Fail only if no network available and no cache available
 */
- (void)getForecastForDublinWithsuccess:(void (^)(WeatherForecast *forecast))success
                                failure:(void (^)(NSError *error))failure
{
    // hardcode values from request
    NSString *requestPath = @"/data/2.5/weather";
    NSDictionary *requestParameters = @{@"q": @"Dublin,ie",
                                        @"units" : @"metric",
                                        @"mode" : @"json"};
    
    __block WeatherForecast *forecast = nil;
    // "weak" hack used to avoid crash in ARC world (block may be executed when controller is "released"
    WeakSelf weakSelf = self;
    
    [self.weatherObjectManager getObject:nil
                                    path:requestPath
                              parameters:requestParameters
                                 success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
     {
         forecast = mappingResult.firstObject;
         if (forecast) {
             [weakSelf saveWeatherForecastToDisk:forecast];
             weakSelf.lastSyncDate = [NSDate date];
             success(forecast);
         } else {
             failure(operation.error);
         }
     }
                                 failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         forecast = [weakSelf readWeatherForecastFromDisk];
         if (forecast) {
             success(forecast);
         } else {
             failure(error);
         }
     }];
}

#pragma mark - Caching 

/*!
 *  Reads 'WeatherForecast' from disk cache
 *
 *  @return Object of class 'WeatherForecast'
 */
- (WeatherForecast *)readWeatherForecastFromDisk
{
    WeatherForecast *resultValue = nil;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:docDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:docDir withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    NSString *dataPath = [docDir stringByAppendingPathComponent:ARCHIVE_FILE];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        resultValue = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
    }
    
    return resultValue;
}

/*!
 *  Save 'WeatherForecast' to disk. No encryption.
 *
 *  @param weatherForecast The object of class 'WeatherForecast'
 */
- (void)saveWeatherForecastToDisk:(WeatherForecast *)weatherForecast
{
    // nothing to do if no object parsed
    if (!weatherForecast) return;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:docDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:docDir withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    [NSKeyedArchiver archiveRootObject:weatherForecast toFile:[docDir stringByAppendingPathComponent:ARCHIVE_FILE]];
}

@end
