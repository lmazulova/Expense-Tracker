import UIKit

final class PeriodCell: UITableViewCell {

    static let identifier = "PeriodCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dateButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        config.background.backgroundColor = UIColor(named: "mintGreen")
        config.baseForegroundColor = .black
        config.cornerStyle = .medium
        
        let button = UIButton(configuration: config)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .inline
        picker.layer.cornerRadius = 13
        picker.layer.masksToBounds = true
        picker.backgroundColor = .systemBackground
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ru_RU")
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private var isPickerVisible = false
    private var datePickerHeightConstraint: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
        updateButtonTitle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateButton)
        contentView.addSubview(datePicker)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),

            dateButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

            datePicker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        // Initially hidden
        datePicker.isHidden = true
        datePickerHeightConstraint = datePicker.heightAnchor.constraint(equalToConstant: 0)
        datePickerHeightConstraint?.isActive = true

        dateButton.addTarget(self, action: #selector(toggleDatePicker), for: .touchUpInside)
    }

    @objc private func dateChanged() {
        updateButtonTitle()
    }

    private func updateButtonTitle() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"
        let title = formatter.string(from: datePicker.date).capitalized
        dateButton.setTitle(title, for: .normal)
    }

    @objc private func toggleDatePicker() {
        isPickerVisible.toggle()
        datePicker.isHidden = !isPickerVisible
        datePickerHeightConstraint?.constant = isPickerVisible ? 300 : 0

        UIView.animate(withDuration: 0.25) {
            self.contentView.layoutIfNeeded()
        }

        if let tableView = self.findTableView() {
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
    }

    private func findTableView() -> UITableView? {
        var view: UIView? = self
        while let current = view {
            if let tableView = current as? UITableView {
                return tableView
            }
            view = current.superview
        }
        return nil
    }
    
    func configureCell(title: String) {
        titleLabel.text = title
    }
}

import SwiftUI

struct PeriodCellPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> PeriodCell {
        let cell = PeriodCell(style: .default, reuseIdentifier: nil)
        cell.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        cell.configureCell(title: "Период: начало")
        return cell
    }
    func updateUIView(_ uiView: PeriodCell, context: Context) {}
}

#Preview {
    PeriodCellPreview()
        .frame(width: 400, height: 400)
}
