import UIKit

public final class PieChartView: UIView {
    
    public var entities: [Entity] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var colors: ColorScheme
    
    public init(frame: CGRect, colors: ColorScheme = ColorScheme()) {
        self.colors = colors
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        self.colors = ColorScheme()
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    public override func draw(_ rect: CGRect) {
        guard !entities.isEmpty else { return }

        let total = entities.map(\.value).reduce(0, +)
        guard total > 0 else { return }

        let topEntities = Array(entities.sorted { $0.value > $1.value }.prefix(5))
        let remaining = entities.dropFirst(5)
        let remainingValue = remaining.map(\.value).reduce(0, +)
        
        var displayItems = topEntities
        if remainingValue > 0 {
            displayItems.append(Entity(value: remainingValue, label: "Остальные"))
        }

        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        let outerRadius = min(bounds.width, bounds.height) * 0.45
        let innerRadius = outerRadius * 0.7
        var startAngle: CGFloat = -.pi / 2
        
        for (index, entity) in displayItems.enumerated() {
            let percentage = CGFloat((entity.value / total as NSDecimalNumber).doubleValue)
            let endAngle = startAngle + percentage * 2 * .pi
            
            let path = UIBezierPath()
            path.addArc(withCenter: centerPoint, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.addArc(withCenter: centerPoint, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: false)
            path.close()

            let segmentLayer = CAShapeLayer()
            segmentLayer.path = path.cgPath
            segmentLayer.fillColor = colors[index].cgColor
            layer.addSublayer(segmentLayer)
            
            startAngle = endAngle
        }

        drawLegend(in: rect, entities: displayItems)
    }
    
    private func drawLegend(in rect: CGRect, entities: [Entity]) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left

        let total = entities.map(\.value).reduce(0, +)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .paragraphStyle: paragraph
        ]

        var yOffset: CGFloat = bounds.midY - CGFloat(entities.count * 20)

        for (index, entity) in entities.enumerated() {
            let color = colors[index]
            let percent = Int(round((entity.value / total as NSDecimalNumber).doubleValue * 100))
            let text = "\(percent)% \(entity.label)"

            let dotRect = CGRect(x: bounds.midX - 40, y: yOffset + 4, width: 12, height: 12)
            let dotPath = UIBezierPath(ovalIn: dotRect)
            color.setFill()
            dotPath.fill()

            let textRect = CGRect(x: bounds.midX - 20, y: yOffset, width: bounds.width / 2, height: 20)
            (text as NSString).draw(in: textRect, withAttributes: attributes)

            yOffset += 24
        }
    }
}

