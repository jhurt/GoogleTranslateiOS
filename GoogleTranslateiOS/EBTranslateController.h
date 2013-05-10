//
//  EBTranslateController.h
//  GoogleTranslateiOS
//
//  Created by Jason Hurt on 5/9/13.
//  Copyright (c) 2013 8byte8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EBTranslateController : NSObject<UIWebViewDelegate>

- (void)beginTranslate:(NSString*)sourceText onSuccess:(void (^)(NSString *result))success onError:(void (^)(void))error;

@end
