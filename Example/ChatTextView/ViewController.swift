//
//  ViewController.swift
//  ChatTextView
//
//  Created by abeyuya on 12/27/2019.
//  Copyright (c) 2019 abeyuya. All rights reserved.
//

import UIKit
import UnderKeyboard
import ChatTextView

class ViewController: UIViewController {

    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatTextView: ChatTextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton! {
        didSet {
            sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
        }
    }
    @IBOutlet weak var emojiButton: UIButton! {
        didSet {
            emojiButton.addTarget(self, action: #selector(didTapEmojiButton), for: .touchUpInside)
        }
    }
    @IBOutlet weak var mensionButton: UIButton! {
        didSet {
            mensionButton.addTarget(self, action: #selector(didTapMensionButton), for: .touchUpInside)
        }
    }

    private let underKeyboardLayoutConstraint = UnderKeyboardLayoutConstraint()
    private var sendTextTypes: [[TextType]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        underKeyboardLayoutConstraint.setup(bottomLayoutConstraint, view: view)

        chatTextView.setup(delegate: self)
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc
    func didTapSendButton() {
        let textTypes = chatTextView.getCurrentTextTypes()
        sendTextTypes.append(textTypes)
        tableView.reloadData()

        chatTextView.clear()
        chatTextView.resignFirstResponder()
    }

    @objc
    func didTapEmojiButton() {
        let vc = UIAlertController(title: "", message: "emoji", preferredStyle: .actionSheet)

        let parrot = UIAlertAction(title: "parrot (gif)", style: .default) { _ in
            let url = "https://emoji.slack-edge.com/T02DMDKPY/parrot/2c74b5af5aa44406.gif"
            let image = UIImage.gifImageWithURL(url)
            let emoji = TextTypeCustomEmoji(
                displayImage: image,
                escapedString: ":parrot:",
                size: .init(width: 14, height: 14)
            )
            self.chatTextView.insert(emoji: emoji)
        }

        let octcat = UIAlertAction(title: "octcat (png)", style: .default) { _ in
            let url = URL(string: "https://emoji.slack-edge.com/T02DMDKPY/octocat/627964d7c9.png")!
            let data = try? Data(contentsOf: url)
            let image = data == nil ? nil : UIImage(data: data!)
            let emoji = TextTypeCustomEmoji(
                displayImage: image,
                escapedString: ":octcat:",
                size: .init(width: 14, height: 14)
            )
            self.chatTextView.insert(emoji: emoji)
        }

        let cancel = UIAlertAction(title: "cancel", style: .cancel) { _ in }

        vc.addAction(parrot)
        vc.addAction(octcat)
        vc.addAction(cancel)
        present(vc, animated: true)
    }

    @objc
    func didTapMensionButton() {

    }
}

extension ViewController: UITableViewDelegate {}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sendTextTypes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let textTypes = sendTextTypes[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }

        guard let label = cell.viewWithTag(10) as? UILabel else {
            return UITableViewCell()
        }

        label.attributedText = toAttributedString(textTypes: textTypes)
        return cell
    }

    func toAttributedString(textTypes: [TextType]) -> NSAttributedString {
        let result = NSMutableAttributedString()

        for t in textTypes {
            switch t {
            case .plain(let string):
                result.append(NSAttributedString(string: string))
            case .customEmoji(let value):
                let attarchment = NSTextAttachment()
                attarchment.image = value.displayImage
                attarchment.bounds = .init(origin: .zero, size: .init(width: 17, height: 17))
                let attr = NSAttributedString(attachment: attarchment)
                result.append(attr)
            }
        }

        return result
    }
}

extension ViewController: ChatTextViewDelegate {
    func didChange(textTypes: [TextType]) {
        print(textTypes)
    }
}
