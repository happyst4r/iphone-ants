#import "Vector.h"

@implementation Vector
+ (CGPoint) add: (CGPoint) vec1 to: (CGPoint) vec2
{
    vec2.x += vec1.x;
    vec2.y += vec1.y;
    return vec2;
}

+ (CGPoint) truncate: (CGPoint) vec to: (float) max
{
    // this is not true truncation, but is much faster
    if (vec.x > max) vec.x = max;
    if (vec.y > max) vec.y = max;
    if (vec.y < -max) vec.y = -max;
    if (vec.x < -max) vec.x = -max;
    return vec;
}

+ (CGPoint) multiply: (CGPoint) vec by: (float) factor
{
    vec.x *= factor;
    vec.y *= factor;
    return vec;
}

+ (float) lengthSquared: (CGPoint) vec
{
    return (vec.x*vec.x + vec.y*vec.y);
}

+ (float) length: (CGPoint) vec
{
    return sqrt([Vector lengthSquared: vec]);
}

@end
