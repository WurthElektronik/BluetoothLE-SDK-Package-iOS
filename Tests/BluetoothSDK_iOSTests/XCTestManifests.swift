import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BluetoothSDK_iOSTests.allTests),
    ]
}
#endif
