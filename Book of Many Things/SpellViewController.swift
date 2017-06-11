//
//  SpellViewController.swift
//  Book of Many Things
//
//  Created by Victor Jifcu on 2017-06-08.
//  Copyright © 2017 Victor Jifcu. All rights reserved.
//

import UIKit

class SpellViewController: UIViewController {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var areaOfEffectLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var castingTimeLabel: UILabel!
    @IBOutlet weak var savingThrowLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var componentsLabel: UILabel!
    
    var spell: Spell?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let spell = spell{
            descriptionLabel.text = spell.description.joined(separator: "\n\n")
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
