//
//  VCHFFIHook.h
//  Demo
//
//  Created by vchan on 2022/4/15.
//  Copyright © 2022 sunnyxx. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VCHFFIHook : NSObject

+ (BOOL)hookClass:(Class)aClass
     hookSelector:(SEL)sourceSelector
           target:(Class)target
   targetSelector:(SEL)targetSelector;

@end

NS_ASSUME_NONNULL_END
