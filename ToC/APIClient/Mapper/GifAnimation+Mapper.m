//
//  GifAnimation+Mapper.m
//  ToC
//
//  Created by LinYiting on 2016/10/20.
//  Copyright © 2016年 Mobiusbobs. All rights reserved.
//

#import "GifAnimation+Mapper.h"
#import "Mapper.h"

@implementation GifAnimation (Mapper)

+ (RACSignal *)updateObject:(GifAnimation *)animation
                   withData:(NSDictionary *)data
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber)
            {
                animation.uniqueId = data[@"_id"];
                animation.type = data[@"type"];
                animation.imageURL = data[@"imageURL"];
                animation.bounds = data[@"bounds"];
                animation.position = data[@"position"];
                animation.rotation = data[@"rotation"];
                
                [subscriber sendNext:animation];
                [subscriber sendCompleted];
                return nil;
            }];
}

@end
