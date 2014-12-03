//
//  HelloWorldLayer.m
//  playAir
//
//  Created by li sandy on 13-10-9.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "SimpleAudioEngine.h"
#import "GameController_FacebookIntegration.h"
#import <Foundation/Foundation.h>


#define WINDOWHEIGHT [[UIScreen mainScreen] bounds].size.height

// HelloWorldLayer implementation
@implementation HelloWorldLayer

- (void) dealloc
{
    [BG1 release];
    [BG2 release];
    
    [player release];
    [bullet release];
    
    [foePlanes release];
    [scoreLabel release];
    
    [scoreLabel release];
    
    [prop release];
    
    [gameOverLabel release];
    
    [fbController release];

    
	[super dealloc];
}

#pragma mark -
#pragma mark - 系统默认
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
    
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init]))
    {
        self.isAccelerometerEnabled=NO;
        
        sleep(3);
        
        //play music
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"game_music.mp3" loop:YES];
        
        //init data
        [self initData];
        
        //load bacgroud
        [self loadBackground];
    
        //load player flight
        [self loadPlayer];
        
        isVisible = NO;
        

        //load buttle
        [self madeBullet];
        [self resetBullet];
        
		[self scheduleUpdate];
        
	}
	return self;
}

#pragma mark -
#pragma mark -
- (void) gamePause
{
    if (isGameOver == NO)
    {
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
        
        CCMenuItemFont *gameOverItem = [CCMenuItemFont itemFromString:@"START GAME" target:self selector:@selector(gameStart)];
        [gameOverItem setFontName:@"AmericanTypewriter-Bold"];
        [gameOverItem setFontSize:30];
        restart = [CCMenu menuWithItems:gameOverItem, nil];
        [restart setPosition:ccp(160, WINDOWHEIGHT/2)];
        [self addChild:restart z:4];

        isGameOver = YES;
    }
    else
    {
        [prop stopAllActions];
    }
}

- (void) gameStart
{
    NSLog(@"game start");
    
    [self updateFBmenu];
    
    if (isGameOver == YES)
    {
        [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
        [self removeChild:restart cleanup:YES];
        isGameOver = NO;
    }
}

- (void) restart
{
    [self removeAllChildrenWithCleanup:YES];
    [foePlanes removeAllObjects];
    [self initData];
    [self loadBackground];
    [self loadPlayer];
    [self madeBullet];
    [self resetBullet];
}

- (void) gameOver {
    
    isGameOver = YES;

    [self gamePause];
    
    gameOverLabel = [CCLabelTTF labelWithString:@"GameOver" fontName:@"AmericanTypewriter-Bold" fontSize:35];
    [gameOverLabel setPosition:ccp(160, 300)];
    [self addChild:gameOverLabel z:4];
    
    CCMenuItemFont *gameOverItem = [CCMenuItemFont itemFromString:@"restart" target:self selector:@selector(restart)];
    [gameOverItem setFontName:@"AmericanTypewriter-Bold"];
    [gameOverItem setFontSize:30];
    restart = [CCMenu menuWithItems:gameOverItem, nil];
    [restart setPosition:ccp(160, 200)];
    [self addChild:restart z:4];
    
    if ([FBSession activeSession].state == FBSessionStateOpen) {
        
        [fbController FB_SendScore:scoreInt];
    }

}

#pragma mark -
#pragma mark -
- (void) playFireSound
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"bullet.mp3"];
}

- (void) smallPlaneDownSound
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"enemy1_down.mp3"];
}

- (void) bigPlaneOutSount
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"enemy2_out.mp3"];
}

- (void) mediumPlaneDownSound
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"enemy3_down.mp3"];
}

- (void) bigPlaneDownSound
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"enemy2_down.mp3"];
}

#pragma mark -
#pragma mark - update scenen
- (void) update:(ccTime) delta
{
    if (!isGameOver)
    {
        //move backgroud
        [self scrollBackground];
        
        //shoot bullets
        [self firingBullets];
        
        [self addPlane];
        [self movePlane];
        
        [self bulletLastTime];
        
        [self collisionDetection];
        
        [self addBulletTypeTip];
        
    }
}

