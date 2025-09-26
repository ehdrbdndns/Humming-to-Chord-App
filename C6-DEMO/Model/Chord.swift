enum ChordQuality {
    case major
    case minor
    case diminished
}

struct Chord: Equatable, Hashable {
    let root: PitchClass
    let quality: ChordQuality
    
    var constituentNotes: [PitchClass] {
        let rootValue = self.root.rawValue
        var third: Int
        var fifth: Int
        
        switch self.quality {
        case .major:
            third = (rootValue + 4) % 12 // 장3도 (4 반음 위)
            fifth = (rootValue + 7) % 12 // 완전5도 (7 반음 위)
        case .minor:
            third = (rootValue + 3) % 12 // 단3도 (3 반음 위)
            fifth = (rootValue + 7) % 12 // 완전5도 (7 반음 위)
        case .diminished:
            third = (rootValue + 3) % 12 // 단3도 (3 반음 위)
            fifth = (rootValue + 6) % 12 // 감5도 (6 반음 위)
        }
        
        return [self.root, PitchClass(rawValue: third)!, PitchClass(rawValue: fifth)!]
    }
}
