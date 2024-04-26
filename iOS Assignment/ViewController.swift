//
//  ViewController.swift
//  iOS Assignment
//
//  Created by Yudhishthir Singh Rathore on 18/04/24.
//

import UIKit
import Network

var kImageInCache = NSCache<NSString, UIImage>()

class ViewController: UIViewController {
    
    @IBOutlet weak var imgCV: UICollectionView!
    
    var imageArrays = [WelcomeElement]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchImageData()
    }
    
    // for download image from URL responce
    func downloadImage(from url:URL, completion: @escaping(_ result:UIImage?) -> ()){
        
        let dataTask = URLSession.shared.dataTask(with: url, completionHandler: {(data,responce,error) in
            guard let httpURLres = responce as? HTTPURLResponse, httpURLres.statusCode == 200, let mimeTyme = responce?.mimeType , mimeTyme.hasPrefix("image") , let data = data , error == nil , let image =  UIImage(data: data) else {
                completion(nil)
                return
            }
            
            completion(image)
        })
        dataTask.resume()
    }
}

// collection view UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.imageArrays.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCvCell", for: indexPath) as! imageCvCell
        cell.imgIcon.image = nil
        cell.imgAct.isHidden = false
        cell.imgAct.startAnimating()
        
        let imageUrl = self.imageArrays[indexPath.row].thumbnail.domain + "/" + self.imageArrays[indexPath.row].thumbnail.basePath + "/0/" + self.imageArrays[indexPath.row].thumbnail.key.rawValue
        
        if  let image = kImageInCache.object(forKey: self.imageArrays[indexPath.row].id as NSString){
            cell.imgIcon.image = image
            cell.imgAct.isHidden = true
            cell.imgAct.stopAnimating()
        }else if let image = ImageCache.shared.getImage(of: self.imageArrays[indexPath.row].id){
            cell.imgIcon.image = image
            cell.imgAct.isHidden = true
            cell.imgAct.stopAnimating()
        }else{
            self.downloadImage(from: URL(string: imageUrl)!) { result in
                DispatchQueue.main.async {
                    if let image = result{
                        kImageInCache.setObject(image, forKey: self.imageArrays[indexPath.row].id as NSString)
                        ImageCache.shared.set(image: image, key: self.imageArrays[indexPath.row].id)
                        cell.imgIcon.image = image
                        cell.imgAct.isHidden = true
                        cell.imgAct.stopAnimating()
                        
                    }else{
                        cell.imgIcon.image = UIImage(named: "error")
                        cell.imgAct.isHidden = true
                        cell.imgAct.stopAnimating()
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewSize = collectionView.frame.size.width
        return CGSize(width: (collectionViewSize - 4.0)/3.0, height: (collectionViewSize - 4.0)/3.0)
    }
}


// Api Calling for URL
extension ViewController{
    
    func fetchImageData(){
        
        guard let url = URL(string: "https://acharyaprashant.org/api/v2/content/misc/media-coverages?limit=100") else {
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url, completionHandler: { data, responce, error in
            guard let dataObject = data, error == nil else{
                DispatchQueue.main.async {
                    self.makeAlert(title: "Error", message: error?.localizedDescription.debugDescription ?? "", buttonTitle: "Retry")
                }
                return
            }
            do{
                let imageArray = try JSONDecoder().decode([WelcomeElement].self, from: dataObject)
                self.imageArrays = imageArray
                DispatchQueue.main.async {
                    self.imgCV.reloadData()
                }
            }catch{
                DispatchQueue.main.async {
                    self.makeAlert(title: "Error", message: "\(error.localizedDescription.debugDescription )", buttonTitle: "Retry")
                }
            }
            
        })
        dataTask.resume()
        
    }
}

// UIAlertAction
extension ViewController{
    
    func makeAlert(title: String, message: String, buttonTitle: String) {
        // Create the alert controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: buttonTitle, style: .default) { (action:UIAlertAction!) in

            self.fetchImageData()
        }
        
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion:nil)
    }
}
