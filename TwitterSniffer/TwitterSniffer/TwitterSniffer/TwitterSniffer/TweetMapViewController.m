//
//  TweetMapViewController.m
//  TwitterSniffer
//
//  Created by Jiatian Li on 3/18/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "TweetMapViewController.h"
#import "Tweet.h"
#import "MapPin.h"
#import "TweetContentViewController.h"

#define startLat @"40.809881"
#define startLong @"-73.959746"
#warning Add your own oauth token from foursquare, which you can get from the API docs
#define token @"nba"

//http://search.twitter.com/search.json?q=nba&rpp=15&geocode=40.809881,-73.959746,1mi

@interface TweetMapViewController()

@property (nonatomic, strong) MKMapView *map;
@property (nonatomic, strong) NSMutableArray *tweetArray;
@property (nonatomic, strong) NSMutableArray *pinArray;
@property (nonatomic, strong) CLLocation * currentLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSLock *tweetArrayLock, *mapLock;
@end

@implementation TweetMapViewController

@synthesize map = _map;
@synthesize tweetArray = _tweetArray;
@synthesize pinArray = _pinArray;
@synthesize locationManager = _locationManager;
@synthesize currentLocation = _currentLocation;
@synthesize tweetArrayLock = _tweetArrayLock;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _tweetArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// corelocation :http://www.iosdevnotes.com/2011/10/ios-corelocation-tutorial/
/*
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.currentLocation = newLocation;
    
    if(newLocation.horizontalAccuracy <= 100.0f) { [_locationManager stopUpdatingLocation]; }
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.002, 0.002);
    MKCoordinateRegion region = MKCoordinateRegionMake(_currentLocation.coordinate, span);
    [_map setRegion:region animated:YES];
}*/

/*
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    
    _map = [[MKMapView alloc] initWithFrame:[[self view] frame]];
    [_map setDelegate:self];
    
    /*
    CLLocationCoordinate2D startLocation;
    startLocation.latitude = [startLat floatValue];
    startLocation.longitude = [startLong floatValue];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.002, 0.002);
    MKCoordinateRegion region = MKCoordinateRegionMake(startLocation, span);
    [_map setRegion:region];
    */
    
    _currentLocation = _locationManager.location;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.002, 0.002);
    MKCoordinateRegion region = MKCoordinateRegionMake(_currentLocation.coordinate, span);
    [_map setRegion:region animated:YES];
    
    [[self view] addSubview:_map];
        
    
}

-(void)putPinsOnMap
{
    [_tweetArrayLock lock];
    for (Tweet *tweet in _tweetArray)
    {
        MapPin *pin = [[MapPin alloc] init];
//        tweet.pin = pin;
        pin.tweet = tweet;
        [pin setTitle:[tweet handle]];
        [pin setSubtitle:[tweet text]];
        [pin setCoordinate:[tweet location]];
        //tweet.indexAtPinArray = [_pinArray count];
        //[_pinArray addObject:pin];
        [_map addAnnotation:pin];
    }
    [_tweetArrayLock unlock];
}

-(void)removeAllPinsOnMap
{
    for (id annotation in _map.annotations) {
        [_map removeAnnotation:annotation];
    }
}

