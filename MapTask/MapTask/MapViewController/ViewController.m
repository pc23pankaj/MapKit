
#import "ViewController.h"
#import "SearchDestinationVC.h"


CLLocationCoordinate2D destinationCoordinates;
CLLocationCoordinate2D currentCoordinates;
typedef void(^addressCompletion)(NSString *);

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    _lblDistanceMeasure.hidden = YES;
     [self startUserLocationSearch];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    MKCoordinateRegion mapRegion;
    mapRegion.center = self.mapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.2;
    mapRegion.span.longitudeDelta = 0.2;
    
    [self.mapView setRegion:mapRegion animated: YES];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    self.navigationController.navigationBarHidden = NO;
    //FUNCTION TO GET USER CURRENT LOCATION AND UPDATE ON 1. TextField i.e USER CURRENT LOCATION
    [self startUserLocationSearch];
    if (_strDestinationName !=nil) {
        _txtFieldDestination.text = _strDestinationName;
        [self searchRequestForDestinationLocation];
        CLGeocoder *geocoder = [CLGeocoder new];
        [geocoder geocodeAddressString:_txtFieldDestination.text completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            
            if (error) {
                NSLog(@"Error: %@", [error localizedDescription]);
                return;
            }
            
            if ([placemarks count] > 0) {
                CLPlacemark *placemark = [placemarks lastObject];
//                NSLog(@"Location is: %@", placemark.location);
                CLLocation *destiLocation = placemark.location;
                destinationCoordinates = destiLocation.coordinate; // SETTING DESTINATION COORDINATE IN LOCAL VARIABLE
                if (CLLocationCoordinate2DIsValid(destinationCoordinates) && CLLocationCoordinate2DIsValid(currentCoordinates)) {
                    [self drawRoautLines_FromLocation:currentCoordinates ToLocation:destinationCoordinates];
                }
            }
            
        }];
        
        
    }
}

-(void)startUserLocationSearch{
    
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    //Remember your pList needs to be configured to include the location persmission - adding the display message  (NSLocationWhenInUseUsageDescription)
    
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    [_locationManager startUpdatingLocation];
}

#pragma mark - CLLOCATION MANAGER DELEGATE
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    [self.locationManager stopUpdatingLocation];
    CGFloat usersLatitude = self.locationManager.location.coordinate.latitude;
    CGFloat usersLongidute = self.locationManager.location.coordinate.longitude;
    
    MKCoordinateSpan span = MKCoordinateSpanMake(usersLatitude, usersLongidute);
    span.latitudeDelta = 0.001;
    span.longitudeDelta = 0.001;
    
    CLLocation *location = [[CLLocation alloc]initWithLatitude:usersLatitude longitude:usersLongidute];
    currentCoordinates = CLLocationCoordinate2DMake(usersLatitude, usersLongidute);
//    NSLog(@"CurrentCoordinates are latitude:%f &longitude :%f",currentCoordinates.latitude,currentCoordinates.longitude);
    [self getAddressFromLocation:location complationBlock:^(NSString *address) {
        if(address) {
            self.txtFieldCurrentLocation.text = address;
//            NSLog(@"Current Location is:%@ and comming from complitionBlock %@",self.txtFieldCurrentLocation.text,address);
            
            
        }
    }];
    
    CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(usersLatitude, usersLongidute);
    MKCoordinateRegion region = MKCoordinateRegionMake(locationCoordinate,span);
    [_mapView setRegion:region animated:YES];
    _mapView.showsUserLocation = YES;
    
    [self zoomToFitMapAnnotations:_mapView];
    //Now you have your user's co-oridinates
}

-(void)getAddressFromLocation:(CLLocation *)location complationBlock:(addressCompletion)completionBlock
{
    __block CLPlacemark* placemark;
    __block NSString *address = nil;
    
    CLGeocoder* geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error == nil && [placemarks count] > 0)
         {
             placemark = [placemarks lastObject];
             address = [NSString stringWithFormat:@"%@, %@ %@", placemark.name, placemark.postalCode, placemark.locality];
             completionBlock(address);
         }
     }];
}



