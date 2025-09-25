protocol NoteAggregatorServiceProtocol {
    func add(pitch: Float, amplitude: Float)
    
    func finalize() -> [Note]
}
