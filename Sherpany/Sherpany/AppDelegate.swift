import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        
        let masterViewController = MasterViewController()
        let detailViewController = DetailViewController()
        masterViewController.splitViewDelegate = detailViewController
        
        let masterNavigationViewController = UINavigationController(rootViewController: masterViewController)
        let detailNavigationViewController = UINavigationController(rootViewController: detailViewController)
        
        let splitScreenViewController = UISplitViewController()
        splitScreenViewController.viewControllers = [masterNavigationViewController, detailNavigationViewController]
        splitScreenViewController.view.backgroundColor = .white
        splitScreenViewController.preferredDisplayMode = .allVisible
        
        window?.rootViewController = splitScreenViewController
        
        CoreDataStack.sharedInstance.applicationDocumentsDirectory()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        Manager.shared.fetchAllDataWithCompletion {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Photos Fetched", message: "Latest photos successfully retrieved", preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(action)
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataStack.sharedInstance.saveContext()
    }
}

