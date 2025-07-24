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
        
        let sortedEntities = Array(entities.sorted { $0.value > $1.value })
        let topEntities = Array(sortedEntities.prefix(5))
        let remaining = sortedEntities.dropFirst(5)
        let remainingValue = remaining.map(\.value).reduce(0, +)
        
        var displayItems = topEntities
        if remainingValue > 0 {
            displayItems.append(Entity(value: remainingValue, label: "Остальные"))
        }

        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        let outerRadius = min(bounds.width, bounds.height) * 0.5
        let innerRadius = outerRadius * 0.9
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
        let total = entities.map(\.value).reduce(0, +)
        
        let dotSize: CGFloat = 6
        let spacing: CGFloat = 5
        let interItemSpacing: CGFloat = 4
        let textWidth: CGFloat = bounds.width * 0.6 - dotSize - spacing
        let startX = bounds.midX - (bounds.width * 0.6) / 2

        let font = UIFont.systemFont(ofSize: 7, weight: .regular)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .left

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraph
        ]

        var textHeights: [CGFloat] = []
        for entity in entities {
            let percent = Int(round((entity.value / total as NSDecimalNumber).doubleValue * 100))
            let text = "\(percent)% \(entity.label)" as NSString
            let bounding = text.boundingRect(
                with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: attributes,
                context: nil
            )
            textHeights.append(ceil(bounding.height))
        }

        let totalHeight = textHeights.reduce(0, +) + CGFloat((entities.count - 1)) * interItemSpacing
        var yOffset = bounds.midY - totalHeight / 2

        for (index, entity) in entities.enumerated() {
            let color = colors[index]
            let percent = Int(round((entity.value / total as NSDecimalNumber).doubleValue * 100))
            let text = "\(percent)% \(entity.label)" as NSString
            let height = textHeights[index]

            let dotY = yOffset + (height - dotSize) / 2
            let dotRect = CGRect(x: startX, y: dotY, width: dotSize, height: dotSize)
            let dotPath = UIBezierPath(ovalIn: dotRect)
            color.setFill()
            dotPath.fill()

            let textRect = CGRect(
                x: startX + dotSize + spacing,
                y: yOffset,
                width: textWidth,
                height: height
            )
            text.draw(in: textRect, withAttributes: attributes)

            yOffset += height + interItemSpacing
        }
    }
}

