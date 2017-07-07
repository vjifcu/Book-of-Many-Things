//
//  MyCollectionViewCell.swift
//  Book of Many Things
//
//  Created by Victor Jifcu on 2017-06-13.
//  Copyright © 2017 Victor Jifcu. All rights reserved.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
    
    var label:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = UIFont(name: "TeXGyreBonum-Regular", size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    
    func setupViews() {
        backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        addSubview(self.label)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": label]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": label]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
