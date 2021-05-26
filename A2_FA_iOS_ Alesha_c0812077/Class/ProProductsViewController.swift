//
//  ProProductsViewController.swift
//  A2_FA_iOS_ Alesha_c0812077
//
//  Created by Alesha on 25/05/21.
//  Copyright © 2021 XYZ. All rights reserved.
//

import UIKit
import CoreData

class ProProductsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tblProduct : UITableView!
    @IBOutlet var vAlert : UIView!
    var arrProduts: [NSManagedObject] = []
    var strTitle: String = ""
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = strTitle
        configureNavBar()
        
        tblProduct.register(UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "ProductCell")
        retrieveData()
    }
    
    // MARK: - Core Data Providers
    
    func retrieveData() {
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "product_provider == %@", strTitle)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                arrProduts.append(data)
            }
            tblProduct.reloadData()
            
            if arrProduts.count > 0 {
                vAlert.isHidden = true
            }else{
                vAlert.isHidden = false
            }
            
        } catch {
            
            print("Failed")
        }
    }
    
    
    // MARK: - Local Funtion
    
    func configureNavBar() {
        self.navigationController?.navigationBar.tintColor =  appDelegate.CRGB(r: 255, g: 255, b: 255)
        self.navigationController?.navigationBar.barTintColor = appDelegate.CRGB(r: 0, g: 149, b: 225)
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
    }
    
    // MARK: - TableView Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrProduts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ProductCell = tableView.dequeueReusableCell(withIdentifier: "ProductCell") as! ProductCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let product = arrProduts[indexPath.row]
        
        cell.lblProductName.text = product.value(forKeyPath: "product_name") as? String
        cell.lblProductDesc.text = product.value(forKeyPath: "product_desc") as? String
        
        let number = Int(product.value(forKeyPath: "product_price") as! String)
        cell.lblProductPrice.text = "₹" + number!.delimiter
        cell.lblProductProvider.text = product.value(forKeyPath: "product_provider") as? String
        
        cell.btnDelete.isHidden = true
        
        // cell.btnDelete.tag = indexPath.row
        // cell.btnDelete.addTarget(self, action:  #selector(deleteTapped(_:)), for: .touchUpInside)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
