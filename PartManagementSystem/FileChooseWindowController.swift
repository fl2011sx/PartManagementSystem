//
//  FileChooseWindowController.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/13.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa

class FileChooseWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
    }
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        return contentViewController?.makeTouchBar()
    }
}
