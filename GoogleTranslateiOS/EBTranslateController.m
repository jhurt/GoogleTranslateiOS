//
//  EBTranslateController.m
//  GoogleTranslateiOS
//
//  Created by Jason Hurt on 5/9/13.
//  Copyright (c) 2013 8byte8. All rights reserved.
//

#import "EBTranslateController.h"

#define GOOGLE_TRANSLATE_HOST @"translate.google.com"

typedef enum {
    EBTranslateControllerStateNotIntialized,
    EBTranslateControllerStateReady,
    EBTranslateControllerStateTranslating
} EBTranslateControllerState;


@implementation EBTranslateController
{
    UIWebView *_webView;
    EBTranslateControllerState _state;
    NSMutableArray *_sourcesAndCallbacks;
}

- (id)init
{
    self = [super init];
    if (self) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0F, 0.0F, 800.0F, 600.0F)];
        _webView.hidden = YES;
        _webView.delegate = self;
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //override user agent header
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.99 Safari/537.22", @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
        _state = EBTranslateControllerStateNotIntialized;
        _sourcesAndCallbacks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)beginTranslate:(NSString*)sourceText onSuccess:(void (^)(NSString *result))success onError:(void (^)(void))error {
    if(sourceText.length < 3) {
        success(@"");
    }
    else {
        NSDictionary *sourceAndCallback = [NSDictionary dictionaryWithObjectsAndKeys:sourceText, @"source",
                                           [success copy], @"success",
                                           [error copy], @"error", nil];
        [_sourcesAndCallbacks addObject:sourceAndCallback];
        switch(_state) {
            case EBTranslateControllerStateNotIntialized: {
                NSURL *googleTranslateUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", GOOGLE_TRANSLATE_HOST]];
                [_webView loadRequest:[NSMutableURLRequest requestWithURL:googleTranslateUrl]];
                break;
            }
            case EBTranslateControllerStateTranslating:
                //no op
                break;
                
            case EBTranslateControllerStateReady:
                [self doTranslateInWebView];
                break;
        }
    }
}

- (void)doTranslateInWebView {
    if(_sourcesAndCallbacks.count > 0) {
        NSDictionary *sourceAndCallback = [_sourcesAndCallbacks objectAtIndex:0];
        NSString *nextSourceText = [sourceAndCallback objectForKey:@"source"];
        _state = EBTranslateControllerStateTranslating;
        [self translateTextOnNextChange];
        [self injectTranslationString:nextSourceText];
    }
}

- (void)injectTranslationString:(NSString*)source {
    //inject the text to be translated into the source textarea
    NSString *js = [NSString stringWithFormat:@"var source = document.getElementById('source'); " \
                    "source.value = '%@';", source];
    [_webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)translateTextOnNextChange {
    //listen for the onchange for the result box
    NSString *js = @"var resultBox = document.getElementById('result_box'); " \
    "var resultChecks = 0;" \
    "var checkForResult = function() { " \
    "  resultChecks += 1;" \
    "  if(resultChecks > 100) {" \
    "     window.location = 'lu://error/1';" \
    "  }" \
    "  else if(resultBox.childNodes.length < 1) { " \
    "     setTimeout(checkForResult, 50); " \
    "  }" \
    "  else {" \
    "    var translation = ''; " \
    "    for(var i = 0; i < resultBox.childNodes.length; i++) { " \
    "       var text = resultBox.childNodes[i].innerText;" \
    "       if(text) { " \
    "           if(i > 0) { translation += ' '; } " \
    "           translation += text; " \
    "       } " \
    "    }" \
    "    window.location = 'lu://translated/'+translation; " \
    "  }" \
    "};" \
    "setTimeout(checkForResult, 50);";
    [_webView stringByEvaluatingJavaScriptFromString:js];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *scheme = request.URL.scheme;
    NSLog(@"%@", request.URL.description);
    if([scheme isEqualToString:@"lu"]) {
        NSString *host = request.URL.host;
        if([host isEqualToString:@"translated"]) {
            NSString *translationText = [request.URL.pathComponents objectAtIndex:1];
            NSDictionary *sourceAndCallback = [_sourcesAndCallbacks objectAtIndex:0];
            [_sourcesAndCallbacks removeObjectAtIndex:0];
            void (^success)(NSString*) = [sourceAndCallback objectForKey:@"success"];
            success(translationText);
            //NSLog(@"translation: %@", translationText);
            NSURL *googleTranslateUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", GOOGLE_TRANSLATE_HOST]];
            [_webView loadRequest:[NSMutableURLRequest requestWithURL:googleTranslateUrl]];
        }
        else if([host isEqualToString:@"error"]) {
            if(_state == EBTranslateControllerStateTranslating && _sourcesAndCallbacks.count > 0) {
                NSDictionary *sourceAndCallback = [_sourcesAndCallbacks objectAtIndex:0];
                [_sourcesAndCallbacks removeObjectAtIndex:0];
                void (^error)(void) = [sourceAndCallback objectForKey:@"error"];
                error();
                NSURL *googleTranslateUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", GOOGLE_TRANSLATE_HOST]];
                [_webView loadRequest:[NSMutableURLRequest requestWithURL:googleTranslateUrl]];
            }
        }
        return false;
    }
    
    return [request.URL.host isEqualToString:GOOGLE_TRANSLATE_HOST];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView; {
    _state = EBTranslateControllerStateReady;
    
    if(_sourcesAndCallbacks.count > 0) {
        [self doTranslateInWebView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"did finish load with error");
}



@end
