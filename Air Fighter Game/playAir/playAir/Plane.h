//
//  Plane.h
//  playAir
//
//  Created by li sandy on 13-10-9.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

//enemy’s planes
@interface Plane : CCSprite

//types of planes: 1. Small 2. Big 3. medium
@property (readwrite) int planeType;
//the blood of planes: how many bullets can an plane stands
@property (readwrite) int hp;
//plane’s speed
@property (readwrite) int speed;

@end