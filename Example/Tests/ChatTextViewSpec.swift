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
import ChatTextView

class ChatTextViewSpec: QuickSpec {
    override func spec() {
        describe("input only plain text") {
            it("has only plain text") {
                let t = ChatTextView()
                t.attributedText = NSAttributedString(string: "hello")
                let result = t.getCurrentTextTypes()
                let expectResult: [TextType] = [TextType.plain("hello")]
                expect(result).to(equal(expectResult))
            }
        }

        describe("input only custom emoji") {
            it("has only custom emoji") {
                let t = ChatTextView()
                let e = TextTypeCustomEmoji(
                    displayImageUrl: URL(string: "https://emoji.slack-edge.com/T02DMDKPY/parrot/2c74b5af5aa44406.gif")!,
                    escapedString: ":hoge:",
                    size: CGSize(width: 14, height: 14)
                )

                waitUntil { done in
                    t.insert(emoji: e) {
                        let result = t.getCurrentTextTypes()
                        let expectResult: [TextType] = [TextType.customEmoji(e)]
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
                    escapedString: ":hoge:",
                    size: CGSize(width: 14, height: 14)
                )

                waitUntil { done in
                    t.insert(emoji: e) {
                        t.insert(plain: "world")

                        let result = t.getCurrentTextTypes()
                        let expectResult: [TextType] = [
                            TextType.plain("hello"),
                            TextType.customEmoji(e),
                            TextType.plain("world")
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
                    displayString: "@here",
                    hiddenString: "<mention: here>"
                )
                t.insert(mention: m)
                let result = t.getCurrentTextTypes()
                let expectResult: [TextType] = [
                    TextType.mention(m),
                    TextType.plain(" ")
                ]

                expect(result).to(equal(expectResult))
            }
        }

        describe("input many mention") {
            it("has many mention") {
                let t = ChatTextView()

                let m1 = TextTypeMention(
                    displayString: "@here",
                    hiddenString: "<mention: here>"
                )
                t.insert(mention: m1)

                let m2 = TextTypeMention(
                    displayString: "@user_name",
                    hiddenString: "<mention: user_id>"
                )
                t.insert(mention: m2)

                let result = t.getCurrentTextTypes()
                let expectResult: [TextType] = [
                    TextType.mention(m1),
                    TextType.plain(" "),
                    TextType.mention(m2),
                    TextType.plain(" ")
                ]

                expect(result).to(equal(expectResult))
            }
        }

        describe("when delete mention") {
            it("remove mention") {
                let t = ChatTextView()

                let m1 = TextTypeMention(
                    displayString: "@here",
                    hiddenString: "<mention: here>"
                )
                t.insert(mention: m1)

                let m2 = TextTypeMention(
                    displayString: "@user_name",
                    hiddenString: "<mention: user_id>"
                )
                t.insert(mention: m2)

                t.deleteBackward()
                t.deleteBackward()

                let result = t.getCurrentTextTypes()
                let expectResult: [TextType] = [
                    TextType.mention(m1),
                    TextType.plain(" "),
                ]

                expect(result).to(equal(expectResult))
            }
        }
    }
}
