import UIKit;

class Spellbook: NSObject, NSCoding {
    
    //MARK: Properties
    struct PropertyKey{
        static let name = "name"
        static let spells = "spells"
    }
    
    var name: String
    var spells: [Spell]
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("spellbooks")
    
    init(name: String, spells: [Spell]){
        self.name = name
        self.spells = spells
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder){
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(spells, forKey: PropertyKey.spells)
    }
    
    required convenience init?(coder aDecoder: NSCoder){
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else{
            return nil
        }
        guard let spells = aDecoder.decodeObject(forKey: PropertyKey.spells) as? [Spell] else{
            return nil
        }

        // Must call designated initializer
        self.init(name: name, spells: spells)
    }
    
}
