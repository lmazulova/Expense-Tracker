import SwiftUI

struct CategoryCellPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> CategoryCell {
        let cell = CategoryCell(style: .default, reuseIdentifier: nil)
        let category = Category(id: 1, name: "Ремонт", emoji: "🔨", direction: .income)
        cell.configureCell(for: category, percent: "20", amount: "20 000", currency: "₽")
        cell.frame = CGRect(x: 0, y: 0, width: 350, height: 60)
        return cell
    }
    func updateUIView(_ uiView: CategoryCell, context: Context) {}
}
    
#Preview {
    CategoryCellPreview()
        .frame(width: 350, height: 60)
}


import UIKit

class CategoryCell: UITableViewCell {
    static let identifier = "categoryCell"
    
    private let iconView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "mintGreen")
        view.layer.cornerRadius = 11
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let emoji: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let percentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let chevronView: UIImageView = {
        let image = UIImageView(image: UIImage(systemName: "chevron.right"))
        image.tintColor = .systemGray3
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    private let rightStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .trailing
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private let hStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setupLayout() }
    
    private func setupLayout() {
        contentView.addSubview(hStack)
        iconView.addSubview(emoji)
        rightStack.addArrangedSubview(percentLabel)
        rightStack.addArrangedSubview(amountLabel)
        [iconView, titleLabel, rightStack, chevronView].forEach { hStack.addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),
            emoji.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            emoji.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            
            chevronView.widthAnchor.constraint(equalToConstant: 11),
            chevronView.heightAnchor.constraint(equalToConstant: 22),
        ])
        // titleLabel и rightStack сами займут нужную ширину
    }
    
    func configureCell(for category: Category, percent: String, amount: String, currency: String) {
        titleLabel.text = category.name
        emoji.text = String(category.emoji)
        percentLabel.text = "\(percent)%"
        amountLabel.text = "\(amount)\(currency)"
//        id = category.id
    }
}
