//
//  DetailsVC.swift
//  Artbook
//
//  Created by Pinakpani Mukherjee on 2022/02/05.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageName: UITextField!
    
    @IBOutlet weak var imageArtist: UITextField!
    
    @IBOutlet weak var imageYear: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenArt = ""
    var chosenArtId : UUID?
    
    override func viewDidLoad() {
        
        if chosenArt != ""{
            saveButton.isHidden = true
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Art")
            
            let idString = chosenArtId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            imageName.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            imageArtist.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            imageYear.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            }
            catch{
              print("error")
            }
        }
        else{
            saveButton.isHidden = false
            saveButton.isEnabled = false
            imageName.text = ""
            imageArtist.text = ""
            imageYear.text = ""
        }
        
        super.viewDidLoad()
        
        //Recogniser
        let gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecogniser)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecogniser = UITapGestureRecognizer(target: self, action: #selector(addImage))
        imageView.addGestureRecognizer(imageTapRecogniser)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    @objc func addImage(){
         let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
         present(picker,animated: true,completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonIsClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newArt = NSEntityDescription.insertNewObject(forEntityName: "Art", into: context)
        //Attributes
        newArt.setValue(imageName.text!, forKey: "name")
        newArt.setValue(imageArtist.text!, forKey: "artist")
        if let year = Int(imageYear.text!){
            newArt.setValue(year, forKey: "year")
        }
        newArt.setValue(UUID(), forKey: "id")
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        newArt.setValue(data, forKey:"image")
        
        do{
            try
            context.save()
            print("success")
        }
        catch{
            print("error")
        }
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
}
