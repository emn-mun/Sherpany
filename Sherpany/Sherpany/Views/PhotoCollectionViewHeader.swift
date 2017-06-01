import UIKit

class PhotoCollectionViewHeader: UICollectionReusableView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        label.font = UIFont.italicSystemFont(ofSize: 12)
        return label
    }()
    
    let showHidePhotos: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        label.font = UIFont.italicSystemFont(ofSize: 10)
        label.text = "Tap to show/ hide"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.groupTableViewBackground
        
        addSubview(titleLabel)
        addSubview(showHidePhotos)
        
        showHidePhotos.setContentHuggingPriority(UILayoutPriorityRequired - 1, for: UILayoutConstraintAxis.horizontal)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: showHidePhotos.leadingAnchor, constant: 8),
            showHidePhotos.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            showHidePhotos.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
