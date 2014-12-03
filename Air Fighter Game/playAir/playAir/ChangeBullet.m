//
//  ChangeBullet.m
//  playAir
//
//  Created by li sandy on 13-10-9.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ChangeBullet.h"


@implementation ChangeBullet

@synthesize prop,bulletType;

- (void) initWithType:(prosType) type
{
    self.bulletType = type;
    NSString *proKey = [NSString stringWithFormat:@"enemy%d_fly_1.png",type];
    self.prop = [CCSprite spriteWithSpriteFrameName:proKey];
    [self.prop setPosition:ccp(arc4random()%268 + 23,732)];
}

- (void) propAnimation
{
    id act1 = [CCMoveTo actionWithDuration:1 position:ccp(self.prop.position.x,250)];//move to 400 pix position
    id act2 = [CCMoveTo actionWithDuration:0.4 position:ccp(self.prop.position.x,252)];//stop one second
    id act3 = [CCMoveTo actionWithDuration:1 position:ccp(self.prop.position.x,732)];//go back
    id act4 = [CCMoveTo actionWithDuration:2 position:ccp(self.prop.position.x,-55)];//down
    
    [self.prop runAction:[CCSequence actions:act1,act2,act3,act4, nil]];
}

@end
