import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(PufferyKitTests.allTests),
        ]
    }
#endif
