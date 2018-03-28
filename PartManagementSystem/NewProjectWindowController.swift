//
//  NewProjectWindowController.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/16.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa

class NewProjectWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    }
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        return contentViewController?.makeTouchBar()
    }
}
