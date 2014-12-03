//
//  ChangeBullet.h
//  playAir
//
//  Created by li sandy on 13-10-9.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
    propsTypeBomb = 4,
    propsTypeBullet = 5
} prosType;

@interface ChangeBullet : CCNode

@property (assign) CCSprite *prop;
@property (assign) prosType bulletType;

- (void) initWithType:(prosType) type;
- (void) propAnimation;

@end
