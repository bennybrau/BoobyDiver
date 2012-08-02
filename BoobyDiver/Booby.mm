//
//  Booby.m
//  BoobyDiver
//
//  Created by Jonathan Arme on 10/7/11.
//  Copyright 2011 Rovi Corporation. All rights reserved.
//

#import "Booby.h"


@implementation Booby
@synthesize awake = _awake;

-(void) wake
{
    _awake = YES;
    _body->SetActive(true);
    _body->ApplyForce(b2Vec2(1,2), _body->GetPosition());
}

-(void) climb
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    b2Vec2 curPosition = _body->GetPosition();
    float maxHeight = ((winSize.height+120)/PTM_RATIO);
    
    if (curPosition.y < maxHeight)
    {
        float diffY = (maxHeight - curPosition.y);
        
        if (diffY <= 5)
        {
            _body->ApplyForce(b2Vec2(1, 0), _body->GetPosition());
            //_body->SetLinearVelocity(b2Vec2(1,1));
        }
        
        else
        {
            //_body->SetLinearVelocity(b2Vec2(1,1));
            _body->ApplyForce(b2Vec2(1, 4), _body->GetPosition());
        }
    }
    else
    {
        //_body->SetLinearVelocity(b2Vec2(1,0));
        _body->ApplyForce(b2Vec2(1, 0), _body->GetPosition());
    }
}

-(void) dive
{
    _body->ApplyForce(b2Vec2(1, -10), _body->GetPosition());
}

-(void) limitVelocity
{
    if (!_awake)
        return;
    
    const float minVelocityX = 2;
    const float minVelocityY = -20;
    
    b2Vec2 vel = _body->GetLinearVelocity();
    if (vel.x < minVelocityX) {
        vel.x = minVelocityX;
    }
    if (vel.y < minVelocityY) {
        vel.y = minVelocityY;
    }
    _body->SetLinearVelocity(vel);
}

-(void)createBody
{
    float radius = 16.0f;
    CGSize size = [[CCDirector sharedDirector] winSize];
    int screenH = size.height;
    
    CGPoint startPosition = ccp(0, screenH +120+radius);
    
    b2BodyDef bd;
    bd.type = b2_dynamicBody;
    bd.linearDamping = 0.3f;
    bd.fixedRotation = true;
    bd.position.Set(startPosition.x/PTM_RATIO, startPosition.y/PTM_RATIO);
    _body = _world->CreateBody(&bd);
    
    b2CircleShape shape;
    shape.m_radius = radius/PTM_RATIO;
    
    b2FixtureDef fd;
    fd.shape = &shape;
    fd.density = 1.0f;
    fd.restitution = 0.0f;
    fd.friction = 1.0;
    
    _body->CreateFixture(&fd);
}

-(id)initWithWorld:(b2World *)world
{
    //TODO: init sprite for booby
    
    if ((self = [super initWithSpriteFrameName:@"seal1.png"]))
    {
        _world = world;
        [self createBody];
    }
    return self;
}

-(void)update
{
    self.position = ccp(_body->GetPosition().x*PTM_RATIO, _body->GetPosition().y*PTM_RATIO);
    b2Vec2 vel = _body->GetLinearVelocity();
    b2Vec2 weightedVel = vel;
    
    for (int i = 0; i < NUM_PREV_VELS; ++i)
    {
        weightedVel += _prevVels[i];
    }
    weightedVel = b2Vec2(weightedVel.x/NUM_PREV_VELS, weightedVel.y/NUM_PREV_VELS);
    _prevVels[_nextVel++] = vel;
    if (_nextVel >= NUM_PREV_VELS) _nextVel = 0;
    
    float angle = ccpToAngle(ccp(vel.x, vel.y));  
    if (_awake) {  
        self.rotation = -1 * CC_RADIANS_TO_DEGREES(angle);
    }
}

@end
