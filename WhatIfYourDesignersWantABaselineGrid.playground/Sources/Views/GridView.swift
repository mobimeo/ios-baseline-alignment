import UIKit

public protocol GridView: UIView {
    var lineWidth: CGFloat { get }
    var gridUnit: CGFloat { get set }
}
