//
//  JChiBaoZiFooter.swift
//  TSRefreshExanple
//
//  Created by Lee on 2018/8/23.
//  Copyright © 2018年 LEE. All rights reserved.
//

import UIKit
import TSRefresh

class JChiBaoZiFooter: TSRefreshAutoGifFooter {
    // MARK: - 重写方法-基本设置

    override func prepare() {
        super.prepare()
        // 设置正在刷新状态的动画图片
        var refreshingImages: [UIImage] = []
        for i in 1 ... 3 {
            let image = UIImage(named: "dropdown_loading_0\(i)")
            refreshingImages.append(image!)
        }
        setImages(refreshingImages, .Refreshing)
    }
}
