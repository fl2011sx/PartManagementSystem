//
//  LaunchpadView.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/12.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa

class LaunchpadView: NSView {
    
    enum LayoutScheme {
        case `default`
        case big
        case small
    }
    
    enum LaunchpadViewError : Error {
        case sourcePathFoundError
        case settingFileFoundError
    }
    
    var viewController: NSViewController?
    
    init(frame frameRect: NSRect, viewController: NSViewController? = nil, layoutScheme: LayoutScheme = .default) {
        super.init(frame: frameRect)
        // 读取配置文件
        let sourcePath = Bundle.main.path(forResource: "LaunchpadView", ofType: "plist")
        if (sourcePath == nil) {
            error(.sourcePathFoundError)
            return
        }
        let settings = NSDictionary(contentsOfFile: sourcePath!)
        if (settings == nil) {
            error(.settingFileFoundError)
            return
        }
        // 根据布局计算按钮大小
        var amountForColumn: Int
        switch layoutScheme {
        case .default:
            amountForColumn = settings!.object(forKey: "btnAmtDefault") as! Int
        case .big:
            amountForColumn = settings!.object(forKey: "btnAmtBig") as! Int
        case .small:
            amountForColumn = settings!.object(forKey: "btnAmtSmall") as! Int
        }
        let gaugeH = settings!.object(forKey: "guageH") as! CGFloat
        let buttonLength = self.buttonLength(amountForColumn: amountForColumn, gaugeH: gaugeH)
        let amountForRow = Int(frame.width) / Int(buttonLength + gaugeH) // 横向个数
        let gaugeV = (frame.size.width - CGFloat(amountForRow) * buttonLength) / CGFloat(amountForRow + 1)
        // 加载按钮配置文件
        let btnAmount = (NSDictionary(contentsOfFile: Bundle.main.path(forResource: "LoadButton", ofType: "plist")!)?.count)!
        // 计算是否需要扩展屏幕
        let realRowAmount = (btnAmount - 1) / amountForRow + 1
        if frame.size.height < (CGFloat(realRowAmount) * (gaugeH + buttonLength) + gaugeH) {
            setFrameSize(NSSize(width: frame.size.width, height: CGFloat(realRowAmount) * (gaugeH + buttonLength) + gaugeH))
        }
        // 渲染按钮视图
        var x: CGFloat = gaugeV
        var y: CGFloat = frame.size.height - gaugeH - buttonLength
        var Index = 0
        while (Index < btnAmount) {
            let btn = LoadButton(frame: NSRect(x: x, y: y, width: buttonLength, height: buttonLength), name: "btn\(Index + 1)")
            btn.delegate = viewController as? LoadButtonDelegate
            addSubview(btn)
            x += gaugeV + buttonLength
            Index += 1
            if (Index % amountForRow) == 0 {
                x = gaugeV
                y -= gaugeH + buttonLength
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func buttonLength(amountForColumn: Int, gaugeH: CGFloat) -> CGFloat {
        let height = frame.height
        return (height - gaugeH) / CGFloat(amountForColumn) - gaugeH
    }
    fileprivate func error(_ id: LaunchpadViewError) {
        
    }
}


