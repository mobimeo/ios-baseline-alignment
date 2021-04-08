import UIKit

public protocol LabelView: UIView {
    var textStyle: UIFont.TextStyle { get set }
    var text: String? { get set }
    var gridUnit: CGFloat { get set }
    var extraLineSpacingInGridUnits: Int { get set }
    var contentSizeCategory: UIContentSizeCategory { get set }
}
