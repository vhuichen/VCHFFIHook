//
//  NSMethodSignature+VCHFFI.h
//  Demo
//
//  Created by vchan on 2022/4/15.
//  Copyright © 2022 vchan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ffi.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMethodSignature (VCHFFI)

- (ffi_type *)ffi_getArgumentTypeAtIndex:(NSUInteger)idx;
- (ffi_type *)ffi_methodReturnType;

@end

NS_ASSUME_NONNULL_END
