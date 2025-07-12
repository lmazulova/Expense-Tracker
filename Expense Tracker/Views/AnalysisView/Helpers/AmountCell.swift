import SwiftUI

struct AmountCellPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> AmountCell {
        let cell = AmountCell(style: .default, reuseIdentifier: nil)
        cell.configureCell(amount: "20 000", currency: "₽")
        cell.frame = CGRect(x: 0, y: 0, width: 350, height: 60)
        return cell
    }
    func updateUIView(_ uiView: AmountCell, context: Context) {}
}
    
#Preview {
    AmountCellPreview()
        .frame(width: 350, height: 60)
}

import UIKit

class AmountCell: UITableViewCell {
    static let identifier = "amountCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Сумма"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        return label
    }()
   
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .right
        label.textColor = .label
        return label
    }()

    private lazy var hStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, amountLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        contentView.addSubview(hStack)
        
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configureCell(amount: String, currency: String) {
        amountLabel.text = "\(amount) \(currency)"
    }
}
