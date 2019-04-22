//
//  MMTFCodeCursorLabel.swift
//  RXSwiftDemo
//
//  Created by sameway on 2019/4/22.
//  Copyright © 2019 sameway. All rights reserved.
//

import UIKit

class MMTFCodeCursorLabel: UILabel {

    var cursorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupUI() -> Void {
        self.cursorView.backgroundColor = .blue
        self.cursorView.alpha = 0.0
        self.addSubview(self.cursorView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let h = 30.0
        let w = 2.0
        let x = self.bounds.size.width * 0.5
        let y = self.bounds.size.height * 0.5
        self.cursorView.frame = CGRect(x: 0.0, y: 0.0, width: w, height: h)
        self.cursorView.center = CGPoint(x: x, y: y)
    }
}

extension MMTFCodeCursorLabel {
    
    func startAnimating() -> Void {
        let length = self.text?.count ?? 0
        if length > 0 {
           return
        }
        let oa = CABasicAnimation(keyPath: "opacity")
        oa.fromValue = NSNumber.init(value: 0)
        oa.toValue = NSNumber.init(value: 1)
        oa.duration = 1
        oa.repeatCount = MAXFLOAT
        oa.isRemovedOnCompletion = false
        oa.fillMode = .forwards
        oa.timingFunction = CAMediaTimingFunction(name: .easeIn)
        self.cursorView.layer.add(oa, forKey: "opacity")
    }
    
    func stopAnimating() -> Void {
        self.cursorView.layer.removeAnimation(forKey: "opacity")
    }
}
