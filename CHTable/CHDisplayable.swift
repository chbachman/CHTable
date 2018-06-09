import UIKit

public protocol CHDisplayable: CustomStringConvertible {
    var title: String { get }
    var subtitle: String { get }
}

public extension CHDisplayable {
    var title: String {
        return String(describing: self)
    }

    var subtitle: String {
        return ""
    }
}

extension Date: CHDisplayable {
    public var title: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}

extension String: CHDisplayable {}

extension Int: CHDisplayable {}

extension Int8: CHDisplayable {}

extension Int16: CHDisplayable {}

extension Int32: CHDisplayable {}

extension Int64: CHDisplayable {}

extension Float: CHDisplayable {}

extension Double: CHDisplayable {}

extension Bool: CHDisplayable {}

extension Data: CHDisplayable {}
