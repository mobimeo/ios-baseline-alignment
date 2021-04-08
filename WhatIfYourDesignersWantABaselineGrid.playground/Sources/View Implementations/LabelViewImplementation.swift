// Copyright 2021 Mobimeo GmbH
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit

public func createLabelView() -> LabelView {
    return LabelViewImplementation()
}

private class LabelViewImplementation: UIView, LabelView {

    public var gridUnit: CGFloat = 8 {
        didSet { snapToGrid() }
    }

    public var text: String? {
        get { label.attributedText?.string }
        set { updateLabel(text: newValue) }
    }

    public var textStyle: UIFont.TextStyle = .body {
        didSet { snapToGrid() }
    }

    public var contentSizeCategory = UIApplication.shared.preferredContentSizeCategory {
        didSet { snapToGrid() }
    }

    public var extraLineSpacingInGridUnits = 0 {
        didSet { snapToGrid() }
    }

    private let label = UILabel()
    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!

    public override init(frame: CGRect) {
        super.init(frame: frame)

        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        topConstraint = label.firstBaselineAnchor.constraint(equalTo:topAnchor)
        bottomConstraint = bottomAnchor.constraint(equalTo: label.lastBaselineAnchor)
        let leadingConstraint = leadingAnchor.constraint(equalTo: label.leadingAnchor)
        let trailingConstraint = trailingAnchor.constraint(equalTo: label.trailingAnchor)
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
        NotificationCenter.default.addObserver(self, selector: #selector(contentSizeCategoryDidChange), name: UIContentSizeCategory.didChangeNotification, object: nil)
        snapToGrid()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIContentSizeCategory.didChangeNotification, object: nil)
    }

    private func updateLabel(text: String?) {
        label.attributedText = text.map {
            NSAttributedString(string: $0, attributes: [.paragraphStyle: paragraphStyle])
        }
        setNeedsLayout()
    }

    private var paragraphStyle: NSParagraphStyle {

        // A label with a single line of text will have lineHeight as height (rounded up to the next pixel).
        let lineHeight = label.font.lineHeight

        // The leading is a default line spacing (extra distance between two consecutive lines) baked into the font.
        // It can be negative, meaning consecutive lines overlap slightly.
        let leading = label.font.leading

        let defaultDistanceBetweenBaselines = lineHeight + leading

        // We want the distance of the baselines to be a multiple of the gridUnit.
        var distanceBetweenBaselines = defaultDistanceBetweenBaselines.roundedUpToNextMultiple(of: gridUnit)

        // And we need to incorporate extra line spacing.
        let extraLineSpacing = CGFloat(extraLineSpacingInGridUnits) * gridUnit
        distanceBetweenBaselines += extraLineSpacing

        // Are we done?
        var lineSpacingForParagraphStyle = distanceBetweenBaselines - defaultDistanceBetweenBaselines

        // No, positive leading acts as a minimum lineSpacing, at least for the San Francisco font family.
        // If we want our line spacing to work, we have to add the leading to it.
        let positiveLeading = leading > 0 ? leading : 0
        lineSpacingForParagraphStyle += positiveLeading

        let result = NSMutableParagraphStyle()
        result.lineSpacing = lineSpacingForParagraphStyle
        //        result.paragraphSpacing = distanceBetweenBaselines
        // We could consider to restrict the line height as well if we encounter problems with emojis etc.
        //        result.minimumLineHeight = roundedUpDistanceBetweenBaselines - lineSpacing
        //        result.maximumLineHeight = roundedUpDistanceBetweenBaselines - lineSpacing
        return result
    }

    private func snapToGrid() {
        let font = self.font()
        label.font = font
        topConstraint.constant = font.ascender.roundedUpToNextMultiple(of: gridUnit)
        bottomConstraint.constant = (-font.descender).roundedUpToNextMultiple(of: gridUnit)
        updateLabel(text: text)
    }

    private func font() -> UIFont {
        let traitCollection = UITraitCollection(preferredContentSizeCategory: contentSizeCategory)
        return UIFont.preferredFont(forTextStyle: textStyle, compatibleWith: traitCollection)
    }

    @objc private func contentSizeCategoryDidChange(_ notification: NSNotification) {
        (notification.userInfo?[UIContentSizeCategory.newValueUserInfoKey] as? UIContentSizeCategory).map {
            contentSizeCategory = $0
        }
    }
}