#pragma mark -
#pragma mark - init data
- (void) initData
{
    adjustmentBG = 568;
    isGameOver = NO;
    //bullet init speed is 25
    bulletSpeed = 25;
    
    playerVelocity.x=10;
    playerVelocity.y=10;

    
    //span time
    smallPlaneTime = 0;
    mediumPlaneTime = 0;
    bigPlaneTime = 0;
    
    bulletLastTime = 1200;
    
    propTime = 0;
    
    //score
    scoreInt = 0;
    
    isBigBullet = NO;
    isChangeBullet = NO;
    
    foePlanes = [CCArray array];
    [foePlanes retain];
    
    fbController=[[GameController_FacebookIntegration alloc] init];
    [fbController FB_CreateNewSession];
    if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
        [fbController FB_Login];
    }
}

#pragma mark -
#pragma mark - load and move background
- (void) loadBackground
{
     BG1 = [CCSprite spriteWithSpriteFrameName:@"background_2.png"];
    [BG1 setAnchorPoint:ccp(0.5,0)];
    [BG1 setPosition:ccp(160, 0)];
    [self addChild:BG1 z:0];
    
    BG2 = [CCSprite spriteWithSpriteFrameName:@"background_2.png"];
    [BG2 setAnchorPoint:ccp(0.5,0)];
    [BG2 setPosition:ccp(160, adjustmentBG - 1)];
    [self addChild:BG2 z:0];
    
    [self setIsTouchEnabled:YES];
    
    scoreLabel = [CCLabelTTF labelWithString:@"0000"
                                  fontName:@"American Typewriter"
                                    fontSize:20];
    [scoreLabel setColor:ccc3(0, 0, 0)];
    [scoreLabel setAnchorPoint:ccp(0, 1)];
    [scoreLabel setPosition:ccp(240, WINDOWHEIGHT - 15)];
    [self addChild:scoreLabel z:4];
    
    CCMenuItem *pauseMenuItem = [CCMenuItemImage
                                itemFromNormalImage:@"BurstAircraftPause.png" selectedImage:@"BurstAircraftPause.png"
                                 target:self selector:@selector(gamePause)];
    [pauseMenuItem setAnchorPoint:ccp(0, 1)];
    pauseMenuItem.position = ccp(10, WINDOWHEIGHT - 10);
    
    fbMenuItem = [CCMenuItemImage
                                 itemFromNormalImage:@"facebook_logo.png" selectedImage:@"facebook_logo.png"
                                 target:self selector:@selector(fbLogin)];
    [fbMenuItem setAnchorPoint:ccp(0, 1)];
    fbMenuItem.position = ccp(54, WINDOWHEIGHT - 10);
    
    UserName = [CCMenuItemFont itemFromString:@"START GAME" target:self selector:nil];
    [UserName setFontName:@"AvenirNext-Heavy"];
    [UserName setFontSize:20];
    [UserName setColor:ccc3(56, 96, 184)];
    [UserName setPosition:ccp(160, WINDOWHEIGHT-30)];
    [UserName setVisible:false];

    [self updateFBmenu];
    CCMenu *starMenu = [CCMenu menuWithItems:pauseMenuItem,fbMenuItem,UserName, nil];
    
    starMenu.position = CGPointZero;
    [self addChild:starMenu z:4];
    starMenu.tag = 10;
    NSLog(@"load BG");
}

//scorll background
- (void) scrollBackground
{
    adjustmentBG --;
    
    if (adjustmentBG <= 0)
    {
        adjustmentBG = 568;
    }
    
    [BG1 setPosition:ccp(160,adjustmentBG - 568)];
    [BG2 setPosition:ccp(160, adjustmentBG - 1)];
}

#pragma mark -
#pragma mark -
- (void) loadPlayer
{
    //init flight plane
    NSMutableArray *playerActionArray = [NSMutableArray array];
    for (int i = 1; i < 3; i++)
    {
        NSString *key = [NSString stringWithFormat:@"hero_fly_%d.png",i];
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:key];
        [playerActionArray addObject:frame];
    }
    
    //transfer array into anime
    CCAnimation *animPlayer = [CCAnimation animationWithFrames:playerActionArray delay:0.1];
    id actPlayer = [CCAnimate actionWithAnimation:animPlayer];
    //flue cache
    [playerActionArray removeAllObjects];
    
    player = [[CCSprite alloc] initWithSpriteFrameName:@"hero_fly_1.png"];
    player.position = ccp(160, 50);
    [self addChild:player z:3];
    //repeat anime
    [player runAction:[CCRepeatForever actionWithAction:actPlayer]];
    
    self.isAccelerometerEnabled=YES;
    
}

