//
//  MMPageView.swift
//  RXSwiftDemo
//
//  Created by sameway on 2019/4/17.
//  Copyright © 2019 sameway. All rights reserved.
//

import UIKit

//MARK: UIView - category
extension UIView {
    var MM_Top :CGFloat {
        get {
            return frame.origin.y
        }
        set {
            var original = frame
            original.origin.y = newValue
            frame = original
        }
    }
    
    var MM_Right :CGFloat {
        get {
            return frame.origin.x + frame.size.width
        }
        set {
            var original = frame
            original.origin.x = newValue - frame.origin.x
            frame = original
        }
    }
    
    var MM_Bottom :CGFloat {
        get {
            return frame.origin.y + frame.size.height
        }
        set {
            var original = frame
            original.origin.y = newValue - frame.size.height
            frame = original
        }
    }
    
    var MM_Left :CGFloat {
        get {
            return frame.origin.x
        }
        set {
            var original = frame
            original.origin.x = newValue
            frame = original
        }
    }
    
    var MM_Width :CGFloat {
        get {
            return frame.size.width
        }
        set {
            var original = frame
            original.size.width = newValue
            frame = original
        }
    }
    
    var MM_Height :CGFloat {
        get {
            return frame.size.height
        }
        set {
            var original = frame
            original.size.height = newValue
            frame = original
        }
    }
    
}
@objc protocol MMPageViewDelegate : NSObjectProtocol {
    func pageViewWithIndex(index:Int) -> UIView
    @objc optional func pageViewDidScrollViewToIndex(index:Int)
}

class MMPageView: UIView {

    weak var delegate : MMPageViewDelegate?
    var defaultIndex : Int = 0
    var currentIndex : Int = 0
    var scrlooEnabled : Bool  {
        didSet {
            ContentScrollView?.isScrollEnabled = scrlooEnabled
        }
    }
    private var indicator :UIView = UIView()
    private var headerScrollView : UIScrollView?
    private var ContentScrollView:UIScrollView?
    private var recordInfo :[String:String] = [:]
    private var itemTitle:[String] = []
    private var currentButton :UIButton?
    override init(frame: CGRect) {
        self.scrlooEnabled = true
        super.init(frame: frame)
        
    }
    
    convenience init(frame:CGRect, items:[String],headerFrame:CGRect, dataSourec:MMPageViewDelegate) {
        self.init(frame: frame)
        delegate = dataSourec;
        itemTitle = items
        headerScrollView = {
            let scrollView = UIScrollView()
            scrollView.frame = headerFrame
            scrollView.delegate = self
            scrollView.backgroundColor = .white
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.layer.shadowColor = UIColor.lightGray.cgColor
            scrollView.layer.shadowOffset = CGSize(width: 2, height: 2)
            self.addSubview(scrollView)
            return scrollView
        }()
        ContentScrollView = {
         let scrollView = UIScrollView(frame: CGRect(x: 0, y: headerScrollView!.MM_Bottom, width: self.MM_Width, height: self.MM_Height - headerScrollView!.MM_Bottom))
            scrollView.delegate = self
            scrollView.contentSize = CGSize(width: self.MM_Width * CGFloat(itemTitle.count), height: 0)
            scrollView.isPagingEnabled = true
            scrollView.setContentOffset(CGPoint(x: 0, y: 1), animated: false)
            if #available(iOS 11.0, *) {
                scrollView.contentInsetAdjustmentBehavior = .never
            }
            self.addSubview(scrollView)
            return scrollView
        }()
        var w :Int = 0
        if itemTitle.count > 5 {
           w = (Int(headerFrame.size.width) - 50) / 5
        }else{
           w = Int(headerFrame.size.width) / itemTitle.count
        }
        let h = headerFrame.size.height
        for index in 0 ..< itemTitle.count {
            let btn = UIButton(type: .custom)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
            btn.setTitle(itemTitle[index], for: .normal)
            btn.setTitleColor(.lightGray, for: .normal)
            btn.setTitleColor(.red, for: .selected)
            btn.sizeToFit()
            btn.tag = 100 + index
            btn.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
            btn.frame = CGRect(x: CGFloat(index * w), y: 0, width: CGFloat(w), height: h)
            headerScrollView?.addSubview(btn)
        }
        headerScrollView?.contentSize = CGSize(width: w * itemTitle.count, height: Int(h))
        let lineView = UIView(frame: CGRect(x: 0, y: Int(headerFrame.size.height - 1), width: Int(headerScrollView!.contentSize.width), height: 1))
        lineView.backgroundColor = .lightGray
        headerScrollView?.addSubview(lineView)
        
        indicator.MM_Width = CGFloat(60)
        indicator.MM_Height = CGFloat(2)
        indicator.MM_Top = headerScrollView!.MM_Height - indicator.MM_Height
        indicator.layer.cornerRadius = 1
        indicator.layer.masksToBounds = true
        indicator.MM_Right = 0
        indicator.backgroundColor = .yellow
        headerScrollView?.addSubview(indicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    func selectedIndex(index: Int) -> Bool {
        let btn:UIButton? = self.viewWithTag(index + 100) as? UIButton
        if let button = btn {
            self.buttonAction(sender: button)
            return true
        }else{
            return false
        }
    }
    @objc func buttonAction(sender: UIButton) -> Void {
        if sender == currentButton {
            return
        }
        if sender.tag - 100 >= itemTitle.count {
            return
        }
        sender.isSelected = true
        self.currentButton?.isSelected = false
        self.currentButton = sender
        UIView.animate(withDuration: 0.3) {
            if sender.titleLabel?.MM_Width ?? 0.0 > 0.0 {
                self.indicator.MM_Width = sender.titleLabel?.MM_Width ?? 0.0
            }
            self.indicator.center = CGPoint(x: sender.center.x, y: self.indicator.center.y)
        }
        var offsetX = sender.center.x - self.MM_Width * 0.5
        let maxOffsetX = self.headerScrollView!.contentSize.width - self.MM_Width
        if offsetX < 0.0 {
            offsetX = 0.0
        }else if offsetX > maxOffsetX {
            offsetX = maxOffsetX
        }
        headerScrollView!.setContentOffset(CGPoint(x: offsetX, y: 0.0), animated: true)
        let index = sender.tag - 100
        ContentScrollView?.setContentOffset(CGPoint(x: CGFloat(index) * self.MM_Width, y: 0), animated: false)
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}

extension MMPageView {
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview != nil {
            let sender = headerScrollView?.viewWithTag(100 + currentIndex) as? UIButton
            if let btn = sender {
                self.buttonAction(sender: btn)
            }else {
                self.buttonAction(sender: headerScrollView?.viewWithTag(100) as? UIButton ?? UIButton())
            }
        }
    }
}

extension MMPageView : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == ContentScrollView {
            let index = scrollView.contentOffset.x / self.MM_Width
            currentIndex = Int(index)
            let recordKey:String = "\(Int(index))"
            let ret :Bool = (self.recordInfo[recordKey] != nil) ? true : false
            if !ret {
                let view:UIView? = delegate?.pageViewWithIndex(index: Int(index))
                if let viewOk = view {
                    viewOk.frame = CGRect(x: Int(self.MM_Width * index), y: 0, width: Int(self.MM_Width), height: Int(self.MM_Height - scrollView.MM_Top))
                    scrollView.addSubview(viewOk)
                    recordInfo[recordKey] = recordKey
                }
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == ContentScrollView {
            let index = scrollView.contentOffset.x / self.MM_Width
            self.selectedIndex(index: Int(index))
        }
    }
}
