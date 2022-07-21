//
//  PostCell.h
//  GymBro
//
//  Created by Eric Moran on 7/19/22.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *postImageView;
@property (strong, nonatomic) IBOutlet UILabel *postTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *timestampLabel;
@property (strong, nonatomic) Post *post;

@property (strong, nonatomic) UITableView *tableView;

- (void)setPost;
- (void)setPostImage;

@end

NS_ASSUME_NONNULL_END
