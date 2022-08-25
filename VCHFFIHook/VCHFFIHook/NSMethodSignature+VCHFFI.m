//
//  NSMethodSignature+VCHFFI.m
//  Demo
//
//  Created by vchan on 2022/4/15.
//  Copyright © 2022 vchan. All rights reserved.
//

#import "NSMethodSignature+VCHFFI.h"

@implementation NSMethodSignature (VCHFFI)

- (ffi_type *)ffi_getArgumentTypeAtIndex:(NSUInteger)idx {
    const char *type = [self getArgumentTypeAtIndex:idx];
    
    if (strcmp(type, "i") == 0) {
        return &ffi_type_sint32;
    }
    
    NSLog(@"参数类型异常，需要手动解析:%s", type);
    return &ffi_type_pointer;
}

- (ffi_type *)ffi_methodReturnType {
    if (strcmp(self.methodReturnType, "v") == 0) {
        return &ffi_type_void;
    } else if (strcmp(self.methodReturnType, "i") == 0) {
        return &ffi_type_sint32;
    } else {
        NSLog(@"返回值类型异常，需要手动解析:%s",  self.methodReturnType);
    }
    
    return &ffi_type_pointer;
}

@end
