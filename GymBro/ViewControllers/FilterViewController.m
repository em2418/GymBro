//
//  FilterViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/28/22.
//

#import "FilterViewController.h"
#import "UIKit/UIKit.h"
#import "../Models/PriorityCell.h"

@interface FilterViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)confirm:(id)sender;
- (IBAction)setDefaultFilters:(id)sender;


@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 200;
    
    self.workoutType = 3;
    self.workoutTime = 2;
    self.level = 1;
    self.distance1 = 4;
    self.distance2 = 3;
    self.distance3 = 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    PriorityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PriorityCell"];
    cell.filterVC = self;
    cell.indexPath = indexPath;
    
    switch (indexPath.row) {
        case 0:
            NSLog(@"TYPE: %d", self.workoutType);
            cell.traitLabel.text = @"Workout Type:";
            cell.filterValue = self.workoutType;
            break;
        case 1:
            cell.traitLabel.text = @"Workout Time:";
            cell.filterValue = self.workoutTime;
            break;
        case 2:
            cell.traitLabel.text = @"Level:";
            cell.filterValue = self.level;
            break;
        case 3:
            cell.traitLabel.text = @"Within 1 Mile Of Your Gym";
            cell.filterValue = self.distance1;
            break;
        case 4:
            cell.traitLabel.text = @"Within 5 Miles Of Your Gym";
            cell.filterValue = self.distance2;
            break;
        case 5:
            cell.traitLabel.text = @"Within 10 Miles Of Your Gym";
            cell.filterValue = self.distance3;
            break;
        default:
            break;
    }
    [cell setFilter];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



- (IBAction)setDefaultFilters:(id)sender {
    self.workoutType = 3;
    self.workoutTime = 2;
    self.level = 1;
    self.distance1 = 4;
    self.distance2 = 3;
    self.distance3 = 2;
    [self.tableView reloadData];
    
}

- (IBAction)confirm:(id)sender {
    [self.delegate setFiltersWithArray:[[NSArray alloc] initWithObjects:@(self.workoutType), @(self.workoutTime), @(self.level), @(self.distance1), @(self.distance2), @(self.distance3), nil]];
    [self.tableView reloadData];
    NSLog(@"WORKOUT TYPE: %d", self.workoutType);
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
