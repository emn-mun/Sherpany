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
    
    var post: Post? {
        didSet {
            postTitleLabel.text = post?.title
            postBodyLabel.text = post?.body
            albums = post?.user?.albums?.allObjects as? [Album]
            visibleSections = [Int]()
            collectionView.reloadData()
        }
    }
    
    var albums: [Album]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var visibleSections = [Int]()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Detail"
        view.backgroundColor = .white
        setupCollectionView()
        setupViews()
    }
    
    private func setupCollectionView() {
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: detailCellID)
        collectionView.register(PhotoCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerCellID)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        let collectionViewLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        collectionViewLayout.headerReferenceSize = CGSize(width: 200, height: 40)
        collectionViewLayout.sectionHeadersPinToVisibleBounds = true
    }
    
    private func setupViews() {
        view.addSubview(postTitleLabel)
        view.addSubview(postBodyLabel)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            postTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.labelHorizontal),
            postTitleLabel.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: Padding.labelHorizontal),
            postTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Padding.labelHorizontal),
            
            postBodyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.labelHorizontal),
            postBodyLabel.topAnchor.constraint(equalTo: postTitleLabel.bottomAnchor, constant: Padding.labelVertical),
            postBodyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Padding.labelHorizontal),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: postBodyLabel.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
            ])
    }
}

extension DetailViewController: SherpanySplitViewProtocol {
    func updateDetailForPost(post: Post) {
        self.post = post
    }
}

extension DetailViewController: UICollectionViewDelegate {
    
}

extension DetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: detailCellID, for: indexPath) as! PhotoCollectionViewCell
        let album = albums![indexPath.section]
        let photo = (album.photos?.allObjects as! [Photo])[indexPath.row]
        cell.setDetailCellWith(photo: photo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind:UICollectionElementKindSectionHeader, withReuseIdentifier:headerCellID, for: indexPath) as? PhotoCollectionViewHeader ?? PhotoCollectionViewHeader(frame: .zero)
        let album = albums![indexPath.section]
        header.titleLabel.text = album.title
        header.tag = indexPath.section
        header.isUserInteractionEnabled = true
        header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DetailViewController.onShowHideSection)))
        header.layer.zPosition = 999
        return header
    }
    
    func onShowHideSection(sender: Any) {
        if let gesture = sender as? UITapGestureRecognizer, let headerView = gesture.view {
            let index = headerView.tag
            if albums?[index].photos != nil && !albums![index].photos!.allObjects.isEmpty {
                if visibleSections.contains(index) {
                    hidePhotosAtSectionWithIndex(index: index)
                } else {
                    showPhotosAtSectionWithIndex(index: index)
                }
            } else {
                showAlertWith(title: "Initial data is curently downloading", message: "Please wait a moment ")
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (post == nil || albums == nil) ? 0 : albums!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !visibleSections.contains(section) {
            return 0
        }
        return (post == nil || albums == nil) ? 0 : albums![section].photos!.count
    }
}

extension DetailViewController: ShowHideSectionPhotosDelegate {
    func showPhotosAtSectionWithIndex(index: Int) {
        if !visibleSections.contains(index) {
            visibleSections.append(index)
        }
        collectionView.reloadSections(IndexSet(integer: index))
    }
    
    func hidePhotosAtSectionWithIndex(index: Int) {
        if let idx = visibleSections.index(of: index) {
            visibleSections.remove(at: idx)
            collectionView.reloadSections(IndexSet(integer: index))
        }
    }
}
