//
//  QuestionSearchViewController.m
//  StackOverflowClient
//
//  Created by Kristen Kozmary on 9/15/15.
//  Copyright (c) 2015 koz. All rights reserved.
//

#import "QuestionSearchViewController.h"
#import "StackOverflowService.h"
#import "Question.h"

@interface QuestionSearchViewController () <UISearchBarDelegate>
@property (strong, nonatomic) NSArray *questions;
@end

@implementation QuestionSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

  [self searchBarSearchButtonClicked:nil];
}

#pragma mark - UISearchBarDelegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  [StackOverflowService questionsForSearchTerm:searchBar.text completionHandler:^(NSArray *results, NSError *error) {
    if (error) {
      UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
      UIAlertAction *action = [UIAlertAction actionWithTitle:@"Yeah" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:true completion:nil];
      }];
      [alertController addAction:action];
      
      [self presentViewController:alertController animated:true completion:nil];
    } else {
      self.questions = results;
      dispatch_group_t group = dispatch_group_create();
      dispatch_queue_t imageQueue = dispatch_queue_create("com.koz.stackoverflowclient",DISPATCH_QUEUE_CONCURRENT );
      
      for (Question *question in results) {
        dispatch_group_async(group, imageQueue, ^{
          NSString *avatarURL = question.avatarURL;
          NSURL *imageURL = [NSURL URLWithString:avatarURL];
          NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
          UIImage *image = [UIImage imageWithData:imageData];
          question.avatarPic = image;
        });
      }
      
      dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Images Downloaded" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Yeah" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
          [alertController dismissViewControllerAnimated:true completion:nil];
        }];
        [alertController addAction:action];
        
        [self presentViewController:alertController animated:true completion:nil];
        
      });
    }
  }];
}

@end
