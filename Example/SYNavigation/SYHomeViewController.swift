//
//  SYHomeViewController.swift
//  SYNavigation_Example
//
//  Created by che on 2019/8/2.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SYNavigation

class SYHomeViewController: SYContainerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var arr = Array<UIViewController>()
        for index in 0..<20 {
            arr.append(ViewController(title: "新闻\(index)"))
        }
        self.reLoadDataSources(viewControllers: arr)
        
        //如果你想自定义导航栏样式 self.navigationView开放了很多的属性供你设置
        self.navigationView.borderColor=UIColor.red
        self.navigationView.normalTextColor=UIColor.black
        self.navigationView.selectedTextColor=UIColor.blue
    }
    


}