- (void)drawRoautLines_FromLocation:(CLLocationCoordinate2D)FromLocation ToLocation:(CLLocationCoordinate2D)ToLocation
{
    // REMOVING THE ALREADY ADDED BLUE LINE OVERLAYS IN EXISTING MAP
    [self.mapView removeOverlays:self.mapView.overlays];
    MKPlacemark *source = [[MKPlacemark alloc]initWithCoordinate:FromLocation
                                               addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil]];
    MKMapItem *srcMapItem = [[MKMapItem alloc]initWithPlacemark:source];
    [srcMapItem setName:_txtFieldCurrentLocation.text];
    
    MKPlacemark *destination = [[MKPlacemark alloc]initWithCoordinate:ToLocation
                                                    addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil]];
    MKMapItem *distMapItem = [[MKMapItem alloc]initWithPlacemark:destination];
    [distMapItem setName:_txtFieldDestination.text];
    
    // PERFORMING DIRECTION REQUEST
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    [request setSource:srcMapItem];
    [request setDestination:distMapItem];
    [request setTransportType:MKDirectionsTransportTypeAutomobile];
    
    MKDirections *direction = [[MKDirections alloc]initWithRequest:request];
    
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
     {
         
         
//         NSLog(@"response = %@",response);
         NSLog(@"error = %@",error);
         NSArray *arrRoutes = [response routes];
         if (arrRoutes.count == 0)
         {
             //Show Error Message.
         }
         else
         {
             
             
             MKRoute *route = [response.routes objectAtIndex:0];
           
             CGFloat distance =  route.distance;
             
             NSLog(@"distance in KM is : %f", distance/1000);
             
             //CHECK WEATHER DISTANCE IS LESS THAN 10 KM OR NOT
             if (distance/1000 > 10.0) {
                 
                 self.lblDistanceMeasure.hidden = NO;
                 self.lblDistanceMeasure.text = @"";
                 NSString *strDistanceBetweenPoints = [NSString stringWithFormat:@"Distance From %@ to %@ is %f KM",self.txtFieldCurrentLocation.text,self.txtFieldDestination.text,distance/1000];
                 self.lblDistanceMeasure.text = strDistanceBetweenPoints;
                 self.lblDistanceMeasure.numberOfLines = 0;
                 self.lblDistanceMeasure.backgroundColor = [UIColor whiteColor];
                 [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
                 MKMapRect maprect = route.polyline.boundingMapRect;
                 [self.mapView setRegion:MKCoordinateRegionForMapRect(maprect) animated:YES];
                 self.mapView.delegate = self;
                 
             }else
             {
                 UIAlertController * alert=   [UIAlertController
                                               alertControllerWithTitle:@"Alert"
                                               message:@"Distance Should Be More Than 10 K.M"
                                               preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction *ok = [UIAlertAction
                                      actionWithTitle:@"OK"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          [alert dismissViewControllerAnimated:YES completion:nil];
                                      }];
                 [alert addAction:ok];
                 [self presentViewController:alert animated:YES completion:nil];
                 
             }
             
         }
     }];
    
}

// USING RENDERER MAPVIEW DELEGATE FOR GIVING POLYLINE ON MAP VIEW
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    
    MKPolylineRenderer *polyLineRenderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    polyLineRenderer.strokeColor = [UIColor blueColor];
    polyLineRenderer.lineWidth = 3.0f;
    
    return polyLineRenderer;
}


- (void)zoomToFitMapAnnotations:(MKMapView *)mapView {
    
    if ([mapView.annotations count] == 0) return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(id<MKAnnotation> annotation in mapView.annotations) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    
    // Add a little extra space on the sides
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1;
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1;
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}