- (CGPoint)boundLayerPos:(CGPoint)newPos
{
    CGPoint retval = newPos;
    retval.x = player.position.x+newPos.x;
    retval.y = player.position.y+newPos.y;
    
    if (retval.x>=286) {
        retval.x = 286;
    }else if (retval.x<=33) {
        retval.x = 33;
    }
    
    if (retval.y >=WINDOWHEIGHT-50) {
        retval.y = WINDOWHEIGHT-50;
    }else if (retval.y <= 43) {
        retval.y = 43;
    }
    
    return retval;
}

//move with finger
- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    //get old location
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    
    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
    
    if (!isGameOver)
    {
        player.position = [self boundLayerPos:translation];
    }
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.isAccelerometerEnabled=NO;
}

-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{

    if (!isGameOver)
    {
        // deceleration rate
        float deceleration = 0.1f;

        float Wsensitivity = 30.0f;
        float Hsensitivity = 60.0f;
        

        // current speed
        playerVelocity.x = playerVelocity.x * deceleration + acceleration.x * Wsensitivity;
        playerVelocity.y = playerVelocity.y * deceleration + acceleration.y * Hsensitivity;
        
        player.position = [self boundLayerPos:playerVelocity];
        //NSLog(@"acceleration.x = %f,acceleration.y = %f ",player.position.x,player.position.y);

    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.isAccelerometerEnabled=YES;
}


#pragma mark -
#pragma mark - make bullet, change bullet
- (void) madeBullet
{
    bullet = [CCSprite spriteWithSpriteFrameName:(!isBigBullet)?@"bullet1.png":@"bullet2.png"];
    bullet.anchorPoint = ccp(0.5, 0.5);
    [self addChild:bullet];
    [self playFireSound];
}

- (void) resetBullet
{
    if ((isBigBullet&&isChangeBullet) || (!isBigBullet&&isChangeBullet))
    {
        [bullet removeFromParentAndCleanup:NO];
        [self madeBullet];
        isChangeBullet = NO;
    }
    
    
    bulletSpeed = (WINDOWHEIGHT - (player.position.y + 50))/15;
    
    if (bulletSpeed<5)
    {
        bulletSpeed=5;
    }
    
    bullet.position=ccp(player.position.x,player.position.y+50);
    
    [self playFireSound];
}

//fire
- (void) firingBullets
{
    bullet.position = ccp(bullet.position.x,bullet.position.y + bulletSpeed);
    if (bullet.position.y > WINDOWHEIGHT - 20)
    {
        [self resetBullet];
        [self playFireSound];
    }

}

#pragma mark -
#pragma mark - add plane
//add small plane
- (void) addPlane
{
    smallPlaneTime ++;
    mediumPlaneTime ++;
    bigPlaneTime ++;
    
    if (smallPlaneTime > 25)
    {
        Plane *smallPlane = [self makeSmallPlane];
        [self addChild:smallPlane z:3];
        [foePlanes addObject:smallPlane];
        
        smallPlaneTime = 0;
    }
    
    if (mediumPlaneTime > 400)
    {
        Plane *mediumPlane = [self makeMediumPlane];
        [self addChild:mediumPlane z:3];
        [foePlanes addObject:mediumPlane];
        
        mediumPlaneTime = 0;
    }
    
    if (bigPlaneTime > 700)
    {
        Plane *bigPlane = [self makeBigPlane];
        [self addChild:bigPlane z:3];
        [foePlanes addObject:bigPlane];
        
        [self performSelector:@selector(bigPlaneOutSount) withObject:nil afterDelay:0.5];
        
        bigPlaneTime = 0;
    }
}


- (Plane *) makeSmallPlane
{
    Plane *smallPlane = [Plane spriteWithSpriteFrameName:@"enemy1_fly_1.png"];
    [smallPlane setPosition:ccp((arc4random()%290) + 17,568)];
    [smallPlane setPlaneType:1];
    [smallPlane setHp:1];
    [smallPlane setSpeed:arc4random()%4 + 2];
    return smallPlane;
}

- (Plane *) makeMediumPlane
{
    Plane *mediumPlane = [Plane spriteWithSpriteFrameName:@"enemy3_fly_1.png"];
    [mediumPlane setPosition:ccp((arc4random()%280 + 23),568)];
    [mediumPlane setPlaneType:3];
    [mediumPlane setHp:15];
    [mediumPlane setSpeed:arc4random()%3 + 2];
    return mediumPlane;
}

- (Plane *) makeBigPlane
{
    NSMutableArray *bigPlaneAnimationArr = [NSMutableArray array];
    for (int i = 1; i <= 2; i ++)
    {
        NSString *key = [NSString stringWithFormat:@"enemy2_fly_%i.png",i];
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:key];
        [bigPlaneAnimationArr addObject:frame];
    }
    
    CCAnimation *animation = [CCAnimation animationWithFrames:bigPlaneAnimationArr delay:0.1];
    id animate = [CCAnimate actionWithAnimation:animation];
    [bigPlaneAnimationArr removeAllObjects];
    
    //anime
    Plane *bigPlane = [Plane spriteWithSpriteFrameName:@"enemy2_fly_1.png"];
    [bigPlane setPosition:ccp((arc4random()%210 + 55),700)];
    [bigPlane setPlaneType:2];//big plane
    [bigPlane setHp:25];
    [bigPlane setSpeed:arc4random()%2 + 2];
    [bigPlane runAction:[CCSequence actions:[CCRepeatForever actionWithAction:animate], nil]];
    
    return bigPlane;
    
}


