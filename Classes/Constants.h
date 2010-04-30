/*
 *  Constants.h
 *  text
 *
 *  Created by Brian Pfeil on 4/29/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#define kAddNewFile 1
#define kAddNewFileFromTemplate 1
#define kAddNewFolder 1
#define kAddNewProject 1
#define kAddNewProjectFromTemplate 1

#define kActionEmail 1
#define kActionCopyToClipboard 2

#define kItemTypeFile @"file"
#define kItemTypeFolder @"folder"
#define kItemTypeProject @"project"

typedef enum {
	kItemTypeFile,
	kItemTypeFolder,
	kItemTypeProject
} ItemType;



