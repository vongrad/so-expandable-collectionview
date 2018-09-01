//
//  ContentCell.swift
//  ExpandableCollectionView
//
//  Created by Adam Vongrej on 9/1/18.
//  Copyright © 2018 AV. All rights reserved.
//

import UIKit

class ContentCell: UICollectionViewCell {
    
    static let CELL_ID = "contentCell"
    
    var lblTitle: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        lblTitle = UILabel()
        lblTitle.text = "Content"
        addSubview(lblTitle)
        
        lblTitle.translatesAutoresizingMaskIntoConstraints = false
        lblTitle.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        lblTitle.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
}
