import UIKit

public struct ColorScheme {
    public let color1: UIColor
    public let color2: UIColor
    public let color3: UIColor
    public let color4: UIColor
    public let color5: UIColor
    public let color6: UIColor
    
    public init(color1: UIColor, color2: UIColor, color3: UIColor, color4: UIColor, color5: UIColor, color6: UIColor) {
        self.color1 = color1
        self.color2 = color2
        self.color3 = color3
        self.color4 = color4
        self.color5 = color5
        self.color6 = color6
    }
    
    public init() {
        self.color1 = UIColor.systemGreen
        self.color2 = UIColor.systemYellow
        self.color3 = UIColor.systemBlue
        self.color4 = UIColor.systemRed
        self.color5 = UIColor.systemOrange
        self.color6 = UIColor.systemPurple
    }
    
    public subscript(index: Int) -> UIColor {
            switch index {
            case 0: return color1
            case 1: return color2
            case 2: return color3
            case 3: return color4
            case 4: return color5
            case 5: return color6
            default:
                fatalError("Index out of range. Valid indices are 0...5.")
            }
        }
}