- (void) movePlane
{
    for (Plane *tmpPlane in foePlanes)
    {
        [tmpPlane setPosition:ccp(tmpPlane.position.x,tmpPlane.position.y - tmpPlane.speed)];
        if (tmpPlane.position.y < (-75))
        {
            [foePlanes removeObject:tmpPlane];
            [tmpPlane removeFromParentAndCleanup:NO];
        }
    }
}

#pragma mark -
#pragma mark -
- (void) addBulletTypeTip
{
    propTime ++;
    
    if (propTime > 1500)
    {
        prop = [ChangeBullet node];
        [prop initWithType:arc4random()%2 + 4];
        [self addChild:prop.prop];
        [prop propAnimation];
        [prop retain];
        propTime = 0;
        isVisible = YES;
    }
}

- (void) bulletLastTime
{
    if (isBigBullet)
    {
        if (bulletLastTime > 0)
        {
            bulletLastTime --;
        }
        else
        {
            bulletLastTime = 1200;
            isBigBullet = NO;
            isChangeBullet = YES;
        }
    }
}

#pragma mark -
#pragma mark - hit flight anime
- (void) hitAnimationToFoePlane:(Plane *) feoPlane
{
    if (feoPlane.planeType == 3)
    {
        //middle plane
        if (feoPlane.hp == 13)
        {
            NSMutableArray *frames = [NSMutableArray array];
            for (int i = 1; i <= 2; i ++)
            {
                NSString *key = [NSString stringWithFormat:@"enemy3_hit_%d.png",i];
                CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:key];
                [frames addObject:frame];
            }
            
            CCAnimation *animation = [CCAnimation animationWithFrames:frames delay:0.1];
            id animate = [CCAnimate actionWithAnimation:animation];
            [frames removeAllObjects];
            //stop former plane
            [feoPlane stopAllActions];
            
            [feoPlane runAction:[CCRepeatForever actionWithAction:animate]];
        }
    }
    else
    {
        //big plane
        if (feoPlane.hp == 20)
        {            
            NSMutableArray *frames = [NSMutableArray array];
            for (int i = 1; i <= 1; i ++)
            {
                NSString *key = [NSString stringWithFormat:@"enemy2_hit_%d.png",i];
                CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:key];
                [frames addObject:frame];
            }
            
            CCAnimation *animation = [CCAnimation animationWithFrames:frames delay:0.1];
            id animate = [CCAnimate actionWithAnimation:animation];
            [frames removeAllObjects];
            //stop former palne
            [feoPlane stopAllActions];
            
            [feoPlane runAction:[CCRepeatForever actionWithAction:animate]];
        }
    }
}

#pragma mark -
#pragma mark - player flight destory
- (void) playerBlowupAnimation
{
    [player stopAllActions];
    
    NSMutableArray *foePlaneActionArray = [NSMutableArray array];
    
    for (int i = 1; i<=4 ; i++ ) {
        NSString* key = [NSString stringWithFormat:@"hero_blowup_%i.png", i];
        CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:key];
        [foePlaneActionArray addObject:frame];
    }
    
    CCAnimation* animPlayer = [CCAnimation animationWithFrames:foePlaneActionArray delay:0.1f];
    id actFowPlane = [CCAnimate actionWithAnimation:animPlayer];
    id end = [CCCallFuncN actionWithTarget:self selector:@selector(blowupEnd:)];
    [foePlaneActionArray removeAllObjects];
    
    [player runAction:[CCSequence actions:actFowPlane,end, nil]];
}

