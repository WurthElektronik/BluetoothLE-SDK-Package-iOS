import XCTest
@testable import BluetoothSDK_iOS

final class BluetoothSDK_iOSTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(BluetoothSDK_iOS().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
