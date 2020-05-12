//
//  ChatTextViewSpec.swift
//  ChatTextView_Example
//
//  Created by abeyuya on 2020/01/11.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Mockit
import ChatTextView

class ChatTextViewSpec: QuickSpec {
    override func spec() {
        describe("input only plain text") {
            it("has only plain text") {
                let t = ChatTextView()
                t.attributedText = NSAttributedString(string: "hello")
                let result = t.getCurrentTextTypes()
                let expectResult: [TextBlock] = [TextBlock.plain("hello")]
                expect(result).to(equal(expectResult))
            }
        }

        describe("input only custom emoji") {
            it("has only custom emoji") {
                let t = ChatTextView()
                let e = TextTypeCustomEmoji(
                    displayImageUrl: URL(string: "https://emoji.slack-edge.com/T02DMDKPY/parrot/2c74b5af5aa44406.gif")!,
                    escapedString: ":hoge:"
                )

                waitUntil { done in
                    t.insert(emoji: e) {
                        let result = t.getCurrentTextTypes()
                        let expectResult: [TextBlock] = [TextBlock.customEmoji(e)]
                        expect(result).to(equal(expectResult))
                        done()
                    }
                }
            }
        }

        describe("input plain text and custom emoji") {
            it("has plain text and custom emoji") {
                let t = ChatTextView()
                t.attributedText = NSAttributedString(string: "hello")

                let e = TextTypeCustomEmoji(
                    displayImageUrl: URL(string: "https://emoji.slack-edge.com/T02DMDKPY/parrot/2c74b5af5aa44406.gif")!,
                    escapedString: ":hoge:"
                )

                waitUntil { done in
                    t.insert(emoji: e) {
                        t.insert(plain: "world")

                        let result = t.getCurrentTextTypes()
                        let expectResult: [TextBlock] = [
                            TextBlock.plain("hello"),
                            TextBlock.customEmoji(e),
                            TextBlock.plain("world")
                        ]

                        expect(result).to(equal(expectResult))
                        done()
                    }
                }
            }
        }

        describe("input only mention") {
            it("has mention") {
                let t = ChatTextView()
                let m = TextTypeMention(
                    displayString: "@channel",
                    metadata: ""
                )
                t.insert(mention: m)
                let result = t.getCurrentTextTypes()
                let expectResult: [TextBlock] = [
                    TextBlock.mention(m),
                    TextBlock.plain(" ")
                ]

                expect(result).to(equal(expectResult))
            }
        }

        describe("input many mention") {
            it("has many mention") {
                let t = ChatTextView()

                let m1 = TextTypeMention(
                    displayString: "@channel",
                    metadata: ""
                )
                t.insert(mention: m1)
 
                let m2 = TextTypeMention(
                    displayString: "@user_name",
                    metadata: ""
                )
                t.insert(mention: m2)

                let result = t.getCurrentTextTypes()
                let expectResult: [TextBlock] = [
                    TextBlock.mention(m1),
                    TextBlock.plain(" "),
                    TextBlock.mention(m2),
                    TextBlock.plain(" ")
                ]

                expect(result).to(equal(expectResult))
            }
        }

        describe("when delete mention") {
            it("remove mention") {
                let t = ChatTextView()

                let m1 = TextTypeMention(
                    displayString: "@channel",
                    metadata: ""
                )
                t.insert(mention: m1)

                let m2 = TextTypeMention(
                    displayString: "@user_name",
                    metadata: ""
                )
                t.insert(mention: m2)

                t.deleteBackward()
                t.deleteBackward()

                let result = t.getCurrentTextTypes()
                let expectResult: [TextBlock] = [
                    TextBlock.mention(m1),
                    TextBlock.plain(" "),
                ]

                expect(result).to(equal(expectResult))
            }
        }

        describe("when delete mention") {

            class DelegateStub: Stub, ChatTextViewDelegate {
                func didChange(textView: ChatTextView, contentSize: CGSize) {
                }

                func didChange(textView: ChatTextView, isFocused: Bool) {
                }

                func didChange(textView: ChatTextView, textTypes: [TextBlock]) {
                    callCount += 1
                }
            }

            it("call delegate correctly") {
                let t = ChatTextView()
                let stub = DelegateStub()

                t.setup(delegate: stub)
                expect(stub.callCount).to(equal(0))

                let m1 = TextTypeMention(
                    displayString: "@channel",
                    metadata: ""
                )
                t.insert(mention: m1)
                expect(stub.callCount).to(equal(1))

                t.deleteBackward()
                expect(stub.callCount).to(equal(2))

                t.deleteBackward()
                expect(stub.callCount).to(equal(3))
            }
        }

        describe("render textTypes") {
            it("become equal input and output") {
                let t = ChatTextView()

                let m1 = TextTypeMention(
                    displayString: "@channel",
                    metadata: ""
                )

                let e = TextTypeCustomEmoji(
                    displayImageUrl: URL(string: "https://emoji.slack-edge.com/T02DMDKPY/parrot/2c74b5af5aa44406.gif")!,
                    escapedString: ":hoge:"
                )

                let textTypes: [TextBlock] = [
                    TextBlock.mention(m1),
                    TextBlock.customEmoji(e),
                    TextBlock.plain("hello")
                ]

                waitUntil { done in
                    t.render(textTypes: textTypes) {
                        let result = t.getCurrentTextTypes()
                        expect(result).to(equal(textTypes))
                        done()
                    }
                }
            }
        }
    }
}
