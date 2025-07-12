import UIKit

final class CustomDatePickerView: UIView {
    var onDateChanged: ((Date) -> Void)?

    var date: Date = Date() {
        didSet {
            dateLabel.text = formatDate(date).capitalized
            datePicker.date = date
        }
    }

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .mintGreen
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ru")
        picker.alpha = 0.011
        picker.isUserInteractionEnabled = true
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return picker
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        dateLabel.text = formatDate(date).capitalized
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        addSubview(backgroundView)
        backgroundView.addSubview(dateLabel)
        addSubview(datePicker)

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.heightAnchor.constraint(equalToConstant: 34),

            datePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor),

            dateLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -12),
            dateLabel.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor)
        ])
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "ru")
        return formatter.string(from: date)
    }
    
    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker) {
        self.date = sender.date
        onDateChanged?(sender.date)
    }
}

#Preview {
    AnalysisViewController(direction: .outcome)
}
