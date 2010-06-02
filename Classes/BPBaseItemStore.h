//
//  BPBaseItemStore.h
//  text
//
//  Created by Brian Pfeil on 5/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPItem.h"

@interface BPBaseItemStore : NSObject {

}

- (BPItem*)fileItem;
- (BPItem*)folderItem;

@end
