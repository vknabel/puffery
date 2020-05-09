import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(APIDefinitionTests.allTests),
        ]
    }
#endif
