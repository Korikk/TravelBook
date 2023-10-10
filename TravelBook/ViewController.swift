//
//  ViewController.swift
//  TravelBook
//
//  Created by Gökay Korik on 8.10.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var nameArray = [String]()
    var descriptionArray = [String]()
    var idArrray = [UUID]()
    
    var chosenPlace = ""
    var chosenPlaceId : UUID?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        getData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    @objc func getData(){
        nameArray.removeAll(keepingCapacity: false)
        descriptionArray.removeAll(keepingCapacity: false)
        idArrray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "title") as? String {
                        self.nameArray.append(name)
                    }
                    if let descripton = result.value(forKey: "subtitle") as? String{
                        self.descriptionArray.append(descripton)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArrray.append(id)
                    }
                    self.tableView.reloadData()
                }
                
            }
            
        }catch{
            print("erorr")
        }
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = nameArray[indexPath.row]
        content.secondaryText = descriptionArray[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    @objc func addButtonClicked(){
        chosenPlace = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenPlace = nameArray[indexPath.row]
        chosenPlaceId = idArrray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.selectedTitle = chosenPlace
            destinationVC.selectedTitleID = chosenPlaceId
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let appDelegete = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegete.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Places")
            let idString = idArrray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults  = false
            
            do{
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results {
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == idArrray[indexPath.row]{
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArrray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                do{
                                    try context.save()
                                }catch{
                                    print("error")
                                }
                                break
                            }
                        }
                    }
                }
            }catch{
                print("erorr")
            }
        }
    }

}

