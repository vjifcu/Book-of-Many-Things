//
//  SpellViewController.swift
//  Book of Many Things
//
//  Created by Victor Jifcu on 2017-06-08.
//  Copyright © 2017 Victor Jifcu. All rights reserved.
//

import UIKit

class SpellViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var areaOfEffectLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var castingTimeLabel: UILabel!
    @IBOutlet weak var savingThrowLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var componentsLabel: UILabel!
    @IBOutlet weak var descriptionEndLabel: UILabel!

    @IBOutlet weak var stackView: UIStackView!
    
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 20, bottom: 10.0, right: 20)
    let reuseIdentifier = "cell"
    var items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]

    var spell: Spell?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        if let spell = spell{
            
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
                    let newLabel = UILabel()
                    if let desc = items as? [String]{
                        let newLabel = UILabel()
                        newLabel.text = desc.joined(separator: "\n\n")
                        newLabel.font = UIFont(name: "TeXGyreBonum-Regular", size: 15)
                        newLabel.numberOfLines = 0
                        stackView.addArrangedSubview(newLabel)
                    } else if let table = items as? [[String]]{
                        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: UICollectionViewFlowLayout())
                        collectionView.dataSource = self
                        collectionView.delegate = self
                        collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
                        collectionView.backgroundColor = UIColor.white
                        stackView.addArrangedSubview(collectionView)
                        let constraint = NSLayoutConstraint(item: collectionView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
                        self.view.addConstraint(constraint)
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
            
            var formattedString = NSMutableAttributedString()
            
            formattedString.bold("Range: ").normal(spell.range)
            rangeLabel.attributedText = formattedString
            formattedString = NSMutableAttributedString()
            
            formattedString.bold("Duration: ").normal(spell.duration)
            durationLabel.attributedText = formattedString
            formattedString = NSMutableAttributedString()
            
            formattedString.bold("Area of Effect: ").normal(spell.area_of_effect)
            areaOfEffectLabel.attributedText = formattedString
            formattedString = NSMutableAttributedString()
            
            formattedString.bold("Casting Time: ").normal(spell.casting_time)
            castingTimeLabel.attributedText = formattedString
            formattedString = NSMutableAttributedString()
            
            formattedString.bold("Saving Throw: ").normal(spell.saving_throw)
            savingThrowLabel.attributedText = formattedString
            formattedString = NSMutableAttributedString()
            
            formattedString.bold("Components: ").normal(spell.components)
            componentsLabel.attributedText = formattedString
            
            
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (3 + 1)
        let availableWidth = stackView.frame.width - paddingSpace
        let widthPerItem = availableWidth / 3
        
        return CGSize(width: widthPerItem, height: widthPerItem/2)
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MyCollectionViewCell

        if let cellLabel = cell.myLabel{
            cellLabel.text = self.items[indexPath.item]
            cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
            
            return cell
        }
        let newLabel = UILabel()
        cell.myLabel = newLabel
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.myLabel.text = self.items[indexPath.item]
        cell.myLabel.textColor = UIColor.black
        cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
        
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
