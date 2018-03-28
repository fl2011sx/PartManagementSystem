//
//  LoadButton.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/12.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa

protocol LoadButtonDelegate {
    func btnClick(_ sender: LoadButton)
}

class LoadButton: NSButton {
    
    enum LoadButtonError : Error {
        case sourcePathFoundError
        case settingFileFoundError
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var delegate: LoadButtonDelegate?
    var name: String
    var targetFunctionName: String?
    
    init(frame frameRect: NSRect, name: String, needImage: Bool = true) {
        self.name = name
        super.init(frame: frameRect)
        // 加载配置文件
        let path = Bundle.main.path(forResource: "LoadButton", ofType: "plist")
        if (path == nil) {
            error(.sourcePathFoundError)
            return
        }
        let settings = NSDictionary(contentsOfFile: path!)
        if (settings == nil) {
            error(.settingFileFoundError)
            return
        }
        // 设置图片
        if needImage {
            self.image = NSImage(named: (settings!.value(forKey: name) as! NSDictionary).value(forKey: "imagePath") as! String)
            self.imageScaling = .scaleAxesIndependently
        }
        // 按钮模板设置
        self.bezelStyle = .texturedSquare
        // 触发事件
        targetFunctionName = (settings?.value(forKey: name) as? NSDictionary)?.value(forKey: "targetFunction") as? String
        self.target = self
        self.action = #selector(btnClick(_:))
    }
    // MARK:- button click functions
    @objc func btnClick(_ sender: LoadButton) {
        if delegate != nil {
            delegate?.btnClick(sender)
        }
    }
    // MARK:- error process
    fileprivate func error(_ id: LoadButtonError) {
        Swift.print(id)
    }
}
