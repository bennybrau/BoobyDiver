//
//  HelloWorldLayer.h
//  TinySeal
//
//  Created by Ray Wenderlich on 6/15/11.
//  Copyright Ray Wenderlich 2011. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "Ocean.h"
#import "Booby.h"

#define PTM_RATIO 32.0

@interface HelloWorldLayer : CCLayer
{
	CCSprite * _background;
    Ocean * _ocean;
    Booby * _booby;
    b2World * _world;
    BOOL _tapDown;
}

+(CCScene *) scene;

@end
