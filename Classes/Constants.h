/*
 *  Constants.h
 *  text
 *
 *  Created by Brian Pfeil on 4/29/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#define kKeyItem @"item"

#define BPItemSelectedNotification @"BPItemSelectedNotification"
#define BPAddNewFileNotification @"BPAddNewFileNotification"
#define BPItemDeletedNotification @"BPItemDeletedNotification"

#define kAddNewFile 0
#define kAddNewFileFromTemplate 1
#define kAddNewFolder 1 
#define kAddNewProject 2
#define kAddNewProjectFromTemplate 1

#define kActionEmail 1
#define kActionCopyToClipboard 2

#define kConfigBaseDirectoryName @"config"
#define kConfigKeyboardAccessoryDefinitionsDirectoryName @"keyboard_accessory_definitions"


//#define kItemTypeFile @"file"
//#define kItemTypeFolder @"folder"
//#define kItemTypeProject @"project"

typedef enum tagItemType {
	kItemTypeFile,
	kItemTypeFolder,
	kItemTypeProject
} ItemType;



