import UIKit

final class TransactionCell: UITableViewCell {
    static let identifier = "transactionCell"
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.backgroundColor = .mintGreen
        label.layer.cornerRadius = 11
        label.clipsToBounds = true
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()
    
    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var infoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [categoryLabel])
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }()
    
    private lazy var amountStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [percentageLabel, amountLabel])
        stack.axis = .vertical
        stack.alignment = .trailing
        stack.spacing = 2
        return stack
    }()
    
    private lazy var horizontalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emojiLabel, infoStack, amountStack])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupConstraints() {
        contentView.addSubview(horizontalStack)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            horizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            horizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            emojiLabel.widthAnchor.constraint(equalToConstant: 22),
            emojiLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    func configure(with category: Category, amount: Decimal?, categorySum: Decimal? = nil, currency: Currency) {
        if let amount = amount, let categorySum = categorySum, abs(amount) > 0 {
            let percentageDecimal = categorySum / amount * 100
            let percentage = NSDecimalNumber(decimal: abs(percentageDecimal)).rounding(accordingToBehavior: nil)
            percentageLabel.text = "\(percentage)%"
        } else {
            percentageLabel.text = "0%"
        }
        
        let currency = currency
        
        categoryLabel.text = category.name
        
        if let categorySum = categorySum {
            amountLabel.text = "\(String(describing: categorySum)) \(currency.rawValue)"
        } else {
            amountLabel.text = "0 \(currency.rawValue)"
        }
        emojiLabel.text = String(category.emoji)
    }
}

import SwiftUI

struct TransactionCellPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> UITableViewCell {
        let cell = TransactionCell(style: .default, reuseIdentifier: TransactionCell.identifier)
        let category = Category(id: 1, name: "Еда", emoji: "🍔", direction: .income)
        cell.configure(with: category, amount: 1000, categorySum: 500, currency: .eur)
        return cell
    }
    func updateUIView(_ uiView: UITableViewCell, context: Context) {}
}

#Preview {
    TransactionCellPreview()
}
