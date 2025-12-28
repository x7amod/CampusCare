import UIKit

final class UserItemView: UITableViewCell {

    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!

    var onTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupDesign()
        setupTapOnce()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        usernameLabel.text = nil
        roleLabel.text = nil
        onTap = nil // ✅ important so old closures don’t stay with reused cells
    }

    func configure(with user: UserModel) {
        nameLabel.text = "\(user.FirstName) \(user.LastName)".trimmingCharacters(in: .whitespaces)
        usernameLabel.text = user.username
        roleLabel.text = user.Role
    }

    private func setupDesign() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        cardContainerView.backgroundColor = .white
        cardContainerView.layer.cornerRadius = 18
        cardContainerView.layer.masksToBounds = false

        cardContainerView.layer.shadowColor = UIColor.black.cgColor
        cardContainerView.layer.shadowOpacity = 0.08
        cardContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardContainerView.layer.shadowRadius = 8
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cardContainerView.layer.shadowPath = UIBezierPath(
            roundedRect: cardContainerView.bounds,
            cornerRadius: cardContainerView.layer.cornerRadius
        ).cgPath
    }

    // MARK: - Tap Handling (ONLY ONCE)
    private func setupTapOnce() {
        // Add gesture on the card container (best UX)
        cardContainerView.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        cardContainerView.addGestureRecognizer(tap)
    }

    @objc private func handleTap() {
        onTap?()
    }
}
