//
//  BallView.swift
//  Breakout
//
//  Created by hyf on 17/9/5.
//  Copyright © 2017年 hyf. All rights reserved.
//

import UIKit

class BallView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        image = UIImage(named: "first")
        image = image?.withRenderingMode(.alwaysTemplate)
        tintColor = UIColor.blue
        frame.size = image?.size ?? CGSize.zero
    }
    
   
}
