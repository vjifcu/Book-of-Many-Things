//
//  SpellViewController.swift
//  Book of Many Things
//
//  Created by Victor Jifcu on 2017-06-08.
//  Copyright © 2017 Victor Jifcu. All rights reserved.
//

import UIKit

class SpellViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var nameLabel: UILabel!
    var infoFields = [UILabel]()
    
    var scrollView = UIScrollView()
    var innerView = UIView()
    var stackView = UIStackView()
    
    let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    var numTables = 0
    
    var tableData = [[String]]()
    var tables = [UICollectionView]()

    var spell: Spell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView.axis = .vertical
        //stackView.spacing = 1
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(innerView)
        innerView.addSubview(stackView)
        
        //scrollView Constraints
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        innerView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: scrollView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true

        NSLayoutConstraint(item: innerView, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: innerView, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: innerView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: innerView, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: innerView, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1.0, constant: 0).isActive = true

        NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: innerView, attribute: .leading, multiplier: 1.0, constant: 8).isActive = true
        NSLayoutConstraint(item: stackView, attribute: .trailing, relatedBy: .equal, toItem: innerView, attribute: .trailing, multiplier: 1.0, constant: -8).isActive = true
        NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal, toItem: innerView, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: innerView, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true

        
        nameLabel = UILabel()
        nameLabel.font = UIFont(name: "TeXGyreBonum-Regular", size: 24)
        stackView.addArrangedSubview(nameLabel)
        
        
        if let spell = spell{

            if let fields = spell.infoFields{
                for (key, value) in fields{
                    let formattedString = NSMutableAttributedString()
                    let label = UILabel()
                    label.font = UIFont(name: "TeXGyreBonum-Regular", size: 17)
                    label.numberOfLines = 0
                    if let field = value as? String{
                        label.attributedText = formattedString.bold(key + ": ").normal(field)
                    }
                    else if let texts = value as? [String]{
                        var labelText = formattedString.bold(key + ": ")
                        for text in texts{
                            labelText = labelText.normal(text + ", ")
                        }
                        labelText.deleteCharacters(in: NSMakeRange(labelText.length-2, 2))
                        label.attributedText = labelText
                    }
                    stackView.addArrangedSubview(label)
                    infoFields.append(label)
                }
            }
            
            
            var combinedDesc = [Any]()
            
            if let tables = spell.table{

                
                let commonLength = min(spell.description.count, tables.count)
                combinedDesc = zip(spell.description, tables).flatMap { [$0, $1] }

                for desc in spell.description.suffix(from: commonLength){
                    combinedDesc.append(desc)
                }
                
                for table in tables.suffix(from: commonLength){
                    combinedDesc.append(table)
                }
                
                for items in combinedDesc{
                    if let desc = items as? [String]{
                        let newLabel = UILabel()
                        newLabel.text = desc.joined(separator: "\n\n")
                        newLabel.font = UIFont(name: "TeXGyreBonum-Regular", size: 15)
                        newLabel.numberOfLines = 0
                        stackView.addArrangedSubview(newLabel)
                    } else if let table = items as? [[String]]{
                        self.tables.append(UICollectionView(frame: self.view.frame, collectionViewLayout: UICollectionViewFlowLayout()))
                        self.tables[numTables].dataSource = self
                        self.tables[numTables].delegate = self
                        self.tables[numTables].register(MyCollectionViewCell.self, forCellWithReuseIdentifier: String(numTables))
                        self.tables[numTables].backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
                        self.stackView.addArrangedSubview(self.tables[numTables])
                        let constraintHeight = NSLayoutConstraint(item: self.tables[numTables], attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: CGFloat(table.count*38))
                        self.view.addConstraint(constraintHeight)
                        
                        self.tableData.append([String]())
                        self.tableData[numTables].append(String(table[0].count))
                        for row in table{
                            for cell in row{
                                self.tableData[numTables].append(cell)
                            }
                        }
                        
                        
                        
                        numTables += 1
                    }
                }
                
            } else{
                let newLabel = UILabel()
                newLabel.text = spell.description[0].joined(separator: "\n\n")
                newLabel.font = UIFont(name: "TeXGyreBonum-Regular", size: 15)
                newLabel.numberOfLines = 0
                stackView.addArrangedSubview(newLabel)
            }
            
            nameLabel.text = spell.name
            
            
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        for table in tables{
            guard let flowLayout = table.collectionViewLayout as? UICollectionViewFlowLayout else {
                return
            }
            table.collectionViewLayout.invalidateLayout()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let index = (tables.index(of: collectionView))!
        return tableData[index].count-1
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let index = (tables.index(of: collectionView))!
        let numItems = CGFloat(Int(tableData[index][0])!)
        
        
        let paddingSpace = (sectionInsets.left) * ( numItems)
        let availableWidth = collectionView.bounds.size.width - paddingSpace
        let widthPerItem = availableWidth / numItems
        
        return CGSize(width: widthPerItem, height: 38)
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = tables.index(of: collectionView)!
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: index), for: indexPath as IndexPath) as! MyCollectionViewCell

        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.label.text = tableData[index][indexPath.item + 1]
        
        let numItems = Int(tableData[index][0])!
        
        if(indexPath.item/numItems % 2 == 1){
            cell.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        } else {
            cell.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
}

extension NSMutableAttributedString {
    @discardableResult func bold(_ text:String) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [NSFontAttributeName : UIFont(name: "TeXGyreBonum-Bold", size: 17)!]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text:String)->NSMutableAttributedString {
        let normal =  NSAttributedString(string: text)
        self.append(normal)
        return self
    }
}