-(void)getTweetsForLocation:(CLLocationCoordinate2D)location
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
                   {
                       int index = 0;
                       int page = 15;
                       while (true)
                       {
                           if (_currentLocation.coordinate.latitude - _locationManager.location.coordinate.latitude > 0.0002||
                               _currentLocation.coordinate.longitude - _locationManager.location.coordinate.longitude > 0.0002)
                           {
                               _currentLocation = _locationManager.location;
                               MKCoordinateSpan span = MKCoordinateSpanMake(0.002, 0.002);
                               MKCoordinateRegion region = MKCoordinateRegionMake(_currentLocation.coordinate, span);
                               [_map setRegion:region animated:YES];
                           }
                           NSString *formattedLat = [NSString stringWithFormat:@"%0.2f", _currentLocation.coordinate.latitude];
                           NSString *formattedLong = [NSString stringWithFormat:@"%0.2f", _currentLocation.coordinate.longitude];
                           NSURL *tweetsURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://search.twitter.com/search.json?page=%d&rpp=100&geocode=%@,%@,1mi", page, formattedLat, formattedLong]];
                           page--;
                           if(page == 0)
                               page = 15;
                           NSLog(@"%@", [tweetsURL absoluteString]);
                           NSError *error = nil;
                           NSData *tweetData = [NSData dataWithContentsOfURL:tweetsURL options:0 error:&error];
                           if (error)
                           {
                               NSLog(@"Error getting data: %@", [error description]);
                               return;
                           }
                           NSDictionary *tweetsDict = [NSJSONSerialization JSONObjectWithData:tweetData options:0 error:&error];
                           if (error)
                           {
                               NSLog(@"Error parsing data: %@", [error description]);
                               return;
                           }
                           NSArray *tweetsArray = [tweetsDict objectForKey:@"results"];
                           for (NSDictionary *tweetDict in tweetsArray)
                           {
                               if ([tweetDict objectForKey:@"geo"] == [NSNull null])
                                   continue;
                               Tweet *newTweet = [[Tweet alloc] init];
                               [newTweet setHandle:[tweetDict objectForKey:@"from_user_name"]];
                               [newTweet setText:[tweetDict objectForKey:@"text"]];
                               [newTweet setTweetId:[tweetDict objectForKey:@"id_str"]];
                               
                               [newTweet setTimestamp:[tweetDict objectForKey:@"created_at"]];
                               NSString *avatarURL = [tweetDict objectForKey:@"profile_image_url"];
                               [newTweet setAvatarURL:[NSURL URLWithString:avatarURL]];
                               
                               NSURLResponse *response = nil;
                               NSData *AvatarData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:newTweet.avatarURL] returningResponse:&response error:&error];
                               
                               if(error) {
                                   NSLog(@"Error getting Avatar data: %@", [error description]);
                               }
                               UIImage *Avatar = [UIImage imageWithData:AvatarData];
                               [newTweet setAvatar:Avatar];
                               
                               
                               CLLocationCoordinate2D tweetLocation;
                               NSArray *coordinates = [[tweetDict objectForKey:@"geo"] objectForKey:@"coordinates"];
                               tweetLocation.latitude = [[coordinates objectAtIndex:0] floatValue];
                               tweetLocation.longitude = [[coordinates objectAtIndex:1] floatValue];
                               [newTweet setLocation:tweetLocation];
                               
                               Boolean flag = NO;
                               [_tweetArrayLock lock];
                               for (Tweet *tweet in _tweetArray)
                                   if([tweet.tweetId isEqualToString:newTweet.tweetId])
                                   {
                                       flag = YES;
                                       break;
                                   }
                               if(flag)
                                   continue;
                               
                               if ([_tweetArray count] < 100)
                               {
                                   [_tweetArray addObject:newTweet];
                                   index++;
                               }
                               else
                               {
                                   index %= 100;
                                   //[_map removeAnnotation:[_pinArray objectAtIndex:[[_tweetArray objectAtIndex:index] indexAtPinArray]]];
                                   [_tweetArray replaceObjectAtIndex:index withObject:newTweet];
                                   index++;
                               }
                               [_tweetArrayLock unlock];
                           }
                           
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              [self removeAllPinsOnMap];
                                              [self putPinsOnMap];
                                          });
                           sleep(10);
                       }
                   });
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [_locationManager stopUpdatingLocation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - MKMapViewDelegate methods

-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    [_tweetArrayLock lock];
    if ([_tweetArray count] == 0)
    {
        [self getTweetsForLocation:[_map centerCoordinate]];
    }
    [_tweetArrayLock unlock];
}


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *identifier = @"MapPin";
    if ([annotation isKindOfClass:[MapPin class]])
    {
        MKPinAnnotationView *newPinView = (MKPinAnnotationView *)[_map dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (newPinView == nil)
        {
            newPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            //newPinView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:((MapPin *)(annotation)).tweet.avatar];
            newPinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        } 
        else 
        {
            [newPinView setAnnotation:annotation];
        }
        
        
        [newPinView setEnabled:YES];
        [newPinView setPinColor:MKPinAnnotationColorRed];
        [newPinView setCanShowCallout:YES];
        //[newPinView setAnimatesDrop:YES];
        return newPinView;
    }
    return nil;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [_tweetArrayLock lock];
    if([view.annotation isKindOfClass:[MapPin class]])
    {
        Tweet *tweet = ((MapPin *)(view.annotation)).tweet;
        TweetContentViewController *tweetContentViewController = [[TweetContentViewController alloc] initWithTweet:tweet];
        [[self navigationController] pushViewController:tweetContentViewController animated:YES];
    }
    [_tweetArrayLock unlock];
}

/*
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
    if ([view.rightCalloutAccessoryView isKindOfClass:[UIButton class]])
    {
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    TweetContentViewController *tweetContentViewController = [TweetContentViewController alloc] initWithTweet:<#(Tweet *)#>
}
*/

@end


































