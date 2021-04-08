import UIKit

public func createGridView() -> GridView {
    return GridViewImplementation()
}

private class GridViewImplementation: UIView, GridView {

    let lineWidth: CGFloat = 0.5
    var gridUnit: CGFloat = 8 {
        didSet {
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }

    fileprivate func gridPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.lineWidth = lineWidth

        let bounds = self.bounds
        var y: CGFloat = gridUnit - lineWidth / 2

        while y < bounds.height {
            let start = CGPoint(x: 0, y: y)
            let end = CGPoint(x: bounds.width, y: y)
            path.move(to: start)
            path.addLine(to: end)
            y += gridUnit
        }
        path.close()
        return path
    }

    override func draw(_ rect: CGRect) {
        UIColor.systemRed.setStroke()
        gridPath().stroke()
    }
}
