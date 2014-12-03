//
//  GameController_FacebookIntegration.h
//  playAir
//
//  Created by li sandy on 13-10-9.
//
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "cocos2d.h"


@interface GameController_FacebookIntegration : NSObject

@property (assign) NSString* fbname;
@property long long fbid;
@property FBSession *session;

- (id)  FB_CreateNewSession;
- (id)  FB_Login;
- (id)  FB_Customize;
- (id)  FB_Logout;
- (id)  FB_RequestWritePermissions;
- (id)  FB_SendScore: (const int) nScore;


@end
