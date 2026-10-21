import UIKit

class AnnouncementCell: UITableViewCell {

    @IBOutlet private weak var categoryIconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var priorityLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        categoryIconImageView.image = nil
        categoryIconImageView.tintColor = .systemBlue
        contentView.backgroundColor = .clear
        priorityLabel.text = nil
        priorityLabel.textColor = .secondaryLabel
    }

    func configure(with announcement: CampusAnnouncement) {
        titleLabel.text = announcement.title
        dateLabel.text = "\(announcement.category) • \(announcement.date)"
        priorityLabel.text = "Location: \(announcement.location)\nPriority Level: \(announcement.priorityLevel) • \(announcement.postedBy)"

        let isUrgent = ["urgent", "high"].contains(announcement.priorityLevel.lowercased())
        categoryIconImageView.image = UIImage(
            systemName: isUrgent ? "exclamationmark.triangle.fill" : "megaphone.fill"
        )
        categoryIconImageView.tintColor = isUrgent ? .systemRed : .systemBlue
        priorityLabel.textColor = isUrgent ? .systemRed : .secondaryLabel
        contentView.backgroundColor = isUrgent
            ? UIColor.systemRed.withAlphaComponent(0.07)
            : .clear
    }
}
