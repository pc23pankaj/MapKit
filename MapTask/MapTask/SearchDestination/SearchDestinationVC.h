
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchDestinationVC : UIViewController<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>




@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableSearch;

@property(strong,nonatomic)NSMutableArray   *marrSearchItem;



@end

NS_ASSUME_NONNULL_END
