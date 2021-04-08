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
import PlaygroundSupport

// First a bit of setup.

// dynamicTypeFonts is an array of all dynamic type fonts.
let dynamicTypeFonts = UIContentSizeCategory.specifiedContentSizeCategories.flatMap { (contentSizeCategory) -> [UIFont] in
    let traitCollection = UITraitCollection(preferredContentSizeCategory: contentSizeCategory)
    return UIFont.TextStyle.textStyles.map {
        UIFont.preferredFont(forTextStyle: $0, compatibleWith: traitCollection)
    }
}

// labelHeight(for:numberOfLines:lineSpacing:) is a method that returns the height
// for a given font, number of lines, and an optional line spacing.
let label = UILabel()
func labelHeight(for font: UIFont, numberOfLines: Int, lineSpacing: CGFloat? = nil) -> CGFloat {
    let text = Array(repeating: "Some text", count: numberOfLines).joined(separator: "\n")
    label.numberOfLines = 0
    var attributes: [NSAttributedString.Key: Any] = [.font: font]
    if let lineSpacing = lineSpacing {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        attributes[.paragraphStyle] = paragraphStyle
    }
    label.attributedText = NSMutableAttributedString(string: text, attributes: attributes)
    return label.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
}

// The ascender is always a positive value.
assert(dynamicTypeFonts.allSatisfy { $0.ascender > 0 })

// The descender is always a negative value.
assert(dynamicTypeFonts.allSatisfy { $0.descender < 0 })

// The line height is always the sum of the ascender and the negated descender.
assert(
    dynamicTypeFonts.allSatisfy {
        $0.lineHeight == $0.ascender - $0.descender
    }
)

// Contrary to what we may expect at first, the height of a label of a single line
// of text is **not** the lineheight of the font.
assert(
    dynamicTypeFonts.contains {
        labelHeight(for: $0, numberOfLines: 1) != $0.lineHeight
    }
)

// We have to round up the line height to the next pixel to get the height of the label:
assert(
    dynamicTypeFonts.allSatisfy {
        let labelLineHeight = labelHeight(for: $0, numberOfLines: 1)
        let calculatedLineHeight = $0.lineHeight.roundedUpToNextMultiple(of: 1.0 / UIScreen.main.scale)
        return labelLineHeight == calculatedLineHeight
    }
)

// If we have two layout anchors `topAnchor` and `bottomAnchor,
// then for one line labels, we can reach a baseline adjustment by
//
// - rounding up ascender and descender to a multiple of the grid size
// - anchor the firstBaselineAnchor to the

//topConstraint = label.firstBaselineAnchor.constraint(equalTo: topAnchor)
//topConstraint.constant = font.ascender.roundedUpToNextMultiple(of: gridUnit)
//bottomConstraint = bottomAnchor.constraint(equalTo: label.lastBaselineAnchor)
//bottomConstraint.constant = (-font.descender).roundedUpToNextMultiple(of: gridUnit)

// For multi-line labels, the height is not simply the multiple of the line height:
let numberOfLines = 10
assert(
    dynamicTypeFonts.contains {
        let labelLineHeight = labelHeight(for: $0, numberOfLines: numberOfLines)
        let calculatedLineHeight = ($0.lineHeight * CGFloat(numberOfLines) ).roundedUpToNextMultiple(of: 1.0 / UIScreen.main.scale)
        return labelLineHeight != calculatedLineHeight
    }
)

// we have to take the leading into account:
assert(
    dynamicTypeFonts.allSatisfy {
        let labelLineHeight = labelHeight(for: $0, numberOfLines: numberOfLines)
        let calculatedLineHeight = (
            $0.lineHeight * CGFloat(numberOfLines) + $0.leading * CGFloat(numberOfLines - 1)
        ).roundedUpToNextMultiple(of: 1.0 / UIScreen.main.scale)
        return labelLineHeight == calculatedLineHeight
    }
)

// So the distance between two baselines is font.lineHeight + font.leading.

// To get a grid alignment, we need to round it up to a multiple of the grid.
// How can we add to the distance between two lines?
// lineSpacing in the attributedText's paragraph style sounds right.

// Adding 1.5 to the lineSpacing does not always lead to the desired effect:
assert(
    dynamicTypeFonts.contains { font in
        let lineSpacing: CGFloat = 1.5
        let labelLineHeight = labelHeight(for: font, numberOfLines: 2, lineSpacing: lineSpacing)
        var calculatedLineHeight =
            font.lineHeight
            + font.leading
            + lineSpacing
            + font.lineHeight
        calculatedLineHeight = calculatedLineHeight.roundedUpToNextMultiple(of: 1.0 / UIScreen.main.scale)
        return labelLineHeight != calculatedLineHeight
    }
)

// Turns out it only works if the leading is <= 0:
assert(
    dynamicTypeFonts.filter { $0.leading <= 0 } .allSatisfy { font in
        let lineSpacing: CGFloat = 1.5
        let labelLineHeight = labelHeight(for: font, numberOfLines: 2, lineSpacing: lineSpacing)
        var calculatedLineHeight =
            font.lineHeight
            + font.leading
            + lineSpacing
            + font.lineHeight
        calculatedLineHeight = calculatedLineHeight.roundedUpToNextMultiple(of: 1.0 / UIScreen.main.scale)
        return labelLineHeight == calculatedLineHeight
    }
)

// If the leading is > 0, the leading acts as a minimum line spacing for dynamic type fonts!
// To increase the line spacing, we have to add the leading to our line spacing if it is positive:
assert(
    dynamicTypeFonts.allSatisfy { font in
        let lineSpacing: CGFloat = 1.5
        let adjustedLineSpacing = lineSpacing + (font.leading > 0 ? font.leading : 0)
        let labelLineHeight = labelHeight(for: font, numberOfLines: 2, lineSpacing: adjustedLineSpacing)
        var calculatedLineHeight = font.lineHeight + font.leading + lineSpacing + font.lineHeight
        calculatedLineHeight = calculatedLineHeight.roundedUpToNextMultiple(of: 1.0 / UIScreen.main.scale)
        return labelLineHeight == calculatedLineHeight
    }
)

// We can now use the line spacing to round up the distance between baselines to the grid unit.

let gridUnit: CGFloat = 4

let lineHeight = label.font.lineHeight
let leading = label.font.leading

// The distance between two baselines is the line height plus the leading.
let defaultDistanceBetweenBaselines = lineHeight + leading

// The target is to round up to the next multiple of the grid unit.
let targetDistanceBetweenBaselines = defaultDistanceBetweenBaselines.roundedUpToNextMultiple(of: gridUnit)

// The line spacing we need to set is the difference.
var lineSpacingForParagraphStyle = targetDistanceBetweenBaselines - defaultDistanceBetweenBaselines

// As positive leadings act as a minimum line spacing, we have to add
// those to the line spacing we use.
if leading > 0 {
    lineSpacingForParagraphStyle += leading
}

// For a given text ...
let text = "Hello"

// ... we can set the paragraph style to make the distance between the
// baselines a multiple of the grid unit.
let paragraphStyle = NSMutableParagraphStyle()
paragraphStyle.lineSpacing = lineSpacingForParagraphStyle
label.attributedText = NSAttributedString(string: text, attributes: [.paragraphStyle: paragraphStyle])

// If we combine this with the constraints for the single line label,
// all baselines will end up on the grid. Note we need to update the
// line spacing whenever the content size category changes.

// Here is an example in action:
let viewController = ViewController()
viewController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 568)
PlaygroundPage.current.liveView = viewController
