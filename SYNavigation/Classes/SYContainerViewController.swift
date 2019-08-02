//
//  SYContainerViewController.swift
//  sjwz_swift_Example
//
//  Created by che on 2019/7/31.
//  Copyright © 2019 CocoaPods. All rights reserved.
//



/*
 1、方便子页面自定义布局 采用frame
 
 */
import UIKit

let SYContainerViewControllerCellIdentify = "SYContainerViewControllerCellIdentify"

open class SYContainerViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    private var collectionView:UICollectionView!
    private lazy var flowLayout=UICollectionViewFlowLayout()
    
    open var viewControllers:Array<UIViewController>=[]
    open var selectedIndex = 0
    open var currentController:UIViewController{
        get{
            return self.viewControllers[self.selectedIndex]
        }
    }
    //可能会被自定义
   open lazy var navigationView = SYContainerNavigationView {
        [unowned self]
        (index) in
        self.willSelectControllerAtIndex(index: index)
        self.didSelectControllerAtIndex(index: index)
    }
    
    // MARK: life cycle func
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.currentController.beginAppearanceTransition(true, animated: animated)
    }
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.currentController.endAppearanceTransition()
        self.updateCollectViewSelection()
    }
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.currentController.beginAppearanceTransition(false, animated: animated)
    }
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.currentController.endAppearanceTransition()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        if self.responds(to: #selector(setter: edgesForExtendedLayout)) {
            self.edgesForExtendedLayout = []
        }
        self.extendedLayoutIncludesOpaqueBars = false
        
        self.setupUI()
        
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let size = self.view.frame.size
        self.navigationView.frame=CGRect(x: 0, y: 0, width: size.width, height: self.navigationView.customHeight)
        self.flowLayout.itemSize = CGSize(width: size.width, height: size.height-self.navigationView.frame.maxY)
        self.collectionView.frame = CGRect(x: 0, y: self.navigationView.frame.maxY, width: size.width, height: size.height-self.navigationView.frame.maxY)
    }
    // MARK: sysytem func
    open override var shouldAutomaticallyForwardAppearanceMethods: Bool{
        return false
    }
    // MARK: custom func
    func setupUI() {
        self.view.addSubview(self.navigationView)
        
        self.flowLayout.scrollDirection = .horizontal
        self.flowLayout.minimumLineSpacing = 0
        self.flowLayout.minimumInteritemSpacing = 0
        
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: self.flowLayout)
        self.view.addSubview(self.collectionView)
        self.collectionView.isPagingEnabled=true
        if #available(iOS 10.0, *) {
            self.collectionView.isPrefetchingEnabled = true
        }
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: SYContainerViewControllerCellIdentify)
        self.collectionView.delegate=self
        self.collectionView.dataSource=self
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.scrollsToTop = false
        self.collectionView.backgroundColor=UIColor.white
    }
    
    open func reLoadDataSources(viewControllers:Array<UIViewController>) {
        if viewControllers.count == 0 {
            assert(true, "viewControllers不能为空")
            return
        }
        self.viewControllers = viewControllers
        self.viewControllers.forEach { (vc) in
            self.addChildViewController(vc)
            
        }
        let items = self.viewControllers.map { (vc:UIViewController) -> String in
            return vc.title ?? ""
        }
        self.navigationView.setItems(items)
        self.navigationView.setSelectedItemIndex(0)
        
        self.reLoadDataSources()
    }
    
    open func reLoadDataSources() {
        assert(self.viewControllers.count != 0, "缺少子视图，请调用 reLoadDataSources(:)函数进行初始化")
        self.collectionView.reloadData()
    }
    //设置当前选中项
    open func setSelectedIndex(index:Int) {
        if self.viewControllers.count>index {
            selectedIndex = index
            self.navigationView.setSelectedItemIndex(index)
            self.updateCollectViewSelection()
        }
    }
    open func willSelectControllerAtIndex(index:Int) {
        self.selectedIndex = index
        self.updateCollectViewSelection()
    }

    open func didSelectControllerAtIndex(index:Int) {
        
    }
    func updateCollectViewSelection() {
        let size = self.view.bounds.size
        let offsetX = size.width * CGFloat(selectedIndex)
        self.collectionView.contentOffset = CGPoint(x: offsetX, y: 0)
    }
    
    // MARK: delegate
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewControllers.count
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SYContainerViewControllerCellIdentify, for: indexPath)
        cell.contentView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        let subView = self.viewControllers[indexPath.row].view!
        subView.frame=cell.bounds
        cell.contentView.addSubview(subView)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let vc = self.viewControllers[indexPath.row]
        vc.beginAppearanceTransition(true, animated: true)
        vc.endAppearanceTransition()
    }
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let vc = self.viewControllers[indexPath.row]
        vc.beginAppearanceTransition(false, animated: true)
        vc.endAppearanceTransition()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let size = self.view.bounds.size
        let index = Int(scrollView.contentOffset.x / size.width)
        selectedIndex = index
        self.navigationView.setSelectedItemIndex(index)
        self.didSelectControllerAtIndex(index: index)
    }
    
    
}
