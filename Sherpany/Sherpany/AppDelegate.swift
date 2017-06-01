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
        
        let masterNavigationViewController = UINavigationController(rootViewController: masterViewController)
        let detailNavigationViewController = UINavigationController(rootViewController: detailViewController)
        
        let splitScreenViewController = UISplitViewController()
        splitScreenViewController.viewControllers = [masterNavigationViewController, detailNavigationViewController]
        splitScreenViewController.view.backgroundColor = .white
        splitScreenViewController.preferredDisplayMode = .allVisible
        
        window?.rootViewController = splitScreenViewController
        
        return true
    }
}

