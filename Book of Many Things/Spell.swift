//
//  File.swift
//  Book of Many Things
//
//  Created by Victor Jifcu on 2017-06-09.
//  Copyright © 2017 Victor Jifcu. All rights reserved.
//

import UIKit;

class Spell{
    
    let infoFields: Dictionary<String, Any>?
    let name: String
    let level: Int
    let _class: [String]
    let description: [[String]]
    let table: [[[String]]]?
    
    init(dictionary: [String: Any]){
        var dict = dictionary
        self.name = dict["name"] as! String
        dict.removeValue(forKey: "name")
        self.level = dict["level"] as! Int
        dict.removeValue(forKey: "level")
        self._class = dict["class"] as! [String]
        dict.removeValue(forKey: "class")
        self.description = dict["desc"] as! [[String]]
        dict.removeValue(forKey: "desc")
        self.table = dict["table"] as? [[[String]]]
        dict.removeValue(forKey: "table")
        
        infoFields = dict
    }
}
