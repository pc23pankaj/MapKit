

#import "SearchDestinationVC.h"
#import "SearchDestinationTVC.h"
#import "MapItemModalClass.h"
#import "ViewController.h"

@interface SearchDestinationVC ()

@end

@implementation SearchDestinationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Search Destination";
   _searchBar.delegate = self;
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc]init];
    searchRequest.naturalLanguageQuery = searchBar.text;
    
    MKLocalSearch *activeSearch = [[MKLocalSearch alloc]initWithRequest:searchRequest];
    
    [activeSearch startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        
        if (response == nil) {
            NSLog(@"Error");
        }
        else if (response.mapItems.count == 0)
        {
            NSLog(@"No Palce Found");
        }
        else{
            
            NSLog(@"response coming is : %@",response);
            
            
//            MKPlacemark *placemark = [[[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) addressDictionary:nil] autorelease];
            
            
//            MKMapItem *mapItem = [[MKMapItem alloc]init];
            
            self.marrSearchItem = [[NSMutableArray alloc] init];
            
            if (!error) {
                self.marrSearchItem = [NSMutableArray array];
                for (MKMapItem *mapItem in [response mapItems]) {
                    [self.marrSearchItem  addObject:mapItem.placemark];
                    NSLog(@"Name: %@, Placemark title: %@", [mapItem name], [[mapItem placemark] title]);
                }
                [self.tableSearch reloadData];
            }
            
            
            
//            if([response.mapItems isKindOfClass:[NSArray class]])
//            {
//                for (int i=0; i<[response.mapItems count]; i++) {
//
//                    NSDictionary *dictResponse = [response.mapItems objectAtIndex:i];
//
//                    MapItemModalClass *objMapItem = [[MapItemModalClass alloc] init];
//                    objMapItem.strName = [dictResponse objectForKey:@"name"];
//                    objMapItem.strPlaceMark = [dictResponse objectForKey:@"placemark"];
//
//
//                }
//            }

            
            
    }
        
    }];
    
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
    return YES;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_marrSearchItem count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"cell";
    SearchDestinationTVC *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                   forIndexPath:indexPath];
    
//    [cell.lblSearchResult setText:[NSString stringWithFormat:@"My Cell at Row %ld",
//                         (long)indexPath.row]];
    
    MKPlacemark *placemark = [_marrSearchItem objectAtIndex:indexPath.row];
    cell.textLabel.text = placemark.name;
    NSString *address = [NSString stringWithFormat:@"%@, %@ ",
                         placemark.locality,
                         placemark.country];
    NSLog(@"%@", address);
    cell.detailTextLabel.text = address;
    
    return cell;
    


}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MKPlacemark *placemark = [_marrSearchItem objectAtIndex:indexPath.row];
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController * mapViewController = (ViewController *)[storyboard instantiateViewControllerWithIdentifier:@"mapViewController"];
    
    
    mapViewController.strDestinationName = [NSString stringWithFormat:@"%@, %@, %@ ",
                                                                         placemark.name,
                                                                         placemark.locality,
                                                                         placemark.country];
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:mapViewController];
    
    //now present this navigation controller modally
    [self presentViewController:navigationController animated:YES completion:nil];
    
    
}

@end
