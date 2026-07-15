import UIKit
import Components
import OOGFontKit

final class GeneralLinkTextView: UITextView, UITextViewDelegate {

    private func setCommonAttribute(_ contentText: String, commonAttributes: [NSAttributedString.Key: Any]
    ) {
        let attributes = commonAttributes
        let attributesString = NSMutableAttributedString(string: contentText, attributes: attributes)
        attributedText = attributesString
    }

    @discardableResult
    func setlinkAttribute(_ linkText: String,
                          _ linkURLText: String,
                          _ attributes: [NSAttributedString.Key: Any]? = nil) -> LinkTextView {
        let contentText = self.attributedText.string

        let attributesString = NSMutableAttributedString(attributedString: self.attributedText)
        if let range = contentText.range(of: linkText) {
            let nsRange = NSRange(range, in: contentText)
            attributesString.addAttributes(linkAttribute(linkURLText, attributes), range: nsRange)
        }

        self.attributedText = attributesString
        self.textAlignment = .center

        return self
    }


    func linkAttribute(_ linkURLText: String, _ attributes: [NSAttributedString.Key: Any]? = nil) -> [NSAttributedString.Key: Any] {

        var underlineStyle = NSNumber(value: NSUnderlineStyle.single.rawValue)
        var underlineColor = UIColor.white.withAlphaComponent(0.8)
        var font = UIFont.systemFont(ofSize: 13)

        if let underline = attributes?[.underlineStyle] as? NSNumber {
            underlineStyle = underline
        }

        if let lineColor = attributes?[.underlineColor] as? UIColor  {
            underlineColor = lineColor
        }

        if let customFont = attributes?[.font] as? UIFont {
            font = customFont
        }

        return [
            .link: linkURLText,
            .underlineStyle: underlineStyle,
            .underlineColor: underlineColor,
            .font: font
        ]
    }

    static func createLinkView(
        with text: String,
        attributes: [NSAttributedString.Key: Any],
        delegate: UITextViewDelegate? = nil
    ) -> LinkTextView {
        let textView = LinkTextView()
        textView.delegate = (delegate != nil) ? delegate : textView
        textView.contentInset = UIEdgeInsets.zero
        textView.textContainerInset = .zero
        textView.isEditable = false
        //textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = true
        textView.textAlignment = .center
        textView.backgroundColor = .clear
        textView.textContainer.lineBreakMode = .byWordWrapping
        
        textView.setCommonAttribute(
            text,
            commonAttributes: attributes
        )
        
        return textView
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if UIApplication.shared.canOpenURL(URL) {
            UIApplication.shared.open(URL)
        }
        return false
    }
}