#pragma mark -
#pragma mark - 碰撞检测
- (void) foePlaneBlowupAnimation:(Plane *) foePlane
{
    int animationNum = 0;
    
    if (foePlane.planeType == 1)
    {
        animationNum = 4;
        scoreInt += 2000;
    }
    
    if (foePlane.planeType == 3)
    {
        animationNum = 4;
        scoreInt += 10000;
    }
    
    if (foePlane.planeType == 2)
    {
        animationNum = 7;
        scoreInt += 40000;
    }
    
    [scoreLabel setString:[NSString stringWithFormat:@"%d",scoreInt]];
    
    //stop all anime
    [foePlane stopAllActions];
    
    NSMutableArray *foeActionArr = [NSMutableArray array];
    for (int i = 1; i <= animationNum; i ++)
    {
        NSString *key = [NSString stringWithFormat:@"enemy%d_blowup_%i.png",foePlane.planeType,i];
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:key];
        [foeActionArr addObject:frame];
    }
    
    CCAnimation *aniPlayer = [CCAnimation animationWithFrames:foeActionArr delay:0.1f];
    id actFowPlane = [CCAnimate actionWithAnimation:aniPlayer];
    id end = [CCCallFuncN actionWithTarget:self selector:@selector(blowupEnd:)];
    [foeActionArr removeAllObjects];
    
    [foePlane runAction:[CCSequence actions:actFowPlane,end, nil]];
    
    if (foePlane.planeType == 3)
    {
        [self mediumPlaneDownSound];
    }
    else if (foePlane.planeType == 2)
    {
        [self bigPlaneDownSound];
    }
    else if (foePlane.planeType == 1)
    {
        [self smallPlaneDownSound];
    }
}

- (void) blowupEnd:(id) sender
{
    Plane *tmpPlane = (Plane *)sender;
    [tmpPlane removeFromParentAndCleanup:NO];
}

- (void) collisionDetection
{
    CGRect bulletRect = bullet.boundingBox;
    for (Plane *tmpPlane in foePlanes)
    {
        if (CGRectIntersectsRect(bulletRect, tmpPlane.boundingBox))
        {
            [self resetBullet];
            
            tmpPlane.hp = tmpPlane.hp - (isBigBullet?2:1);
            
            if (tmpPlane.hp <= 0)
            {
                [self foePlaneBlowupAnimation:tmpPlane];
                [foePlanes removeObject:tmpPlane];
            }
            else
            {
                [self hitAnimationToFoePlane:tmpPlane];
            }
        }
    }
    
    CGRect playerRec = player.boundingBox;
    playerRec.origin.x += 25;
    playerRec.size.width -= 50;
    playerRec.origin.y -= 10;
    playerRec.size.height -= 10;
    for (Plane *tmpPlane in foePlanes)
    {
        if (CGRectIntersectsRect(playerRec, tmpPlane.boundingBox))
        {
            [self gameOver];
            [self playerBlowupAnimation];
            [self foePlaneBlowupAnimation:tmpPlane];
            [foePlanes removeObject:tmpPlane];
        }
    }
    
    if (isVisible == YES)
    {
        CGRect playerRect1 = player.boundingBox;
        CGRect propRect = prop.prop.boundingBox;
        
        if (CGRectIntersectsRect(playerRect1, propRect))
        {
            [prop.prop stopAllActions];
            [prop.prop removeFromParentAndCleanup:YES];
            isVisible = NO;
            
            if (prop.bulletType == propsTypeBullet)
            {
                isBigBullet = YES;
                isChangeBullet = YES;
            }
            else
            {
                for (Plane *tmpPlane in foePlanes)
                {
                    [self foePlaneBlowupAnimation:tmpPlane];
                }
                [foePlanes removeAllObjects];
            }
            
        }
    }
    
}

-(void) fbLogin
{
    [self gamePause];
    [fbController FB_CreateNewSession];
    [fbController FB_Login];
}

-(void) updateFBmenu
{
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *result, NSError *error)
         {
             if (!error) {
                 [UserName setString: result.last_name];
                 [UserName setVisible:true];
                 [fbMenuItem setVisible:false];
             }
         }];
    }
}



@end
