//
//  BPConfig.h
//  text
//
//  Created by Brian Pfeil on 5/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPConfig : NSObject {

}

+ (BPConfig*)sharedInstance;
- (id)keyboardAccessoryDefinitionForType:(NSString*)type;

@end
