import UIKit

class RequestItemView: UIView {

    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var IDLabel: UILabel!
    @IBOutlet weak var CategoryLabel: UILabel!
    @IBOutlet weak var RoleLabel: UILabel!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var PreoriteyLabel: UILabel!

    // Load from XIB
    static func instantiate() -> RequestItemView {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: "RequestItemView", bundle: bundle)
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
        TimeLabel.text = model.description
        PreoriteyLabel.text = model.priority
    }
}
