//
//  Booby.h
//  BoobyDiver
//
//  Created by Jonathan Arme on 10/7/11.
//  Copyright 2011 Rovi Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

#define PTM_RATIO 32.0
#define NUM_PREV_VELS 5


@interface Booby : CCSprite {
    b2World *_world;
    b2Body *_body;
    BOOL _awake;
    b2Vec2 _prevVels[NUM_PREV_VELS];
    int _nextVel;
}

@property (readonly) BOOL awake;

-(void)wake;
-(void)dive;
-(void)climb;
-(void)limitVelocity;

-(id)initWithWorld:(b2World *)world;
-(void)update;

@end
