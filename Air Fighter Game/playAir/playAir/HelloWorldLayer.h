//
//  HelloWorldLayer.h
//  playAir
//
//  Created by li sandy on 13-10-9.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Plane.h"
#import "GameController_FacebookIntegration.h"
#import "ChangeBullet.h"
#import <Foundation/Foundation.h>


// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
    // Background-Roll
    CCSprite *BG1;
    CCSprite *BG2;
    NSInteger adjustmentBG;
    
    // if game is over
    BOOL isGameOver;
    
    // player’ plane
    CCSprite *player;
    
    // plane’s bullet
    CCSprite *bullet;
    int bulletSpeed;//bullet’s speed
    
    //enemy’s plane
    CCArray *foePlanes;
    int smallPlaneTime;//a small plane of enemy shows up in every 25 ms
    int mediumPlaneTime;//a meduim plane of enemy shows up in every 25 ms
    int bigPlaneTime;//a big plane of enemy shows up in every 25 ms
    
    //count time of Airborne goods
    int propTime;
    //Airborne goods
    ChangeBullet *prop;
    //if the airborne goods is gone
    BOOL isVisible;
    
    　　//get score
    CCLabelTTF *scoreLabel;
    int scoreInt;
    
    //start
    CCMenu *restart;
    
    //change bullets
    BOOL isBigBullet;
    BOOL isChangeBullet;
    int bulletLastTime;//time of changing bullet
    
    CGPoint playerVelocity;
    
    GameController_FacebookIntegration * fbController;
    CCMenuItem *fbMenuItem;
    CCMenuItemFont *UserName;
    
    //remind of game over
    CCLabelTTF *gameOverLabel;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

//initiate data
- (void) initData;

//background
- (void) loadBackground;
- (void) scrollBackground;

//player’s airplane
- (void) loadPlayer;

//made bullet fire move
- (void) madeBullet;
- (void) firingBullets;
- (void) resetBullet;

//make planes for enemy
- (void) addPlane;
//make small planes
- (Plane *) makeSmallPlane;
// make medium planes
- (Plane *) makeMediumPlane;
//make big planes
- (Plane *) makeBigPlane;


- (void) movePlane;

//detect collision
- (void) collisionDetection;

//add airborne goods
- (void) addBulletTypeTip;

//set property of game
- (void) gamePause;
- (void) gameStart;

//time of bullet lasting
- (void) bulletLastTime;

- (void) fbLogin;


@end