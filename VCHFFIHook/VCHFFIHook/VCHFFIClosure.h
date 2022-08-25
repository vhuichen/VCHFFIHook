//
//  VCHFFIClosure.h
//  Demo
//
//  Created by vchan on 2022/4/15.
//  Copyright © 2022 vchan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <ffi.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (*CallbackImp)(ffi_cif *, void *, void * _Nullable * _Nullable, void *);

@interface VCHFFIClosure : NSObject

- (instancetype)initWithHookClass:(Class)aClass
                     hookSelector:(SEL)sourceSelector
                           target:(Class)targetClass
                   targetSelector:(SEL)targetSelector
                      callbackImp:(CallbackImp)callbackImp;

@property (nonatomic, assign) IMP targetImp;

@end

NS_ASSUME_NONNULL_END
