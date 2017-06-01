import UIKit
import CoreData

enum Padding {
    static let labelHorizontal: CGFloat = 8.0
    static let labelVertical: CGFloat = 10.0
}

protocol ShowHideSectionPhotosDelegate: class {
    func showPhotosAtSectionWithIndex(index: Int)
    func hidePhotosAtSectionWithIndex(index: Int)
}

class DetailViewController: SherpanyViewController {
    
    fileprivate let detailCellID = "detailCellID"
    fileprivate let headerCellID = "headerCellID"
    
    let postTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let postBodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        label.font = UIFont.italicSystemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    
    var visibleSections = [Int]()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
