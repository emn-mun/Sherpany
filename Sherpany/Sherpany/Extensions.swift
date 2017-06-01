import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadImageUsingCacheWithURLString(_ urlString: String, placeholder: UIImage?) {
        self.image = nil
        if let cachedImage = imageCache.object(forKey: NSString(string: urlString)) {
            self.image = cachedImage
            return
        }
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
                if error != nil {
                    print("Error Loading Image from url: \(url). Error: \(error!.localizedDescription)")
                    DispatchQueue.main.async {
                        self.image = #imageLiteral(resourceName: "placeholder")
                    }
                    return
                }
                DispatchQueue.main.async {
                    if let data = data {
                        if let downloadImage = UIImage(data: data) {
                            imageCache.setObject(downloadImage, forKey: NSString(string: urlString))
                            self.image = downloadImage
                        }
                    }
                }
            }).resume()
        }
    }
}
