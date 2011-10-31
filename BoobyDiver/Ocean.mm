//
//  Ocean.m
//  BoobyDiver
//
//  Created by Jonathan Arme on 10/6/11.
//  Copyright 2011 Rovi Corporation. All rights reserved.
//

#import "Ocean.h"
#import "HelloWorldLayer.h"


@implementation Ocean
@synthesize water = _water;
@synthesize batchNode = _batchNode;

- (void) resetEdgeBox2DBodies {
    
    CGPoint p0 = _waveKeyPoints[0];
    CGPoint p1 = _waveKeyPoints[kMaxWaveKeyPoints-1];
    
    if(_oceanBottom == NULL)
    {
        b2BodyDef bd;
        bd.position.Set(0, 0);
        _oceanBottom = _world->CreateBody(&bd);
    
        b2PolygonShape shape;
        b2Vec2 ep1 = b2Vec2(p0.x/PTM_RATIO, 0);
        b2Vec2 ep2 = b2Vec2(p1.x/PTM_RATIO, 0);    
        shape.SetAsEdge(ep1, ep2);
        _oceanBottom->CreateFixture(&shape, 0);
    }
    
}

-(void) generateWaves
{
    CGSize winSize = [CCDirector sharedDirector].winSize;  
    
    float minDX = 200;  //160
    float minDY = 20;
    int rangeDX = 80;
    int rangeDY = 20;
    
    float midpoint = winSize.height/2 + 80;
    
    float x = -minDX;
    float y = midpoint-minDY;
    
    float dy,ny;
    float sign = 1;  // +1 going up, -1 going down
    float paddingTop = 20;
    float paddingBottom = 20;
    
    for(int i = 0; i < kMaxWaveKeyPoints; i++) 
    {
        _waveKeyPoints[i] = CGPointMake(x, y);
        if (i == 0)
        {
            x = 0;
            y = midpoint;  //winSize.height/2;
        }
        else
        {
            x += rand()%rangeDX+minDX;
            while (true)
            {
                dy = rand()%rangeDY+minDY;
                ny = y + dy*sign;
                if (ny < winSize.height-paddingTop && ny > paddingBottom)
                {
                    break;
                }
            }
            y = ny;
        }
        sign *= -1; //flip direction
        
    }
}

- (void) resetWaveVertices
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    static int prevFromKeyPointI = -1;
    static int prevToKeyPointI = -1;
    
    // key points interval for drawing
    while (_waveKeyPoints[_fromKeyPointI+1].x < _offsetX-winSize.width/8/self.scale) {
        _fromKeyPointI++;
    }
    while (_waveKeyPoints[_toKeyPointI].x < _offsetX+winSize.width*9/8/self.scale) {
        _toKeyPointI++;
    }
    
    if (prevFromKeyPointI != _fromKeyPointI || prevToKeyPointI != _toKeyPointI) {
        
        // vertices for visible area
        _nWaveVertices = 0;
        _nBorderVertices = 0;
        CGPoint p0, p1, pt0, pt1;
        p0 = _waveKeyPoints[_fromKeyPointI];
        for (int i=_fromKeyPointI+1; i<_toKeyPointI+1; i++) {
            p1 = _waveKeyPoints[i];
            
            // triangle strip between p0 and p1
            int hSegments = floorf((p1.x-p0.x)/kWaveSegmentWidth);
            float dx = (p1.x - p0.x) / hSegments;
            float da = M_PI / hSegments;
            float ymid = (p0.y + p1.y) / 2;
            float ampl = (p0.y - p1.y) / 2;
            pt0 = p0;
            _borderVertices[_nBorderVertices++] = pt0;
            for (int j=1; j<hSegments+1; j++) {
                pt1.x = p0.x + j*dx;
                pt1.y = ymid + ampl * cosf(da*j);
                _borderVertices[_nBorderVertices++] = pt1;
                
                _waveVertices[_nWaveVertices] = CGPointMake(pt0.x, 0);
                _waveTexCoords[_nWaveVertices++] = CGPointMake(pt0.x/512, 1.0f);
                _waveVertices[_nWaveVertices] = CGPointMake(pt1.x, 0);
                _waveTexCoords[_nWaveVertices++] = CGPointMake(pt1.x/512, 1.0f);
                
                _waveVertices[_nWaveVertices] = CGPointMake(pt0.x, pt0.y);
                _waveTexCoords[_nWaveVertices++] = CGPointMake(pt0.x/512, 0);
                _waveVertices[_nWaveVertices] = CGPointMake(pt1.x, pt1.y);
                _waveTexCoords[_nWaveVertices++] = CGPointMake(pt1.x/512, 0);
                
                pt0 = pt1;
            }
            
            p0 = p1;
        }
        
        prevFromKeyPointI = _fromKeyPointI;
        prevToKeyPointI = _toKeyPointI;
        [self resetEdgeBox2DBodies];    
    }
    
}

-(void)setupDebugDraw
{
    _debugDraw = new GLESDebugDraw(PTM_RATIO*[[CCDirector sharedDirector] contentScaleFactor]);
    _world->SetDebugDraw(_debugDraw);
    _debugDraw->SetFlags(b2DebugDraw::e_shapeBit | b2DebugDraw::e_jointBit);
}

- (id)initWithWorld:(b2World *)world
{
    if ((self = [super init])) {
        _world = world;
        //[self setupDebugDraw];
        [self generateWaves];
        [self resetWaveVertices];
        
        _batchNode = [CCSpriteBatchNode batchNodeWithFile:@"TinySeal.png"];
        [self addChild:_batchNode];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"TinySeal.plist"];
    }
    return self;
}

- (void) draw 
{
    glBindTexture(GL_TEXTURE_2D, _water.texture.name);
    glDisableClientState(GL_COLOR_ARRAY);
    
    glColor4f(1, 1, 1, 1);
    glVertexPointer(2, GL_FLOAT, 0, _waveVertices);
    glTexCoordPointer(2, GL_FLOAT, 0, _waveTexCoords);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)_nWaveVertices);
    
    //cosine wave
    for(int i = MAX(_fromKeyPointI, 1); i <= _toKeyPointI; ++i) {    
        
        glColor4f(1.0, 1.0, 1.0, 1.0);
        
        CGPoint p0 = _waveKeyPoints[i-1];
        CGPoint p1 = _waveKeyPoints[i];
        int hSegments = floorf((p1.x-p0.x)/kWaveSegmentWidth);
        float dx = (p1.x - p0.x) / hSegments;
        float da = M_PI / hSegments;
        float ymid = (p0.y + p1.y) / 2;
        float ampl = (p0.y - p1.y) / 2;
        
        CGPoint pt0, pt1;
        pt0 = p0;
        for (int j = 0; j < hSegments+1; ++j) {
            
            pt1.x = p0.x + j*dx;
            pt1.y = ymid + ampl * cosf(da*j);
            
            ccDrawLine(pt0, pt1);
            
            pt0 = pt1;
            
        }
    }
    
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    //_world->DrawDebugData();
    
    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
}

- (void) setOffsetX:(float)newOffsetX 
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    _offsetX = newOffsetX;
    self.position = CGPointMake(winSize.width/8-_offsetX*self.scale, 0);
    [self resetWaveVertices];
}

- (void)dealloc 
{
    [super dealloc];
}

@end
