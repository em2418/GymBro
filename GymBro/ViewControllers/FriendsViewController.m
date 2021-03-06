//
//  FriendsViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/15/22.
//

#import "FriendsViewController.h"
#import "../Models/UserCell.h"
#import "../API/APIManager.h"
#import <Parse/Parse.h>

@interface FriendsViewController () <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;
@property (weak, nonatomic) IBOutlet UITableView *pendingTableView;
@property (weak, nonatomic) IBOutlet UITableView *requestTableView;

@property (strong, nonatomic) NSMutableArray *friendsArray;
@property (strong, nonatomic) NSMutableArray *pendingFriendsArray;
@property (strong, nonatomic) NSMutableArray *friendRequestsArray;

@property (strong, nonatomic) PFUser *currUser;
@property (strong, nonatomic) CLLocation *userLoc;

- (IBAction)goHome:(id)sender;
- (IBAction)refresh:(id)sender;

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.friendsTableView.delegate = self;
    self.friendsTableView.dataSource = self;
    self.friendsTableView.rowHeight = 250;
    
    self.pendingTableView.delegate = self;
    self.pendingTableView.dataSource = self;
    self.pendingTableView.rowHeight = 250;
    
    self.requestTableView.delegate = self;
    self.requestTableView.dataSource = self;
    self.requestTableView.rowHeight = 250;
    
    self.currUser = [PFUser currentUser];
    [self setLocalGym];
    
    [self fetchUsersWithQuery];
    
}

- (void)fetchUsersWithQuery
{
    self.friendsArray = [[NSMutableArray alloc] init];
    self.friendRequestsArray = [[NSMutableArray alloc] init];
    self.pendingFriendsArray = [[NSMutableArray alloc] init];
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" notEqualTo:self.currUser[@"username"]];
    query.limit = 100;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            [self filterFriends:users];
            [self.friendsTableView reloadData];
            [self.requestTableView reloadData];
            [self.pendingTableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    if ([tableView isEqual: self.friendsTableView])
    {
        cell.user = self.friendsArray[indexPath.row];
    }
    else if ([tableView isEqual:self.requestTableView])
    {
        cell.delegate = self;
        cell.rightUtilityButtons = [self rightButtons];
        cell.user = self.friendRequestsArray[indexPath.row];
    }
    else
    {
        cell.user = self.pendingFriendsArray[indexPath.row];
    }
    cell.distanceFromUser = [self getDistance:cell.user];
    cell.controller = self;
    [cell setData];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.friendsTableView])
    {
        return self.friendsArray.count;
    }
    else if ([tableView isEqual:self.requestTableView])
    {
        return self.friendRequestsArray.count;
    }
    else
    {
        return self.pendingFriendsArray.count;
    }
    
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    UIImage *checkImage = [UIImage imageNamed:@"add-user.png"];
    UIImage *rejectImage = [UIImage imageNamed:@"close.png"];
    checkImage = [APIManager imageWithImage:checkImage convertToSize:CGSizeMake(50, 50)];
    rejectImage = [APIManager imageWithImage:rejectImage convertToSize:CGSizeMake(50, 50)];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.0f green:0.0f blue:1.4f alpha:1.0]
                                                 icon:checkImage];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.8f green:0.0f blue:0.0f alpha:1.0]
                                                icon:rejectImage];
    
    return rightUtilityButtons;
}

