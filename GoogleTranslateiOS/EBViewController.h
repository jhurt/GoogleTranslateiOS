//
//  EBViewController.h
//  GoogleTranslateiOS
//
//  Created by Jason Hurt on 5/9/13.
//  Copyright (c) 2013 8byte8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EBViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UILabel *outputLabel;

- (IBAction)didTouchTranslate:(id)sender;


@end
