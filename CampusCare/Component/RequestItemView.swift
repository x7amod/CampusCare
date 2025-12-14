import UIKit

class RequestItemView: UIView {

    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var IDLabel: UILabel!
    @IBOutlet weak var CategoryLabel: UILabel!
    @IBOutlet weak var RoleLabel: UILabel!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var PreoriteyLabel: UILabel!

    var onTap: (() -> Void)?

    // Load from XIB
    static func instantiate() -> RequestItemView {
        let nib = UINib(nibName: "RequestItemView", bundle: nil)
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? RequestItemView else {
            fatalError("Could not load RequestItemView.xib")
        }
        return view
    }

    func configure(with model: RequestModel) {
        TitleLabel.text = model.title
        IDLabel.text = model.id
        CategoryLabel.text = model.category
        RoleLabel.text = model.location
        TimeLabel.text = DateFormatter.localizedString(from: model.releaseDate.dateValue(), dateStyle: .medium, timeStyle: .none)
        PreoriteyLabel.text = model.priority

        setupTap()
    }

    // Tap Handling
    private func setupTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    @objc private func handleTap() {
        onTap?()
    }
}
