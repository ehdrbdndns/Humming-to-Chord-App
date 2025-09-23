enum KeyQuality {
    case major
    case minor
}

struct Key: Hashable { // changed from Equatable
    let root: PitchClass
    let quality: KeyQuality
}
