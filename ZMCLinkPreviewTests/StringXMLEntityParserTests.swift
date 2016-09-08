//
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import XCTest
@testable import ZMCLinkPreview

class StringXMLEntityParserTests: XCTestCase {
    
    func testThatItIgnoresEmptyString() {
        // given 
        let string = ""
        // when & then
        XCTAssertEqual(string, string.resolvedXMLEntityReferences())
    }
    
    func testThatItIgnoresStringWithoutEntities() {
        // given
        let string = "WebKit crashes on background thread"
        // when & then
        XCTAssertEqual(string, string.resolvedXMLEntityReferences())
    }
    
    func testThatItIgnoresStringWithOneAmp() {
        // given
        let string = "NSAttributedString crashes on background thread & no one tells that it uses WebKit"
        // when & then
        XCTAssertEqual(string, string.resolvedXMLEntityReferences())
    }
    
    func testThatItIgnoresStringWithSeveralAmps() {
        // given
        let string = "if webKit && thread.current().isBackground() then fatalError()"
        // when & then
        XCTAssertEqual(string, string.resolvedXMLEntityReferences())
    }
    
    func testThatItIgnoresStringWithEmoji() {
        // given
        let string = "WebKit crashes on background thread 😱"
        // when & then
        XCTAssertEqual(string, string.resolvedXMLEntityReferences())
    }
    
    func testThatItIgnoresStringWithRTL() {
        // given
        let string = "تحطم بكت على موضوع الخلفية"
        // when & then
        XCTAssertEqual(string, string.resolvedXMLEntityReferences())
    }
    
    func testThatItIgnoresStringWithChineese() {
        // given
        let string = "在后台线程WebKit的崩溃"
        // when & then
        XCTAssertEqual(string, string.resolvedXMLEntityReferences())
    }
    
    func testThatItReplacesAmp() {
        // given
        let string = "&amp;"
        // when & then
        XCTAssertEqual("&", string.resolvedXMLEntityReferences())
    }
    
    func testThatItReplacesSeveralAmps() {
        // given
        let string = "if webKit &amp;&amp; thread.current().isBackground() then fatalError()"
        // when & then
        XCTAssertEqual("if webKit && thread.current().isBackground() then fatalError()", string.resolvedXMLEntityReferences())
    }
    
    func testThatItReplacesQuot() {
        // given
        let string = "I said: &quot;WebKit crashes on background thread&quot;"
        // when & then
        XCTAssertEqual("I said: \"WebKit crashes on background thread\"", string.resolvedXMLEntityReferences())
    }
    
    func testThatItReplacesSpecialCharacters() {
        // given
        let string = "Checkout: 0,00 &#8364;"
        // when & then
        XCTAssertEqual("Checkout: 0,00 €", string.resolvedXMLEntityReferences())
    }
    
    func testThatItReplacesSeveralSpecialCharacters() {
        // given
        let string = "Restaurant is &#8364;&#8364;&#8364;"
        // when & then
        XCTAssertEqual("Restaurant is €€€", string.resolvedXMLEntityReferences())
    }
    
}
