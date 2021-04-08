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
