//
//  ComposeViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/19/22.
//

#import "ComposeViewController.h"
#import "../Models/Post.h"

@interface ComposeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UITextView *postTextView;

- (IBAction)choosePhoto:(id)sender;
- (IBAction)post:(id)sender;

@property (nonatomic) BOOL hasChosenImage;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.hasChosenImage = NO;
    
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(choosePhoto:)];
    [imageTap setDelegate:self];
    [self.postImageView addGestureRecognizer:imageTap];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info {
    self.postImageView.image = info[UIImagePickerControllerOriginalImage];
    self.hasChosenImage = YES;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)post:(id)sender {
    if (self.hasChosenImage)
    {
        CGSize size = CGSizeMake(1000, 1000);
        self.postImageView.image = [self resizeImage:self.postImageView.image withSize:size];
        [Post postUserImage:self.postImageView.image withCaption:self.postTextView.text withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (!error)
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success!"
                                             message:@"Successfully Created Post"
                                             preferredStyle:UIAlertControllerStyleAlert];

                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                 {}];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
                self.view.window.rootViewController = tabBarController;
            }
            else
            {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
    else
    {
        [Post postWithText:self.postTextView.text withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (!error)
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success!"
                                             message:@"Successfully Created Post"
                                             preferredStyle:UIAlertControllerStyleAlert];

                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                 {}];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
                self.view.window.rootViewController = tabBarController;
            }
            else
            {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

- (IBAction)choosePhoto:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera ???? available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
