//
//  MapPin.h
//  TwitterSniffer
//
//  Created by Jiatian Li on 3/18/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Tweet.h"

@interface MapPin : NSObject<MKAnnotation>

@property (nonatomic, strong) NSString *title, *subtitle;
@property (nonatomic, strong) Tweet *tweet;
@property CLLocationCoordinate2D coordinate;

@end
