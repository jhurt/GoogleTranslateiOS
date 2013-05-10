//
//  EBViewController.m
//  GoogleTranslateiOS
//
//  Created by Jason Hurt on 5/9/13.
//  Copyright (c) 2013 8byte8. All rights reserved.
//

#import "EBViewController.h"
#import "EBTranslateController.h"

@interface EBViewController ()

@end

@implementation EBViewController
{
    EBTranslateController *_translateController;
    NSMutableArray *_sentencesToTranslate;
    NSMutableString *_translation;
}

@synthesize inputTextView = _inputTextView;
@synthesize outputLabel = _outputLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)translate {
    if(_sentencesToTranslate.count > 0) {
        [_translateController beginTranslate:[_sentencesToTranslate objectAtIndex:0] onSuccess:^(NSString *result) {
            [_sentencesToTranslate removeObjectAtIndex:0];
            [_translation appendFormat:@"%@. ", result];
            [self translate];
        } onError:^{
            [_sentencesToTranslate removeObjectAtIndex:0];
            [self translate];
        }];
    }
    else {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        _outputLabel.text = _translation;
    }
}

- (IBAction)didTouchTranslate:(id)sender {
    _translateController = [[EBTranslateController alloc] init];
    _sentencesToTranslate = [NSMutableArray arrayWithArray:[_inputTextView.text componentsSeparatedByString:@"."]];
    _translation = [[NSMutableString alloc] init];
    [self translate];
    _outputLabel.text = _translation;
    [_inputTextView resignFirstResponder];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

@end
