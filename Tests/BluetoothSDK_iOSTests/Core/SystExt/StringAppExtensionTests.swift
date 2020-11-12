// __          ________        _  _____
// \ \        / /  ____|      (_)/ ____|
//  \ \  /\  / /| |__      ___ _| (___   ___  ___
//   \ \/  \/ / |  __|    / _ \ |\___ \ / _ \/ __|
//    \  /\  /  | |____  |  __/ |____) | (_) \__ \
//     \/  \/   |______|  \___|_|_____/ \___/|___/
//
// Copyright © 2020 Würth Elektronik GmbH & Co. KG.

import Foundation
import XCTest
@testable import BluetoothSDK_iOS

class StringAppExtensionTests: XCTestCase {

    // MARK: isValidHex

    func test_isValidHex_StringIsEmpty_ResultIsFalse() {
        let value = ""

        let result = value.isValidHex()

        XCTAssertFalse(result)
    }

    func test_isValidHex_StringContainsOnlyWhitespaces_ResultIsFalse() {
        let value = "    "

        let result = value.isValidHex()

        XCTAssertFalse(result)
    }

    func test_isValidHex_StringContainsOnlyInvalidCharacters_ResultIsFalse() {
        let value = "LS//TB"

        let result = value.isValidHex()

        XCTAssertFalse(result)
    }

    func test_isValidHex_StringContainsValidAndInvalidCharacters_ResultIsFalse() {
        let value = "EAF3GH"

        let result = value.isValidHex()

        XCTAssertFalse(result)
    }

    func test_isValidHex_StringContainsOnlyValidCharactersAndIsUneven_ResultIsFalse() {
        let value = "00EAF"

        let result = value.isValidHex()

        XCTAssertFalse(result)
    }

    func test_isValidHex_StringContainsAllValidCharacters_ResultIsTrue() {
        let value = "00112233445566778899aaAAbbBBccCCddDDeeEEffFF"

        let result = value.isValidHex()

        XCTAssertTrue(result)
    }

    func test_isValidHex_StringContainsWhitespacesAndValidCharactersAndIsEven_ResultIsTrue() {
        let value = "fe aa bc 09"

        let result = value.isValidHex()

        XCTAssertTrue(result)
    }

    func test_isValidHex_StringContainsOnlyValidHexaDecimalCharactersAndIsEven_ResultIsTrue() {
        let value = "00EAF3"

        let result = value.isValidHex()

        XCTAssertTrue(result)
    }

    // MARK: hexadecimal

    func test_hexadecimal_InvalidHex_ResultIsNil() {
        let value = "bg tsd"

        let result = value.hexadecimal()

        XCTAssertNil(result)
    }

    func test_hexadecimal_ValidHexContainingTwoChars_ResultIsValidData() {
        let value = "FF"

        let result = [UInt8](value.hexadecimal()!)
        let expectedResult: [UInt8] = [255]

        XCTAssertEqual(result, expectedResult)
    }

    func test_hexadecimal_ValidHexContainingSixCharsAndSplitByWhitespaces_ResultIsValidData() {
        let value = "FF AE 01"

        let result = [UInt8](value.hexadecimal()!)
        let expectedResult: [UInt8] = [255, 174, 1]

        XCTAssertEqual(result, expectedResult)
    }

    func test_hexadecimal_ValidHexContainingSixChars_ResultIsValidData() {
        let value = "FFAE01"

        let result = [UInt8](value.hexadecimal()!)
        let expectedResult: [UInt8] = [255, 174, 1]

        XCTAssertEqual(result, expectedResult)
    }

}
