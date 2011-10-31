//
//  Ocean.h
//  BoobyDiver
//
//  Created by Jonathan Arme on 10/6/11.
//  Copyright 2011 Rovi Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

@class HelloWorldLayer;

#define kMaxWaveKeyPoints 1000
#define kWaveSegmentWidth 10
#define kMaxWaveVertices 4000
#define kMaxBorderVertices 800

@interface Ocean : CCNode 
{
    int _offsetX;
    CGPoint _waveKeyPoints[kMaxWaveKeyPoints];
    CCSprite *_water;
    
    int _fromKeyPointI;
    int _toKeyPointI;
    
    int _nWaveVertices;
    CGPoint _waveVertices[kMaxWaveVertices];
    CGPoint _waveTexCoords[kMaxWaveVertices];
    int _nBorderVertices;
    CGPoint _borderVertices[kMaxBorderVertices];
    
    b2World *_world;
    b2Body *_oceanBottom;
    
    GLESDebugDraw *_debugDraw;
    
    CCSpriteBatchNode *_batchNode;
}

@property (retain) CCSprite * water;
@property (retain) CCSpriteBatchNode * batchNode;

- (id)initWithWorld:(b2World *)world;
- (void) setOffsetX:(float)newOffsetX;

@end
