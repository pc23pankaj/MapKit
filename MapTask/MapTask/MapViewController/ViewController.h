

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate,UITextFieldDelegate>

@property (strong,nonatomic) CLLocationManager              *locationManager;
@property (strong, nonatomic) IBOutlet UITextField          *txtFieldCurrentLocation;
@property (strong, nonatomic) IBOutlet UITextField          *txtFieldDestination;
@property (strong, nonatomic) IBOutlet MKMapView            *mapView;
@property (strong, nonatomic) IBOutlet UILabel              *lblDistanceMeasure;


@property (strong,nonatomic)NSString                        *strDestinationName;

@end

