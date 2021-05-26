//
//  ProductListViewController.swift
//  A2_FA_iOS_ Alesha_c0812077
//
//  Created by Alesha on 24/05/21.
//  Copyright © 2021 XYZ. All rights reserved.
//

import UIKit
import CoreData

let CUserDefaults = UserDefaults.standard
let CFirstTimeLoadData = "loaddata"

class ProductListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var txtSearch: UITextField!
    @IBOutlet var tblProduct: UITableView!
    @IBOutlet var btnAdd: UIButton!
    @IBOutlet var btnProducts: UIButton!
    @IBOutlet var btnProviders: UIButton!
    @IBOutlet var vSelected: UIImageView!
    @IBOutlet var vTop: UIView!
    @IBOutlet var vAlert: UIView!

    var arrProduts: [NSManagedObject] = []
    var arrProviders: [NSManagedObject] = []
    var strSearchText: String = ""
    var isProduct: Bool = true
    
    // static data to store in database for first time
    let arrDemoData : NSArray = [["id": 1,
                                  "product_name": "Television",
                                  "product_price": "15000",
                                  "product_desc": "Television (TV), sometimes shortened to tele or telly, is a telecommunication medium used for transmitting moving images in monochrome (black and white), or in color, and in two or three dimensions and sound. The term can refer to a television set, a television show, or the medium of television transmission. Television is a mass medium for advertising, entertainment, news, and sports.",
                                  "product_provider": "Reliance Digital"],
                                 ["id": 2,
                                  "product_name": "Washing Machine",
                                  "product_price": "25000",
                                  "product_desc": "A washing machine (laundry machine, clothes washer, or washer) is a home appliance used to wash laundry. The term is mostly applied to machines that use water as opposed to dry cleaning (which uses alternative cleaning fluids and is performed by specialist businesses) or ultrasonic cleaners. The user adds laundry detergent, which is sold in liquid or powder form, to the wash water.",
                                  "product_provider": "Croma"]]
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.title = "Products"
        
        configureNavBar()
        
        tblProduct.register(UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "ProductCell")
        tblProduct.register(UINib(nibName: "ProvidersCell", bundle: nil), forCellReuseIdentifier: "ProvidersCell")

        self.setupHideKeyboardOnTap()
                
        txtSearch.setLeftImage(UIImage(named: "ic_search"), with: CGSize(width: 20, height: 20))
        txtSearch.layer.cornerRadius = 5
        txtSearch.layer.masksToBounds = true
        txtSearch.layer.borderWidth = 1
        txtSearch.layer.borderColor = appDelegate.CRGB(r: 220, g: 220, b: 220).cgColor
        txtSearch.delegate = self
        txtSearch.returnKeyType = .done
        
        appDelegate.setShadow(btnAdd)
        
        vTop.layer.cornerRadius = vTop.frame.height/2
        vTop.layer.masksToBounds = true
        vTop.layer.borderWidth = 1
        vTop.layer.borderColor = appDelegate.CRGB(r: 0, g: 149, b: 225).cgColor
        
        vSelected.layer.cornerRadius = vSelected.frame.height/2
        vSelected.layer.masksToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setData(notification:)), name: Notification.Name("ProductRefresh"), object: nil)

        let left = UISwipeGestureRecognizer(target : self, action : #selector(ProductListViewController.leftSwipe))
        left.direction = .left
        tblProduct.addGestureRecognizer(left)
        
        let right = UISwipeGestureRecognizer(target : self, action : #selector(ProductListViewController.rightSwipe))
        right.direction = .right
        tblProduct.addGestureRecognizer(right)
        
        if isProduct {
            btnProducts.isSelected = true
            btnProviders.isSelected = false
        }else{
            btnProducts.isSelected = false
            btnProviders.isSelected = true
        }        
        
        if btnProducts.isSelected {
            self.btnTabClicked(btnProducts)
        }
        else{
            self.btnTabClicked(btnProviders)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func setData(notification: Notification) {
        arrProduts.removeAll()
        retrieveData()
    }
    
    // MARK: - Core Data for Providers
    
    func retrieveProvidersData() {
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Provider")
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "provider_id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "provider_id != 0")

        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                arrProviders.append(data)
            }
            tblProduct.reloadData()
            
            if arrProviders.count > 0 {
                vAlert.isHidden = true
            }else{
                vAlert.isHidden = false
            }
            
        } catch {
            
            print("Failed")
        }
    }
    
    func fetchCountOfProducts(strName: String) -> Int {
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "product_provider = %@", strName)

        do {
            let result = try managedContext.fetch(fetchRequest)
            return result.count
            
        } catch {
            
            print("Failed")
        }
        return 0
    }
    
    // MARK: - Core Data for Products
    
    func storeData() {
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Now let’s create an entity and new user records.
        let productEntity = NSEntityDescription.entity(forEntityName: "Product", in: managedContext)!
                
        //Now let’s create an entity and new user records.
        let managedContextPro = appDelegate.persistentContainer.viewContext
        let providerEntity = NSEntityDescription.entity(forEntityName: "Provider", in: managedContextPro)!
        
        for i in 0...arrDemoData.count - 1 {
            
            let dic: NSDictionary = arrDemoData.object(at: i) as! NSDictionary
            
            let product = NSManagedObject(entity: productEntity, insertInto: managedContext)
            let provider = NSManagedObject(entity: providerEntity, insertInto: managedContextPro)

            product.setValue(i+1, forKeyPath: "id")
            product.setValue(dic.value(forKey: "product_name"), forKey: "product_name")
            product.setValue(dic.value(forKey: "product_price"), forKey: "product_price")
            product.setValue(dic.value(forKey: "product_desc"), forKey: "product_desc")
            product.setValue(dic.value(forKey: "product_provider"), forKey: "product_provider")
            provider.setValue(dic.value(forKey: "product_provider"), forKey: "product_provider")
            provider.setValue(i+1, forKeyPath: "provider_id")
        }
        
        do {
            try managedContextPro.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        //Now we have set all the values. The next step is to save them inside the Core Data
        
        do {
            try managedContext.save()
            CUserDefaults.set("firstTime", forKey: CFirstTimeLoadData)
            CUserDefaults.synchronize()
            
            retrieveData()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    func retrieveData() {
    
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "id", ascending: true)]
        
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
    
    func deleteTable() {
        
        let context:NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest)
            for managedObject in results {
                if let managedObjectData: NSManagedObject = managedObject as? NSManagedObject {
                    context.delete(managedObjectData)
                }
            }
        } catch let error as NSError {
            print("Deleted all my data in myEntity error : \(error) \(error.userInfo)")
        }
    }
    
    func deleteData(tag: NSInteger){
    
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
        fetchRequest.predicate = NSPredicate(format: "id = %ld", tag)
        
        do
        {
            let test = try managedContext.fetch(fetchRequest)
            
            let objectToDelete = test[0] as! NSManagedObject
            managedContext.delete(objectToDelete)
            
            do{
                try managedContext.save()
                appDelegate.window?.makeToast("Product Deleted!", duration: 3.0, position: .bottom)
                tblProduct.reloadData()
                
                if arrProduts.count > 0 {
                    vAlert.isHidden = true
                }else{
                    vAlert.isHidden = false
                }
            }
            catch
            {
                print(error)
            }
        }
        catch
        {
            print(error)
        }
    }
    
    func deleteDataByName(name: String){
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
        fetchRequest.predicate = NSPredicate(format: "product_provider = %@", name)
        
        do
        {
            let test = try managedContext.fetch(fetchRequest)
            
            for i in 0...test.count - 1 {
                let objectToDelete = test[i] as! NSManagedObject
                managedContext.delete(objectToDelete)
            }
            do{
                try managedContext.save()
                appDelegate.window?.makeToast("Provider Deleted!", duration: 3.0, position: .bottom)
                tblProduct.reloadData()
                
                if arrProduts.count > 0 {
                    vAlert.isHidden = true
                }else{
                    vAlert.isHidden = false
                }
            }
            catch
            {
                print(error)
            }
        }
        catch
        {
            print(error)
        }
    }
    
    func deleteProviderData(name: String){
    
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Provider")
        fetchRequest.predicate = NSPredicate(format: "product_provider = %@", name)
        
        do
        {
            let test = try managedContext.fetch(fetchRequest)
            
            let objectToDelete = test[0] as! NSManagedObject
            managedContext.delete(objectToDelete)
            
            do{
                try managedContext.save()
                appDelegate.window?.makeToast("Provider Deleted!", duration: 3.0, position: .bottom)
                tblProduct.reloadData()
                
                if arrProviders.count > 0 {
                    vAlert.isHidden = true
                }else{
                    vAlert.isHidden = false
                }
                
                deleteDataByName(name: name)
            }
            catch
            {
                print(error)
            }
        }
        catch
        {
            print(error)
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
    
    func CViewSetX(_ view:UIView, x:CGFloat) -> Void {
        view.frame = CGRect(x: x, y: CViewY(view), width: CViewWidth(view), height: CViewHeight(view))
    }
    
    func CViewY(_ view:UIView) -> CGFloat {
        return view.frame.origin.y
    }
    
    func CViewWidth(_ view:UIView) -> CGFloat {
        return view.frame.size.width
    }
    
    func CViewHeight(_ view:UIView) -> CGFloat {
        return view.frame.size.height
    }
    
    
    // MARK: - TableView Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if btnProducts.isSelected {
            return arrProduts.count
        }else{
            return arrProviders.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if btnProducts.isSelected
        {
            let cell : ProductCell = tableView.dequeueReusableCell(withIdentifier: "ProductCell") as! ProductCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            let product = arrProduts[indexPath.row]
            
            cell.lblProductName.text = product.value(forKeyPath: "product_name") as? String
            cell.lblProductName.textColor = UIColor.black // initally set the whole color for your text
            let attString = NSMutableAttributedString(string: cell.lblProductName.text!)
            let range: NSRange = (cell.lblProductName.text! as NSString).range(of: strSearchText, options: .caseInsensitive) //he in here use searchBar.text
            attString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: range) // here set selection color what ever you typed
            cell.lblProductName.attributedText = attString
            
            cell.lblProductDesc.text = product.value(forKeyPath: "product_desc") as? String
            cell.lblProductDesc.textColor = UIColor.black // initally set the whole color for your text
            let attString2 = NSMutableAttributedString(string: cell.lblProductDesc.text!)
            let range2: NSRange = (cell.lblProductDesc.text! as NSString).range(of: strSearchText, options: .caseInsensitive) //he in here use searchBar.text
            attString2.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: range2) // here set selection color what ever you typed
            cell.lblProductDesc.attributedText = attString2
            
            let number = Int(product.value(forKeyPath: "product_price") as! String)
            cell.lblProductPrice.text = "₹" + number!.delimiter
            cell.lblProductProvider.text = product.value(forKeyPath: "product_provider") as? String
            
            cell.btnDelete.tag = indexPath.row
            cell.btnDelete.addTarget(self, action:  #selector(deleteTapped(_:)), for: .touchUpInside)
            
            return cell
        }
        else{
            let cell : ProvidersCell = tableView.dequeueReusableCell(withIdentifier: "ProvidersCell") as! ProvidersCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            let provider = arrProviders[indexPath.row]
            
            cell.lblProductProvider.text = provider.value(forKeyPath: "product_provider") as? String
            let count: Int = (fetchCountOfProducts(strName: provider.value(forKeyPath: "product_provider") as? String ?? ""))
            
            if count > 1 {
                cell.lblCount.text = "\(fetchCountOfProducts(strName: provider.value(forKeyPath: "product_provider") as? String ?? "")) products"
            }else{
                cell.lblCount.text = "\(fetchCountOfProducts(strName: provider.value(forKeyPath: "product_provider") as? String ?? "")) product"
            }
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if btnProducts.isSelected
        {
            let product = arrProduts[indexPath.row]
            
            UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(100)) {
                UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
                let presentedViewController = AddProductViewController()
                presentedViewController.isEdit = true
                presentedViewController.dicProduct = [product]
                let navController = UINavigationController(rootViewController: presentedViewController)
                navController.modalPresentationStyle = .overFullScreen
                navController.view.backgroundColor = appDelegate.CRGBA(r: 0, g: 0, b: 0, a: 0.7)
                self.present(navController, animated: false, completion: nil)
            }
        }
        else{
            
            let provider = arrProviders[indexPath.row]
            
            let obj = ProProductsViewController()
            obj.strTitle = provider.value(forKeyPath: "product_provider") as! String
            self.navigationController?.pushViewController(obj, animated: true)
        }
    }
    
     
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if btnProducts.isSelected {
            return UITableViewCell.EditingStyle.none
        } else {
            return UITableViewCell.EditingStyle.delete
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if btnProviders.isSelected
        {
            let provider = arrProviders[indexPath.row]
            let strName = (provider.value(forKeyPath: "product_provider") as? String)!

            if editingStyle == .delete {
                let alert = UIAlertController(title: "Alert!", message: "Are you sure you want to delete?", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { _ in
                    //Cancel Action
                }))
                alert.addAction(UIAlertAction(title: "Delete",
                                              style: UIAlertAction.Style.destructive,
                                              handler: {(_: UIAlertAction!) in
                                                self.arrProviders.remove(at: indexPath.row)
                                                self.tblProduct.deleteRows(at: [indexPath], with: .fade)
                                                self.deleteProviderData(name: strName)
                                                
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Textfield Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        strSearchText  = ""
        arrProduts.removeAll()
        retrieveData()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        strSearchText = newString as String
        
        if newString.length > 0 {
            //We need to create a context from this container
            let managedContext = appDelegate.persistentContainer.viewContext
            
            //Prepare the request of type NSFetchRequest  for the entity
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
            
            fetchRequest.predicate = NSPredicate(format: "product_name BEGINSWITH[c] %@ || product_desc CONTAINS[c] %@", newString, newString)
            fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "id", ascending: true)]
            
            do {
                let result = try managedContext.fetch(fetchRequest)
                arrProduts.removeAll()
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
        else{
            arrProduts.removeAll()
            retrieveData()
        }
        
        return true
    }
    
    // MARK:- Button Actions
    
    @IBAction func clickOnAdd(_ sender: UIButton) {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(100)) {
            UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
            let presentedViewController = AddProductViewController()
            let navController = UINavigationController(rootViewController: presentedViewController)
            navController.modalPresentationStyle = .overFullScreen
            navController.view.backgroundColor = appDelegate.CRGBA(r: 0, g: 0, b: 0, a: 0.7)
            self.present(navController, animated: false, completion: nil)
        }
    }
    
    @objc func deleteTapped(_ sender: UIButton){
        let index = sender.tag
        let product = arrProduts[index]
        
        let tag = (product.value(forKeyPath: "id") as? NSInteger)!
        
        let alert = UIAlertController(title: "Alert!", message: "Are you sure you want to delete?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { _ in
            //Cancel Action
        }))
        alert.addAction(UIAlertAction(title: "Delete",
                                      style: UIAlertAction.Style.destructive,
                                      handler: {(_: UIAlertAction!) in
                                        
                                        self.arrProduts.remove(at: index)
                                        self.tblProduct.deleteRows(at: [(NSIndexPath(row: index, section: 0) as IndexPath)], with: .fade)
                                        self.deleteData(tag: tag)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func btnTabClicked(_ sender:UIButton)
    {
        switch sender.tag {
        case 50:
            
            self.title = "Products"
            
            btnProducts.isSelected = true
            btnProviders.isSelected = false
            
            btnProducts.setTitleColor(UIColor.white, for: UIControl.State.normal)
            btnProviders.setTitleColor(appDelegate.CRGB(r: 0, g: 149, b: 225), for: UIControl.State.normal)
            
            btnAdd.isHidden = false
            tblProduct.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 75, right: 0)
            txtSearch.hide(byHeight: false)
            txtSearch.layoutIfNeeded()
            txtSearch.setConstraintConstant(15, edge: NSLayoutConstraint.Attribute.top, ancestor: true)
            
//            arrProduts.removeAll()
//            retrieveData()

            if CUserDefaults.value(forKey: CFirstTimeLoadData) ==  nil {
                deleteTable()
                storeData()
            }
            else{
                arrProduts.removeAll()
                retrieveData()
            }
            
            UIView.animate(withDuration: 0.2) {
                self.CViewSetX(self.vSelected, x: self.btnProducts.frame.origin.x)
            }
            
            break
            
        case 51:
            
            self.title = "Providers"
            
            btnProviders.isSelected = true
            btnProducts.isSelected = false
            
            btnProviders.setTitleColor(UIColor.white, for: UIControl.State.normal)
            btnProducts.setTitleColor(appDelegate.CRGB(r: 0, g: 149, b: 225), for: UIControl.State.normal)
            
            btnAdd.isHidden = true
            tblProduct.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
            txtSearch.hide(byHeight: true)
            txtSearch.layoutIfNeeded()
            txtSearch.setConstraintConstant(-7, edge: NSLayoutConstraint.Attribute.top, ancestor: true)
            
            arrProviders.removeAll()
            retrieveProvidersData()
            
            UIView.animate(withDuration: 0.2) {
                self.CViewSetX(self.vSelected, x: self.btnProviders.frame.origin.x)
            }
            break
            
        default:
            break
            
        }
        tblProduct.reloadData()
    }
    
    @objc func leftSwipe(){
        
        if btnProviders.isSelected {
            return
        }
        let animation = CATransition()
        animation.type = .push
        animation.subtype = .fromLeft
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .both
        animation.duration = 0.4
        
        UIView.animate(withDuration: 0.2, animations: {
            
        }) { finished in
            
        }
        
        self.btnTabClicked(btnProviders)
    }
    
    @objc func rightSwipe(){
        
        if btnProducts.isSelected {
            return
        }
        
        let animation = CATransition()
        animation.type = .push
        animation.subtype = .fromRight
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .both
        animation.duration = 0.4
        
        UIView.animate(withDuration: 0.2, animations: {
            
        }) { finished in
            
        }
        
        self.btnTabClicked(btnProducts)
    }
}

extension UIColor {
    
    class func getRandomColor() -> UIColor {
        let colors = [appDelegate.CRGB(r: 164, g: 191, b: 247), appDelegate.CRGB(r: 189, g: 168, b: 251), appDelegate.CRGB(r: 248, g: 177, b: 174)]
        let randomNumber = arc4random_uniform(UInt32(colors.count))
        
        return colors[Int(randomNumber)]
    }
    
}

extension UITextField {
    
    func addLeftPadding(withWidth width: CGFloat) {
        let textFieldPadding = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 0))
        leftView = textFieldPadding
        leftViewMode = .always
    }
    
    func setLeftImage(_ img: UIImage?, with sizeImg: CGSize) {
        let imgView = UIImageView(frame: CGRect(x: 10, y: 0, width: sizeImg.width, height: sizeImg.height))
        imgView.image = img
        imgView.contentMode = .scaleAspectFit
        imgView.layer.masksToBounds = false
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: sizeImg.width+20, height: sizeImg.height))
        paddingView.addSubview(imgView)
        imgView.center = CGPoint(x: paddingView.center.x, y: paddingView.center.y)
        
        leftView = paddingView
        leftViewMode = .always
    }
    
    func setPlaceHolderColor(_ color:UIColor) {
        self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes: [NSAttributedString.Key.foregroundColor: color])
    }
    
}
extension Int {
    private static var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter
    }()
    
    var delimiter: String {
        return Int.numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
}
