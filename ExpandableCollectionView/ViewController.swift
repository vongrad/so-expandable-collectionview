//
//  ViewController.swift
//  ExpandableCollectionView
//
//  Created by Adam Vongrej on 9/1/18.
//  Copyright © 2018 AV. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    let itemsCount = 3
    let itemsPerRow = 3
    var reminder: Int = 0
    
    var expandedCell: IndexPath?
    
    let heightHeader: CGFloat = 60
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView!.register(ContentCell.self, forCellWithReuseIdentifier: ContentCell.CELL_ID)
        collectionView?.register(HeaderCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HeaderCell.CELL_ID)
        
        collectionView?.backgroundColor = UIColor.white
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        reminder = itemsCount % itemsPerRow
        return itemsCount * 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isDetailCell(indexPath: indexPath) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCell.CELL_ID, for: indexPath) as! ContentCell
            cell.lblTitle.text = "Detail \(indexPath.item)"
            cell.layer.masksToBounds = true
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = UIColor.black.cgColor
            cell.backgroundColor = UIColor.red
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCell.CELL_ID, for: indexPath) as! ContentCell
            cell.lblTitle.text = "Content \(indexPath.item)"
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = UIColor.black.cgColor
            cell.backgroundColor = UIColor.green
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HeaderCell.CELL_ID, for: indexPath) as! HeaderCell
            header.backgroundColor = UIColor.blue
            header.lblTitle.text = "Section header \(indexPath.section)"
            return header
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / CGFloat(itemsPerRow)
        
        if isDetailCell(indexPath: indexPath) {
            if expandedCell == indexPath {
                return CGSize(width: collectionView.frame.size.width, height: width)
            } else {
                return CGSize(width: collectionView.frame.size.width, height: 0)
            }
        } else {
            return CGSize(width: width, height: width)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: heightHeader)
    }
    
    private func isDetailCell(indexPath: IndexPath) -> Bool {
        return (indexPath.item / itemsPerRow) % 2 == 1 || indexPath.item > (collectionView!.numberOfItems(inSection: 0) - 1) - (reminder)
    }
    
    private func isLastRow(indexPath: IndexPath) -> Bool {
        let total = collectionView!.numberOfItems(inSection: indexPath.section)
        return indexPath.item > (total - 1) - (2 * reminder) && indexPath.item < total - reminder
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isDetailCell(indexPath: indexPath) {
            return
        }
        
        var offset = itemsPerRow
        if isLastRow(indexPath: indexPath) {
            offset = reminder
        }
        
        let new = IndexPath(item: indexPath.item + offset, section: indexPath.section)
        var prev: IndexPath?
        if let expandedCell = expandedCell {
            prev = IndexPath(item: expandedCell.item, section: expandedCell.section)
        }
        
        if expandedCell == new {
            expandedCell = nil
        } else {
            expandedCell = new
        }
        
        //invalidateLayoutUsingNewLayout()
        invalidateLayoutUsingContext(prev: prev, new: new)
    }
    
    // Invalidate collection view supposedly the correct way
    // Currently does not work as suplementary views (header) does not get rendered
    func invalidateLayoutUsingContext(prev: IndexPath?, new: IndexPath) {
        
        guard let collectionView = collectionView else { return }
        
        var minSection: Int = new.section
        var minItem: Int = new.item
        
        if let prev = prev {
            if prev.section == new.section {
                minItem = min(prev.item, new.item)
            }
            else if prev.section < new.section {
                minSection = prev.section
                minItem = prev.item
            }
        }
        
        let context = UICollectionViewFlowLayoutInvalidationContext()
        
        let supplementaryIndexPaths = (minSection + 1..<collectionView.numberOfSections).map { IndexPath(item: 0, section: $0)}
        
        var cellIndexPaths = (minItem..<collectionView.numberOfItems(inSection: minSection)).map { IndexPath(item: $0, section: minSection) }
        for section in minSection + 1..<collectionView.numberOfSections {
            cellIndexPaths.append(contentsOf: (0..<collectionView.numberOfItems(inSection: section)).map { IndexPath(item: $0, section: section) })
        }
        
        context.invalidateSupplementaryElements(ofKind: UICollectionElementKindSectionHeader, at: supplementaryIndexPaths)
        context.invalidateItems(at: cellIndexPaths)
        context.invalidateFlowLayoutAttributes = true
        context.invalidateFlowLayoutDelegateMetrics = true
        
        UIView.animate(withDuration: 0.25) {
            collectionView.collectionViewLayout.invalidateLayout(with: context)
            collectionView.layoutIfNeeded()
        }
    }
}

