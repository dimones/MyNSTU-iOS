//
//  MNNewsDetailController.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 27.08.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "MNNewsDetailController.h"
#import "MNAPI+Addition.h"
#import "VKSdk.h"
#import <Social/Social.h>
@interface MNNewsDetailController ()
{
    NSDictionary *subjectDictionary;
}
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation MNNewsDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareNews)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    
    // Do any additional setup after loading the view.
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"Подробнее";
    NSString* totalString = [NSString stringWithFormat:@"%@\n\nДата публикации: %@\n\n\t%@",subjectDictionary[@"title"],[subjectDictionary valueForKey:@"pubdate"],[subjectDictionary[@"description"] stringByReplacingOccurrencesOfString:@"\r>" withString:@""]];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:totalString];
    //заголовок
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:19.0f] range:[totalString rangeOfString:subjectDictionary[@"title"]]];
    //F44336
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorFromHexString:@"#000000"] range:[totalString rangeOfString:subjectDictionary[@"title"]]];
    //Дата
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica" size:15.0f] range:[totalString rangeOfString:[NSString stringWithFormat:@"Дата публикации: %@",[subjectDictionary valueForKey:@"pubdate"]]]];
    //Сама новость
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica" size:17.0f] range:[totalString rangeOfString:[subjectDictionary[@"description"] stringByReplacingOccurrencesOfString:@"\r>" withString:@""]]];
    NSString *text = [subjectDictionary[@"description"] stringByReplacingOccurrencesOfString:@"\r<" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"\r>" withString:@"\t"];
    [UIView animateWithDuration:.5f animations:^{
        [_textView setAttributedText:str!=nil?str:@"NULL"];
    }];
}
- (void) setSubjectDictionary:(NSDictionary*)dictionary
{
    subjectDictionary = dictionary;
}
- (void) shareNews
{
    NSString *textToShare = subjectDictionary[@"title"];
    NSURL *myWebsite = [NSURL URLWithString:subjectDictionary[@"link"]];
    NSArray *activityItems = @[textToShare,myWebsite];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:@[[VKActivity new]]];
    
    [activityViewController setValue:@"VK SDK" forKey:@"subject"];
    if (VK_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") && UIUserInterfaceIdiomPad == [[UIDevice currentDevice] userInterfaceIdiom])
    {
        UIPopoverPresentationController *popover = activityViewController.popoverPresentationController;
        popover.sourceView = self.view;
        popover.barButtonItem = self.navigationItem.rightBarButtonItem;
    }
    
    [self presentViewController:activityViewController animated:YES completion:^{
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
