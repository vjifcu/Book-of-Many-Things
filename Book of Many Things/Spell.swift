//
//  File.swift
//  Book of Many Things
//
//  Created by Victor Jifcu on 2017-06-09.
//  Copyright © 2017 Victor Jifcu. All rights reserved.
//

import UIKit;
import SWXMLHash

class Spell{
    
    var infoFields: Dictionary<String, Any>?
    var name: String = ""
    var level: Int = 0
    var _class: [String] = [""]
    var description: [[String]] = [[""]]
    var table: [[[String]]]?
    
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
    
    init(data: XMLIndexer){
        self.name = data["name"].element!.text
        self.level = Int(data["level"].element!.text)!
        self._class.append(data["classes"].element!.text)
        self.description[0].append(data["name"].element!.text)
    }
    
}