#pragma MARK- TEXTFIELD DELEGATE

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    
    _lblDistanceMeasure.text = @"";
    _lblDistanceMeasure.hidden = YES;
    // REMOVING ANNOTATION WHICH WAS ADDED EARLIER
    [self.mapView removeAnnotations:self.mapView.annotations];
    if (_txtFieldCurrentLocation.text !=nil) {
        [self searchRequestForCurrentLocation];
    }
    if (_txtFieldDestination.text !=nil) {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SearchDestinationVC * searchController = (SearchDestinationVC *)[storyboard instantiateViewControllerWithIdentifier:@"searchController"];
        [self.navigationController pushViewController:searchController animated:YES];
        
        //        [self searchRequestForDestinationLocation];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [self.view endEditing:YES];
    
    CLGeocoder *geocoder = [CLGeocoder new];

        // GETTING ENTER LOCATION  COORDINATES FOR CURRENT LOCATION
        [geocoder geocodeAddressString:_txtFieldCurrentLocation.text completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            
            if (error) {
                NSLog(@"Error: %@", [error localizedDescription]);
                return;
            }
            
            if ([placemarks count] > 0) {
                CLPlacemark *placemark = [placemarks lastObject];
//                NSLog(@"Location is: %@", placemark.location);
                CLLocation *destiLocation = placemark.location;
                currentCoordinates = destiLocation.coordinate; // SETTING CURRENT COORDINATE IN LOCAL VARIABLE
                
            }
            
        }];

    if (_txtFieldDestination.text != nil){
        // GETTING ENTER LOCATION  COORDINATES FOR DESTINATION LOCATION
        [geocoder geocodeAddressString:_txtFieldDestination.text completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            
            if (error) {
                NSLog(@"Error: %@", [error localizedDescription]);
                return;
            }
            
            if ([placemarks count] > 0) {
                CLPlacemark *placemark = [placemarks lastObject];
//                NSLog(@"Location is: %@", placemark.location);
                CLLocation *destiLocation = placemark.location;
                destinationCoordinates = destiLocation.coordinate; // SETTING DESTINATION COORDINATE IN LOCAL VARIABLE
                
            }
            
        }];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    
    return YES;
}

#pragma mark- DESTINATION BUTTON ACTION
- (IBAction)btnDestinationClicked:(id)sender {
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SearchDestinationVC * searchController = (SearchDestinationVC *)[storyboard instantiateViewControllerWithIdentifier:@"searchController"];
    [self.navigationController pushViewController:searchController animated:YES];
    
}



#pragma mark- SEARCH REQUEST FROM THE TEXTFIELD
-(void)searchRequestForCurrentLocation{
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = _txtFieldCurrentLocation.text;
    
    MKLocalSearch *activeSearch = [[MKLocalSearch alloc]initWithRequest:request];
    
    [activeSearch startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        if (response == nil) {
            NSLog(@"Error is:%@",error);
            
        }else{
            // GETTING LOCATION  RESPONSE FROM COMPLETION HANDLER
            CGFloat newLatitude = response.boundingRegion.center.latitude;
            CGFloat newLongitude = response.boundingRegion.center.longitude;
            
            //NOW CREATING NEW ANNOTATION
            
            MKPointAnnotation *newPointAnnotation = [[MKPointAnnotation alloc] init];
            newPointAnnotation.title = self.txtFieldCurrentLocation.text;
            newPointAnnotation.coordinate = CLLocationCoordinate2DMake(newLatitude, newLongitude);
            [self.mapView addAnnotation:newPointAnnotation];
            
//            NSLog(@"Current coordiantes are Lat:%f and Long:%f ",newPointAnnotation.coordinate.latitude,newPointAnnotation.coordinate.longitude);
            
        }
    }];
}

-(void)searchRequestForDestinationLocation{
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = _txtFieldDestination.text;
    
    MKLocalSearch *activeSearch = [[MKLocalSearch alloc]initWithRequest:request];
    
    [activeSearch startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        if (response == nil) {
            NSLog(@"Error is:%@",error);
            
        }else{
            // GETTING LOCATION  RESPONSE FROM COMPLETION HANDLER
            CGFloat newLatitude = response.boundingRegion.center.latitude;
            CGFloat newLongitude = response.boundingRegion.center.longitude;
            
            //NOW CREATING NEW ANNOTATION
            
            MKPointAnnotation *newPointAnnotation = [[MKPointAnnotation alloc] init];
            newPointAnnotation.title = self.txtFieldDestination.text;
            newPointAnnotation.coordinate = CLLocationCoordinate2DMake(newLatitude, newLongitude);
            [self.mapView addAnnotation:newPointAnnotation];
            
//            NSLog(@"destination coordiantes are Lat:%f and Long:%f ",newPointAnnotation.coordinate.latitude,newPointAnnotation.coordinate.longitude);
        }
    }];
}

@end



