//
//  HelloWorldLayer.mm
//  TinySeal
//
//  Created by Ray Wenderlich on 6/15/11.
//  Copyright Ray Wenderlich 2011. All rights reserved.
//


#import "HelloWorldLayer.h"

@implementation HelloWorldLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
	return scene;
}

-(CCSprite *)spriteWithColor:(ccColor4F)bgColor textureSize:(float)textureSize showGradient:(BOOL)showGrad {
    
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:textureSize height:textureSize];
    
    [rt beginWithClear:bgColor.r g:bgColor.g b:bgColor.b a:bgColor.a];
    
    //Draw gradient into the texture (if enabled)
    if (showGrad)
    {
        glDisable(GL_TEXTURE_2D);
            glDisableClientState(GL_TEXTURE_COORD_ARRAY);
            
            float gradientAlpha = 0.7;    
            CGPoint vertices[4];
            ccColor4F colors[4];
            int nVertices = 0;
            
            vertices[nVertices] = CGPointMake(0, 0);
            colors[nVertices++] = (ccColor4F){0, 0, 0, 0 };
            vertices[nVertices] = CGPointMake(textureSize, 0);
            colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
            vertices[nVertices] = CGPointMake(0, textureSize);
            colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
            vertices[nVertices] = CGPointMake(textureSize, textureSize);
            colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
            
            glVertexPointer(2, GL_FLOAT, 0, vertices);
        glColorPointer(4, GL_FLOAT, 0, colors);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)nVertices);
            
            glEnableClientState(GL_TEXTURE_COORD_ARRAY);
            glEnable(GL_TEXTURE_2D);
            
            
            CCSprite *noise = [CCSprite spriteWithFile:@"Noise.png"];
            [noise setBlendFunc:(ccBlendFunc){GL_DST_COLOR, GL_ZERO}];
            noise.position = ccp(textureSize/2, textureSize/2);
            [noise visit];
        
    }    
    
    [rt end];
    return [CCSprite spriteWithTexture:rt.sprite.texture];
    
}


- (ccColor4F)randomBrightColor {
    
    while (true) {
        float requiredBrightness = 192;
        ccColor4B randomColor = 
        ccc4(arc4random() % 255,
             arc4random() % 255, 
             arc4random() % 255, 
             255);
        if (randomColor.r > requiredBrightness || 
            randomColor.g > requiredBrightness ||
            randomColor.b > requiredBrightness) {
            return ccc4FFromccc4B(randomColor);
        }        
    }
    
}

- (void)genBackground {
    
    [_background removeFromParentAndCleanup:YES];
    
    ccColor4B skyColor = ccc4(176, 224, 230, 255);
    
    _background = [self spriteWithColor:ccc4FFromccc4B(skyColor) textureSize:512 showGradient:NO];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    _background.position = ccp(winSize.width/2, winSize.height/2); 
    
    ccTexParams tp = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
    [_background.texture setTexParameters:&tp];
    
    [self addChild:_background];
    
    ccColor4F waterColor = ccc4FFromccc4B(ccc4(135, 206, 250, 255));
    CCSprite *water = [self spriteWithColor:waterColor textureSize:512 showGradient:YES];
    ccTexParams tp2 = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_CLAMP_TO_EDGE};
    [water.texture setTexParameters:&tp2];
    _ocean.water = water;
}

-(void) setupWorld 
{
    b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
    bool doSleep = true;
    _world = new b2World(gravity, doSleep);
}

-(void) createTestBodyAtPosition:(CGPoint)position
{
    b2BodyDef testBodyDef;
    testBodyDef.type = b2_dynamicBody;
    testBodyDef.position.Set(position.x/PTM_RATIO, position.y/PTM_RATIO);
    b2Body *testBody = _world->CreateBody(&testBodyDef);
    
    b2CircleShape testBodyShape;
    b2FixtureDef testFixtureDef;
    testBodyShape.m_radius = 25.0/PTM_RATIO;
    testFixtureDef.shape = &testBodyShape;
    testFixtureDef.density = 1.0;
    testFixtureDef.friction = 1.0;
    testFixtureDef.restitution = 0.2;
    testBody->CreateFixture(&testFixtureDef);
    
}

-(id) init {
    if((self=[super init])) {
        [self setupWorld];
        
        _ocean = [[[Ocean alloc] initWithWorld:_world] autorelease];
        
        [self addChild:_ocean z:1];
        [self genBackground];
        self.isTouchEnabled = YES;
        [self scheduleUpdate];
        
        _booby = [[[Booby alloc] initWithWorld:_world] autorelease];
        [_ocean.batchNode addChild:_booby];
        
    }
    return self;
}

- (void)update:(ccTime)dt {
    
    if (_tapDown)
    {
        if (!_booby.awake)
        {
            [_booby wake];
            _tapDown = NO;
        }
        else
        {
            [_booby dive];
        }
    }
    else
    {
        if (_booby.awake)
        {
            [_booby climb];
        }
    }
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    float scale = (winSize.height*4/5) / _booby.position.y;
    if (scale > 1) scale = 1;
    _ocean.scale = scale;
    
    [_booby limitVelocity];
    
    static double UPDATE_INTERVAL = 1.0f/60.0f;
    static double MAX_CYCLES_PER_FRAME = 5;
    static double timeAccumulator = 0;
    
    timeAccumulator += dt;    
    if (timeAccumulator > (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL)) {
        timeAccumulator = UPDATE_INTERVAL;
    }    
    
    int32 velocityIterations = 3;
    int32 positionIterations = 2;
    while (timeAccumulator >= UPDATE_INTERVAL) {        
        timeAccumulator -= UPDATE_INTERVAL;        
        _world->Step(UPDATE_INTERVAL, 
                     velocityIterations, positionIterations);        
        _world->ClearForces();
    }
    
    [_booby update];
    float offset = _booby.position.x;
    
    CGSize textureSize = _background.textureRect.size;
    [_background setTextureRect:CGRectMake(offset * 0.4, 0, textureSize.width, textureSize.height)];
    [_ocean setOffsetX:offset];
    
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _tapDown = YES;
    
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _tapDown = NO;
}

-(void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _tapDown = NO;
}

@end
