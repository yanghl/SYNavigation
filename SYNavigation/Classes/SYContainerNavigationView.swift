//
//  SYContainerNavigationView.swift
//  sjwz_swift_Example
//
//  Created by che on 2019/7/31.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

public enum SYNavigatorViewAligment:Int {
    case Left = 0
    case Center
}

open class SYContainerNavigationView: UIView {
    //public
    open var customHeight:CGFloat = 44.0
    open var items:Array<String> = []
    open var normalTextColor = UIColor.gray{
        didSet{
            self.buttons.forEach { (btn) in
                btn.setTitleColor(self.normalTextColor, for: .normal)
            }
        }
    }
    open var selectedTextColor = UIColor.black {
        didSet{
            self.buttons.forEach { (btn) in
                btn.setTitleColor(self.selectedTextColor, for: .selected)
                btn.setTitleColor(self.selectedTextColor, for: .highlighted)
            }
        }
    }
    open var normalTextFont = UIFont.systemFont(ofSize: 14) {
        didSet{
            self.buttons.forEach { (btn) in
                if btn != self.selectedBtn {
                    btn.titleLabel?.font = self.normalTextFont
                }
            }
        }
    }
    open var selectedTextFont = UIFont.systemFont(ofSize: 18){
        didSet{
            self.selectedBtn.titleLabel?.font = self.normalTextFont
        }
    }
    open var borderColor = UIColor.blue {
        didSet{
            self.selectLayer.backgroundColor=borderColor.cgColor
        }
    }
    open var borderSize = CGSize(width: 30, height: 2) {
        didSet{
            self.selectLayer.frame = CGRect(origin: self.selectLayer.frame.origin, size:borderSize )
        }
    }
    open var margin:CGFloat = 8
    open var aligment:SYNavigatorViewAligment = .Center //只有当总宽度小于容器宽度才有效
   
    //private
    //如果需要selectedIndex值。请调用SYContainerViewController的selectedIndex属性
    private var selectedIndex = 0
    private var scrollView:UIScrollView = {
        var scroll = UIScrollView()
        scroll.scrollsToTop=false
        scroll.bounces=true
        scroll.showsVerticalScrollIndicator=false
        scroll.showsHorizontalScrollIndicator=false
        scroll.contentInset=UIEdgeInsets.zero
        scroll.backgroundColor=UIColor.clear
        return scroll
    }()
    private var selectLayer:CALayer = {
        var layer = CALayer ()
        layer.backgroundColor = UIColor.blue.cgColor
        layer.frame = CGRect(x: 0, y: 0, width: 30, height: 2)
        return layer
    }()
    
    private var buttonFrames:Array<CGFloat>=[]
    private var selectedBtn:UIButton!
    private var buttons:Array<UIButton> = []
    
    var block:((_ selectedIndex:Int) -> Void)!
    convenience init(block:@escaping ((_ selectedIndex:Int) -> Void)) {
        self.init()
        self.addSubview(self.scrollView)
        self.scrollView.layer.addSublayer(self.selectLayer)
        self.selectLayer.backgroundColor=self.borderColor.cgColor
        self.block=block
    }
    
    func setItems(_ items:Array<String>) {
        self.items = items
        self.buttonFrames=[]//清空
        
        self.buttons.forEach { (btn) in
            btn.removeFromSuperview()
        }
        self.buttons=[]//清空
        self.items.forEach { (title) in
            let btn = UIButton()
            btn.setTitle(title, for: .normal)
            btn.addTarget(self, action: #selector(self.btnClick(sender:)), for: .touchUpInside)
            btn.setTitleColor(self.normalTextColor, for: .normal)
            btn.setTitleColor(self.selectedTextColor, for: .selected)
            btn.setTitleColor(self.selectedTextColor, for: .highlighted)
            btn.titleLabel?.font = self.normalTextFont
            btn.titleLabel?.textAlignment = .center
            btn.tag=self.buttons.count//刚好一一对应
            self.scrollView.addSubview(btn)
            self.buttons.append(btn)
            let key = title as NSString
            let frame = key.boundingRect(with: CGSize(width: 0, height: 30), options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: [NSAttributedString.Key.font:self.selectedTextFont], context: nil)
            self.buttonFrames.append(frame.size.width)
            
        }
        //设置默认选项
        self.selectedBtn=self.buttons.first
        self.selectedBtn.isSelected = true
        self.selectedBtn.titleLabel?.font = self.selectedTextFont
        //重新布局
        self.setNeedsLayout()
    }
    
    func setSelectedItemIndex(_ index:Int) {
        if selectedIndex == index {
            return
        }
        self.selectedIndex=index
        self.selectedBtn.isSelected = false
        SYAnimation.scaleAnimation(layer: self.selectedBtn.layer, from: 1.1, to: 1.0, duration: 0.35, remove: false, repeats: 1)
        self.selectedBtn.titleLabel?.font = self.normalTextFont
        self.selectedBtn = self.buttons[index]
        self.selectedBtn.isSelected = true
        self.selectedBtn.titleLabel?.font = self.selectedTextFont
        SYAnimation.scaleAnimation(layer: self.selectedBtn.layer, from: 0.9, to: 1.0, duration: 0.35, remove: false, repeats: 1)
        self.updateOffset(btn: self.selectedBtn)
    }
    
    @objc func btnClick(sender:UIButton) {
        if self.selectedBtn == sender {
            return
        }
        self.setSelectedItemIndex(sender.tag)
        
        block(sender.tag)
    }
    
    //设置选中的button居中
    func updateOffset(btn:UIButton) {
        let offsetX:CGFloat = btn.center.x+self.frame.origin.x - self.center.x;
        var point:CGPoint
        if (offsetX < 0){
            point = CGPoint(x: 0, y: 0)
        }else if (offsetX > (scrollView.contentSize.width - self.bounds.size.width)){
            point = CGPoint(x:scrollView.contentSize.width - self.bounds.size.width , y: 0)
        }else{
            point = CGPoint(x: offsetX, y: 0)
        }
        
        UIView.animate(withDuration: 0.35) {
            self.scrollView.contentOffset=point
        }
        self.selectLayer.position = CGPoint(x: self.selectedBtn.center.x, y: self.frame.size.height-self.selectLayer.frame.size.height-1)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.scrollView.frame=self.bounds
        
        let sum = self.buttonFrames.reduce(0) { $0 + $1 }
        if self.aligment == .Left || sum>self.frame.size.width {
            var x:CGFloat = margin*0.5 , height = self.frame.size.height
            for (index,item) in self.buttons.enumerated() {
                item.frame=CGRect(x: x, y: 0, width: self.buttonFrames[index]+margin, height: height)
                x=item.frame.maxX
            }
            self.scrollView.contentSize=CGSize(width: x, height: height)
        }else{
            var x:CGFloat = 0 , height = self.frame.size.height , width = self.frame.size.width/CGFloat(self.buttonFrames.count)
            for (_,item) in self.buttons.enumerated() {
                item.frame=CGRect(x: x, y: 0, width: width, height: height)
                x=item.frame.maxX
            }
            self.scrollView.contentSize=self.frame.size
        }
        
        self.selectLayer.position = CGPoint(x: self.selectedBtn.center.x, y: self.frame.size.height-self.selectLayer.frame.size.height-1)
        
    }
}
