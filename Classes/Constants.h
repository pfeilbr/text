/*
 *  Constants.h
 *  text
 *
 *  Created by Brian Pfeil on 4/29/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#define kKeyItem @"item"

#define BPItemPropertyType @"BPItemPropertyType"
#define BPItemPropertyName @"BPItemPropertyName"
#define BPItemPropertyPath @"BPItemPropertyPath"

#define BPItemPropertyModifyModeNew @"BPItemPropertyModifyModeNew"
#define BPItemPropertyModifyModeRename @"BPItemPropertyModifyModeRename"

#define BPItemPropertyTypeFile @"BPItemPropertyTypeFile"
#define BPItemPropertyTypeFolder @"BPItemPropertyTypeFolder"

#define BPInvalidFileNameCharaters @"/\:*?\"'<>,"

#define BPDefaultsLastItemDisplayed @"BPDefaultsLastItemDisplayed"

#define BPItemSelectedNotification @"BPItemSelectedNotification"
#define BPSelectItemInItemListNotification @"BPSelectItemInItemListNotification"
#define BPAddNewFileNotification @"BPAddNewFileNotification"
#define BPRenameFileNotification @"BPRenameFileNotification"
#define BPAddNewFolderNotification @"BPAddNewFolderNotification"
#define BPItemDeletedNotification @"BPItemDeletedNotification"

#define BPItemActionEmailFile @"Email"
#define BPItemActionCopyFileToClipboard @"Copy to Clipboard"
#define BPItemActionNewFile @"New File"
#define BPItemActionRenameFile @"Rename File"
#define BPItemActionMoveFile @"Move File"
#define BPItemActionNewFolder @"New Folder"
#define BPItemActionRenameFolder @"Rename Folder"
#define BPItemActionMoveFolder @"Move Folder"

#define BPAddNewFileTitle @"File Name"
#define BPRenameFileTitle @"Rename File"
#define BPAddNewFolderTitle @"Folder Name"

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



