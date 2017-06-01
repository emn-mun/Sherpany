import UIKit
import CoreData

class MasterViewController: SherpanyViewController {
    
    let tableView = UITableView()
    
    fileprivate let masterCellID = "masterCellID"
    public weak var splitViewDelegate: SherpanySplitViewProtocol?
    var searchString: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Challenge Accepted!"
        setupTableView()
        updateTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.register(MasterTableViewCell.self, forCellReuseIdentifier: masterCellID)
        tableView.allowsMultipleSelectionDuringEditing = false
        
        tableView.delegate = self
        tableView.dataSource = self
        splitViewController?.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
    
    fileprivate func updateTableView() {
        do {
            try self.fetchedResultController.performFetch()
            print("COUNT FETCHED FIRST: \(String(describing: self.fetchedResultController.sections?[0].numberOfObjects))")
            tableView.reloadData()
        } catch let error  {
            print("ERROR: \(error)")
        }
    }
    
    lazy var fetchedResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Post.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
}

extension MasterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CoreDataStack.sharedInstance.persistentContainer.viewContext.perform {
                do {
                    let object = self.fetchedResultController.object(at: indexPath) as! NSManagedObject
                    CoreDataStack.sharedInstance.persistentContainer.viewContext.delete(object)
                    try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
                    
                } catch {
                    print("Failed saving delete")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let post = fetchedResultController.object(at: indexPath) as? Post {
            
            if (UIApplication.shared.delegate as! AppDelegate).window!.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.compact {
                let detailViewController = DetailViewController()
                detailViewController.post = post
                navigationController?.pushViewController(detailViewController, animated: true)
            } else {
                
            }
            splitViewDelegate?.updateDetailForPost(post: post)
        }
    }
}

extension MasterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedResultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: masterCellID, for: indexPath) as! MasterTableViewCell
        if let post = fetchedResultController.object(at: indexPath) as? Post {
            cell.setMasterCellWith(post: post)
        }
        return cell
    }
}

extension MasterViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .automatic)
        default:
            break
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            self.tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            if let cell = tableView.cellForRow(at: indexPath) as? MasterTableViewCell, let post = fetchedResultController.object(at: indexPath) as? Post {
                cell.setMasterCellWith(post: post)
            }
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.insertRows(at: [newIndexPath], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
}

extension MasterViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if let secondaryNavigationController = secondaryViewController as? UINavigationController,
            let secondaryViewController = secondaryNavigationController.topViewController as? DetailViewController {
            if secondaryViewController.post == nil {
                return true
            }
        }
        return false
    }
}
