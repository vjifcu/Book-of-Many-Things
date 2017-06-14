//
//  File.swift
//  Book of Many Things
//
//  Created by Victor Jifcu on 2017-06-09.
//  Copyright © 2017 Victor Jifcu. All rights reserved.
//

import UIKit;

class Spell{
    
    let name: String
    let level: Int
    let _class: [String]
    let description: [[String]]
    let duration: String
    let casting_time: String
    let range: String
    let components: String
    let area_of_effect: String
    let saving_throw: String
    let table: [[[String]]]?
    
    init(dictionary: [String: Any]){
        self.name = dictionary["name"] as! String
        self.level = dictionary["level"] as! Int
        self._class = dictionary["class"] as! [String]
        self.description = dictionary["desc"] as! [[String]]
        self.duration = dictionary["duration"] as! String
        self.casting_time = dictionary["casting_time"] as! String
        self.range = dictionary["range"] as! String
        self.components = dictionary["components"] as! String
        self.area_of_effect = dictionary["area_of_effect"] as! String
        self.saving_throw = dictionary["saving_throw"] as! String
        self.table = dictionary["table"] as? [[[String]]]
    }
}