- (void)swipeableTableViewCell:(UserCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index)
    {
        case 0:
            [self acceptFriendRequest:cell];
            break;
        case 1:
            [self rejectFriendRequest:cell];
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (void)acceptFriendRequest:(UserCell *)cell
{
    PFUser *acceptedUser = cell.user;
    PFUser *user = [PFUser currentUser];
    NSMutableArray *friendsArray = [[NSMutableArray alloc] initWithArray:user[@"friends"]];
    [friendsArray addObject:[acceptedUser valueForKeyPath:@"username"]];
    user[@"friends"] = friendsArray;
    
    NSMutableArray *friendRequestsArray = [[NSMutableArray alloc] initWithArray:user[@"friendRequests"]];
    [friendRequestsArray removeObjectIdenticalTo:[acceptedUser valueForKeyPath:@"username"]];
    user[@"friendRequests"] = friendRequestsArray;
    
    NSMutableArray *otherFriendsArray = [[NSMutableArray alloc] initWithArray:acceptedUser[@"friends"]];
    [otherFriendsArray addObject:[user valueForKeyPath:@"username"]];
    
    NSMutableArray *otherPendingFriendsArray = [[NSMutableArray alloc] initWithArray:acceptedUser[@"pendingFriends"]];
    [otherPendingFriendsArray removeObjectIdenticalTo:[user valueForKeyPath:@"username"]];
    
    NSDictionary *params = @{@"username": [acceptedUser valueForKeyPath:@"username"],
                             @"friends": otherFriendsArray,
                             @"pendingFriends": otherPendingFriendsArray};
    
    [PFCloud callFunctionInBackground:@"acceptFriendRequest" withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
    }];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            NSIndexPath *cellIndexPath = [self.requestTableView indexPathForCell:cell];
            [self.friendRequestsArray removeObjectAtIndex:cellIndexPath.row];
            [self.requestTableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            NSLog(@"Error Sending Friend Request: %@", error.localizedDescription);
        }
    }];
}

- (void)rejectFriendRequest:(UserCell *)cell
{
    PFUser *rejectedUser = cell.user;
    PFUser *user = [PFUser currentUser];
    NSMutableArray *rejectedUsers = [[NSMutableArray alloc] initWithArray:user[@"rejectedUsers"]];
    [rejectedUsers addObject:rejectedUser];
    user[@"rejectedUsers"] = rejectedUsers;
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            NSIndexPath *cellIndexPath = [self.requestTableView indexPathForCell:cell];
            [self.friendRequestsArray removeObjectAtIndex:cellIndexPath.row];
            [self.requestTableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            NSLog(@"Error Rejected User: %@", error.localizedDescription);
        }
    }];
}

- (void)setLocalGym
{
    double latitude = [[self.currUser[@"gym"] valueForKeyPath:@"geocodes.main.latitude"] doubleValue];
    double longitude = [[self.currUser[@"gym"] valueForKeyPath:@"geocodes.main.longitude"] doubleValue];
    self.userLoc = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
}

- (long)getDistance:(PFUser *)userOne
{
    double latitudeOne = [[userOne[@"gym"] valueForKeyPath:@"geocodes.main.latitude"] doubleValue];
    double longitudeOne = [[userOne[@"gym"] valueForKeyPath:@"geocodes.main.longitude"] doubleValue];
    CLLocation *userOneLoc = [[CLLocation alloc] initWithLatitude:latitudeOne longitude:longitudeOne];
    
    return [self.userLoc distanceFromLocation:userOneLoc];
}

- (void)filterFriends:(NSArray *)users
{
    __block BOOL isValidFriend;
    __block BOOL isValidPendingFriend;
    __block BOOL isValidFriendRequest;
    
    NSArray *friends = self.currUser[@"friends"];
    NSArray *pendingFriends = self.currUser[@"pendingFriends"];
    NSArray *friendRequests= self.currUser[@"friendRequests"];
    
    for (PFUser *user in users)
    {
        isValidFriend = NO;
        isValidPendingFriend = NO;
        isValidFriendRequest = NO;
        for (NSString *friend in friends)
        {
            if ([user[@"username"] isEqual:friend])
            {
                isValidFriend = YES;
            }
        }
        for (NSString *request in friendRequests)
        {
            if ([user[@"username"] isEqual:request])
            {
                isValidFriendRequest = YES;
            }
        }
        for (NSString *pendingFriend in pendingFriends)
        {
            if ([user[@"username"] isEqual:pendingFriend])
            {
                isValidPendingFriend = YES;
            }
        }
        if (isValidFriend)
        {
            [self.friendsArray addObject:user];
            [self.friendsTableView reloadData];
        }
        else if (isValidFriendRequest)
        {
            [self.friendRequestsArray addObject:user];
            [self.requestTableView reloadData];
        }
        else if (isValidPendingFriend)
        {
            [self.pendingFriendsArray addObject:user];
            [self.pendingTableView reloadData];
        }
    }
}

- (IBAction)goHome:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)refresh:(id)sender {
    [self fetchUsersWithQuery];
}
@end
