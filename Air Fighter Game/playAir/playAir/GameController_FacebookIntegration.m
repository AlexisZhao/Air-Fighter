//
//  GameController_FacebookIntegration.m
//  playAir
//
//  Created by li sandy on 13-10-9.
//
//

#import "GameController_FacebookIntegration.h"

@implementation GameController_FacebookIntegration

@synthesize fbname,fbid,session;


-(id) FB_CreateNewSession
{
    //m_kGameState = kGAMESTATE_FRONTSCREEN_NOSOCIAL_READY;
    //return;
    
    session = [[FBSession alloc] init];
    [FBSession setActiveSession: session];

    NSLog(@"Open FB session");

}

// Attempt to open the session - perhaps tabbing over to Facebook to authorise
-(id) FB_Login
{
    [session  openWithBehavior:FBSessionLoginBehaviorForcingWebView
             completionHandler:^(FBSession *session,
                                 FBSessionState status,
                                 NSError *error) {
                 // Did something go wrong during login? I.e. did the user cancel?
                 if (status == FBSessionStateClosedLoginFailed || status == FBSessionStateCreatedOpening) {
                     
                     // If so, just send them round the loop again
                     [[FBSession activeSession] closeAndClearTokenInformation];
                     [FBSession setActiveSession:nil];
                     [self FB_CreateNewSession];
                 }
                 else
                 {
                     // Update our game now we've logged in
                     NSLog(@"else");
                     [self FB_Customize] ;
                 }
                 // Respond to session state changes,
                 // ex: updating the view
             }];
    
}

- (id)  FB_Customize
{
    // Start the facebook request
    [[FBRequest requestForMe]
     startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *result, NSError *error)
     {
         // Did everything come back okay with no errors?
         if (!error && result)
         {
             // If so we can extract out the player's Facebook ID and first name
              fbid = [result.id longLongValue];
              fbname = [[NSString alloc] initWithString:result.first_name];
              NSLog(fbname);
             // Create a texture from the user's profile picture
            // m_pUserTexture = new System::TextureResource();
            // m_pUserTexture->CreateFromFBID(m_uPlayerFBID, 256, 256);
         }
     }];
}

-(id) FB_RequestWritePermissions
{
    // We need to request write permissions from Facebook
    static bool bHaveRequestedPublishPermissions = false;
    
    if (!bHaveRequestedPublishPermissions)
    {
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"publish_actions", nil];
        
        [session requestNewPublishPermissions:permissions defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *error) {
            NSLog(@"Reauthorized with publish permissions.");
        }];
        
        
        bHaveRequestedPublishPermissions = true;
    }

}

-(id) FB_SendScore: (const int) nScore
{
    
    [self FB_RequestWritePermissions];
    
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSString stringWithFormat:@"%d", nScore], @"score",
                                     nil];
    
    NSLog(@"Fetching current score");
    
    // Get the score, and only send the updated score if it's highter
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%llu/scores", fbid] parameters:params HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        if (result && !error) {
            
            //int nCurrentScore = 1;
            int nCurrentScore = [[[[result objectForKey:@"data"] objectAtIndex:0] objectForKey:@"score"] intValue];

            NSLog(@"Current score is %d", nCurrentScore);
            
            if (nScore > nCurrentScore) {
                
                NSLog(@"Posting new score of %d", nScore);
                
                [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%llu/scores", fbid] parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    if (result && !error) {
                    NSLog(@"Score posted");
                    }
                }];
            }
            else {
                NSLog(@"Existing score is higher - not posting new score");
            }
        }
        
    }];
}



-(id) FB_Logout
{
    // Log out of Facebook and reset our session
    [[FBSession activeSession] closeAndClearTokenInformation];
    [FBSession setActiveSession:nil];
    NSLog(@"FB log out");
}


-(id) FB_UpdateState
{
    NSString *message = [NSString stringWithFormat:@"Updating status for %@ at %@", fbname, [NSDate date]];
    
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    
    connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
    | FBRequestConnectionErrorBehaviorAlertUser
    | FBRequestConnectionErrorBehaviorRetry;
    
    [connection addRequest:[FBRequest requestForPostStatusUpdate:message]
         completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             
             //[self showAlert:message result:result error:error];
             //self.buttonPostStatus.enabled = YES;
         }];
    [connection start];
}



@end
