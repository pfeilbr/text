/*
 *  Constants.h
 *  text
 *
 *  Created by Brian Pfeil on 4/29/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#define BPDropboxConsumerKey @"0ccay36sixvrbmc"
#define BPDropboxConsumerSecret @"arg6tcbel4m08zr"

#define kBPItemStorageTypeRoot @"root"
#define kBPItemStorageTypeFileSystem @"file"
#define kBPItemStorageTypeDropbox @"dropbox"

#define kKeyItem @"item"

#define BPItemPropertyStorageType @"BPItemPropertyStorageType"
#define BPItemPropertyType @"BPItemPropertyType"
#define BPItemPropertyIconName @"BPItemPropertyIconName"
#define BPItemPropertyName @"BPItemPropertyName"
#define BPItemPropertyPath @"BPItemPropertyPath"

#define BPItemPropertyModifyModeNew @"BPItemPropertyModifyModeNew"
#define BPItemPropertyModifyModeRename @"BPItemPropertyModifyModeRename"

/*
#define BPItemPropertyStorageTypeRoot @"BPItemPropertyStorageTypeRoot"
#define BPItemPropertyStorageTypeLocalFileSystem @"BPItemPropertyStorageTypeLocalFileSystem"
#define BPItemPropertyStorageTypeDropbox @"BPItemPropertyStorageTypeDropbox"
*/

#define BPItemPropertyTypeFile @"BPItemPropertyTypeFile"
#define BPItemPropertyTypeFolder @"BPItemPropertyTypeFolder"

#define BPInvalidFileNameCharaters @"/\:*?\"'<>,"

#define BPDefaultsLastItemDisplayed @"BPDefaultsLastItemDisplayed"

#define BPItemSelectedNotification @"BPItemSelectedNotification"
#define BPSelectItemInItemListNotification @"BPSelectItemInItemListNotification"
#define BPDeleteItemInItemListNotification @"BPDeleteItemInItemListNotification"
#define BPAddNewFileNotification @"BPAddNewFileNotification"
#define BPRenameFileNotification @"BPRenameFileNotification"
#define BPAddNewFolderNotification @"BPAddNewFolderNotification"
#define BPRenameFolderNotification @"BPRenameFolderNotification"
#define BPItemDeletedNotification @"BPItemDeletedNotification"

#define BPToggleFullScreenNotification @"BPToggleFullScreenNotification"

#define BPSettingsChangedNotification @"BPSettingsChangedNotification"

#define BPItemActionEmailFile @"Email"
#define BPItemActionCopyFileToClipboard @"Copy to Clipboard"
#define BPItemActionNewFile @"New File"
#define BPItemActionRenameFile @"Rename File"
#define BPItemActionMoveFile @"Move File"
#define BPItemActionNewFolder @"New Folder"
#define BPItemActionRenameFolder @"Rename Folder"
#define BPItemActionMoveFolder @"Move Folder"
#define BPItemActionWebPreview @"Web Preview"
#define BPItemActionCancel @"Cancel"


#define BPAddNewFileTitle @"File Name"
#define BPRenameFileTitle @"Rename File"
#define BPAddNewFolderTitle @"Folder Name"
#define BPRenameFolderTitle @"Rename Folder"

#define kAddNewFile 0
#define kAddNewFileFromTemplate 1
#define kAddNewFolder 1 
#define kAddNewProject 2
#define kAddNewProjectFromTemplate 1

#define kActionEmail 1
#define kActionCopyToClipboard 2

#define kConfigBaseDirectoryName @"config"
#define kConfigKeyboardAccessoryDefinitionsDirectoryName @"keyboard_accessory_definitions"

#define kDropboxSmallIconsBaseDirectoryName @"dropbox-api-icons/16x16"
#define kDropboxLargeIconsBaseDirectoryName @"dropbox-api-icons/48x48"


//#define kItemTypeFile @"file"
//#define kItemTypeFolder @"folder"
//#define kItemTypeProject @"project"

typedef enum tagItemType {
	kItemTypeFile,
	kItemTypeFolder,
	kItemTypeProject
} ItemType;



