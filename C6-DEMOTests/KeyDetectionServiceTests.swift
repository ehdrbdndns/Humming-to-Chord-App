import XCTest
@testable import C6_DEMO

final class KeyDetectionServiceTests: XCTestCase {
    // 각 테스트 케이스가 실행되기 전에 호출
    override func setUp() {
        super.setUp()
    }
    
    // 각 테스트 케이스가 끝난 후에 호출
    override func tearDown() {
        super.tearDown()
    }
    
    func test_calculatePCP_withSimpleNotes_returnsCorrectProfile() {
        let sampleNotes: [Note] = [Note(pitchClass: .C, duration: 1.5), Note(pitchClass: .G, duration: 0.5)]
        
        let expectation = XCTestExpectation(description: "입력된 Note에 따라 PCP 값이 생성됩니다.")
        
        let keyDetectionService = KeyDetectionService()
        let pcp = keyDetectionService.calculatePCP(notes: sampleNotes)
        
        expectation.fulfill()
        
        XCTAssertEqual(pcp, [1.5, 0, 0, 0, 0, 0, 0, 0.5, 0, 0, 0, 0])
    }
    
    func test_pearsonCorrelation_withKnownVectors_returnsCorrectCoefficient() {
        let vectorA: [Float] = [1, 2, 3]
        let vectorB: [Float] = [1, 2, 3]
        let vectorC: [Float] = [3, 2, 1]
        let vectorD: [Float] = [100, 73, 21]
        
        let expectation = XCTestExpectation(description: "두 벡터 간의 피어슨 상관계수가 계산됩니다.")
        
        let keyDetectionService = KeyDetectionService()
        let coefficient1 = keyDetectionService.pearsonCorrelation(vectorA: vectorA, vectorB: vectorB)
        let coefficient2 = keyDetectionService.pearsonCorrelation(vectorA: vectorA, vectorB: vectorC)
        let coefficient3 = keyDetectionService.pearsonCorrelation(vectorA: vectorA, vectorB: vectorD)
        
        expectation.fulfill()
        
        XCTAssertEqual(coefficient1, 1, accuracy: 0.00001)
        XCTAssertEqual(coefficient2, -1, accuracy: 0.00001)
    }
    
    func test_findKey_forVariousScales_returnsCorrectKey() {
        // Given
        let service = KeyDetectionService()

        // 1. 여러 테스트 케이스 데이터를 정의합니다.
        let testCases: [(notes: [Note], expectedKey: Key, description: String)] = [
            (
                notes: [.C, .D, .E, .F, .G, .A, .B].map { Note(pitchClass: $0, duration: 1.0) },
                expectedKey: Key(root: .C, quality: .major),
                description: "C Major scale should be detected as C Major"
            ),
            (
                notes: [.A, .B, .C, .D, .E, .F, .GSharp].map { Note(pitchClass: $0, duration: 1.0) },
                expectedKey: Key(root: .A, quality: .minor),
                description: "A natural minor scale should be detected as A Minor"
            ),
            (
                notes: [.G, .A, .B, .C, .D, .E, .FSharp].map { Note(pitchClass: $0, duration: 1.0) },
                expectedKey: Key(root: .G, quality: .major),
                description: "G Major scale should be detected as G Major"
            )
        ]

        // 2. 모든 테스트 케이스를 순회하며 검증합니다.
        for testCase in testCases {
            // When
            let resultKey = service.findKey(for: testCase.notes)
            
            // Then
            XCTAssertEqual(resultKey, testCase.expectedKey, testCase.description)
        }
    }}
