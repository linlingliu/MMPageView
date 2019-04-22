//
//  MMTFCodeView.swift
//  RXSwiftDemo
//
//  Created by sameway on 2019/4/19.
//  Copyright © 2019 sameway. All rights reserved.
//

import UIKit

class MMTFCodeView: UIView {

    var codeString :String?  {
        return self.textField.text
    }
    fileprivate var itemCount:Int!
    fileprivate var itemMargin:Int!
    fileprivate let textField = UITextField()
    fileprivate let coverView:UIButton = UIButton(type: .custom)
    fileprivate var labels:[MMTFCodeCursorLabel] = []
    fileprivate var lines :[UIView] = []
    fileprivate var currentCursorLabel:MMTFCodeCursorLabel?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    convenience init(frame:CGRect, count:Int,margin:Int) {
        self.init(frame: frame)
        self.itemCount = count
        self.itemMargin = margin
        self.configTextField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MMTFCodeView {
    func configTextField() -> Void {
       self.backgroundColor = .white
        textField.autocapitalizationType = .none
        textField.keyboardType = .numberPad
        textField.addTarget(self, action: #selector(tfEditingChanged(tf:)), for: .editingChanged)
        self.addSubview(textField)
        
        coverView.backgroundColor = .white
        coverView.addTarget(self, action: #selector(clickCoverView(sender:)), for: .touchUpInside)
        self.addSubview(coverView)
        
        for _ in 0..<itemCount {
            let label = MMTFCodeCursorLabel()
            label.textAlignment = .center
            label.textColor = .darkText
            label.font = UIFont.systemFont(ofSize: 41.5)
            self.addSubview(label)
            self.labels.append(label)
        }
        for _ in 0..<itemCount {
            let line = UIView()
            line.backgroundColor = .purple
            self.addSubview(line)
            self.lines.append(line)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.labels.count != self.itemCount {
            return
        }
        let temp = self.bounds.self.width - CGFloat(self.itemMargin * (self.itemCount - 1))
        let w = temp / CGFloat(self.itemCount)
        var x:Double
        for index in 0..<self.itemCount {
            x = Double(CGFloat(index) * (w + CGFloat(self.itemMargin)))
            let label = self.labels[index]
            label.frame = CGRect(x: CGFloat(x), y: 0, width: w, height: self.bounds.size.height)
            let line = self.lines[index]
            line.frame = CGRect(x: CGFloat(CFloat(x)), y: self.bounds.size.height - 1.0, width: w, height: CGFloat(1))
        }
        self.textField.frame = self.bounds;
        self.coverView.frame = self.bounds;
    }
    
    override func endEditing(_ force: Bool) -> Bool {
        self.textField.endEditing(force)
        self.currentCursorLabel?.stopAnimating()
       return super.endEditing(force)
        
    }
}

extension MMTFCodeView {
    
    @objc func tfEditingChanged(tf:UITextField) -> Void {
        let length = tf.text?.count ?? 0
        guard let content = tf.text else {
            return ;
        }
        
        if length > self.itemCount {
            let index1 = content.startIndex
            let index2 = content.index(index1, offsetBy: self.itemCount)
            tf.text = String(content[index1 ..< index2])
        }
        for i in 0..<self.itemCount {
            let label = self.labels[i]
            if i < length {
               let index1 = content.startIndex
               let index2 = content.index(index1, offsetBy: i)
               let index3 = content.index(index2, offsetBy: 1)
               label.text = String(content[index2..<index3])
            }else{
                label.text = nil
            }
            self.cursor()
            if length >= self.itemCount {
                self.currentCursorLabel?.stopAnimating()
                tf.resignFirstResponder()
            }
        }
    }
    @objc func clickCoverView(sender:UIButton) -> Void {
        self.textField.becomeFirstResponder()
        self.cursor()
    }
    
    
}

extension MMTFCodeView {
    func cursor() -> Void {
       self.currentCursorLabel?.stopAnimating()
        var index = self.codeString?.count ?? 0
        if index >= self.labels.count {
            index = self.labels.count - 1
        }
        let label = self.labels[index]
        label.startAnimating()
        self.currentCursorLabel = label
    }
}
