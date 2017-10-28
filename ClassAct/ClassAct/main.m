//
//  main.m
//  ClassAct
//
//  Created by Enrique Aliaga on 10/26/17.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "BNRTowel.h"

NSArray *BNRHierarchyForClass(Class cls)
{
    // Declare an array to hold the list of
    // this class and all its superclasses, building a hierarchy
    NSMutableArray *classHierarchy = [NSMutableArray array];
    
    // Keep climbing the class hierarchy until we get to a class with no superclass
    for (Class c = cls; c != nil; c = class_getSuperclass(c)) {
        NSString *className = NSStringFromClass(c);
        [classHierarchy insertObject:className atIndex:0];
    }
    
    return classHierarchy;
}

NSArray *BNRMethodsForClass(Class cls)
{
    unsigned int methodCount = 0;
    
    Method *methodList = class_copyMethodList(cls, &methodCount);
    
    NSMutableArray *methodArray = [NSMutableArray array];
    
    for (int m = 0; m < methodCount; m++) {
        // Get the current Method
        Method currentMethod = methodList[m];
        // Get the selector for the current method
        SEL methodSelector = method_getName(currentMethod);
        // Add its string representation to the array
        [methodArray addObject:NSStringFromSelector(methodSelector)];
    }
    
    return methodArray;
}

NSArray *BNRInstanceVariablesForClass(Class cls)
{
    unsigned int ivarCount = 0;
    
    Ivar *ivarList = class_copyIvarList(cls, &ivarCount);
    NSMutableArray *ivarArray = [NSMutableArray array];
    
    for (int i = 0; i < ivarCount; i++) {
        Ivar currentIvar = ivarList[i];
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(currentIvar)];
        [ivarArray addObject:ivarName];
    }
    
    return ivarArray;
}

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        
        // Create an array of dictionaries, where each dictionary
        // will end up holding the class name, hierarchy, and method list
        // for a given class.
        NSMutableArray *runtimeClassesInfo = [NSMutableArray array];
        
        // Declare a variable to hold the number of registered classes
        unsigned int classCount = 0;
        
        // Get a pointer to a list of all registered classes
        // currently loaded by your application.
        // The number of registered classes is returned by reference
        Class *classList = objc_copyClassList(&classCount);
        
        // For each class in the list...
        for (int i = 0; i < classCount; i++) {
            
            // Treat the classList as a C array to get a Class from it
            Class currentClass = classList[i];
            
            // Get the class's name as a string
            NSString *className = NSStringFromClass(currentClass);
            
            NSArray *hierarchy = BNRHierarchyForClass(currentClass);
            
            NSArray *methods = BNRMethodsForClass(currentClass);
            
            NSArray *ivars = BNRInstanceVariablesForClass(currentClass);
            
            NSDictionary *classInfoDict = @{ @"classname" : className,
                                             @"hierarchy" : hierarchy,
                                             @"methods" : methods,
                                             @"ivars" : ivars };
            
            [runtimeClassesInfo addObject:classInfoDict];
        }
        
        // We're done with the class list buffer, so free it
        free(classList);
        
        // Sort the classes info array alphabetically by name, and log it.
        NSSortDescriptor *alphaAsc = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        NSArray *sortedArray = [runtimeClassesInfo sortedArrayUsingDescriptors:@[alphaAsc]];
        NSLog(@"There are %ld classes registered with this program's Runtime.", sortedArray.count);
        NSLog(@"%@", sortedArray);
    }
    return 0;
}
