import UIKit

public extension FloatingPoint {
    func roundedUpToNextMultiple(of unit: Self) -> Self {
        (self / unit).rounded(.up) * unit
    }
}
