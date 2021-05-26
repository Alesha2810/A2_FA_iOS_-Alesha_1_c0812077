//
//  AddProductViewController.swift
//  A2_FA_iOS_ Alesha_c0812077
//
//  Created by Alesha on 25/05/21.
//  Copyright © 2021 XYZ. All rights reserved.
//

import UIKit
import CoreData
import Toast_Swift
import IQKeyboardManager

class AddProductViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var btnAdd: UIButton!
    @IBOutlet var txtProductName: UITextField!
    @IBOutlet var txtProductProvider: UITextField!
    @IBOutlet var txtProductPrice: UITextField!
    @IBOutlet var txtProductDesc: UITextView!
    @IBOutlet var btnClose: UIButton!
    @IBOutlet var vMain: UIView!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var vTopline: UIView!
    @IBOutlet var btnDropDown: UIButton!

    var pickerProvider = UIPickerView()
    
    var arrProviders: [NSManagedObject] = []
    var dicProduct: [NSManagedObject] = []
 
    var intAccountIndex:Int = 0
    
    var isEdit: Bool = false
    var primaryID: NSInteger = 2
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.setupHideKeyboardOnTap()
        
        vMain.layer.cornerRadius = 10
        vMain.layer.masksToBounds = true
        
        btnAdd.layer.cornerRadius = 5
        btnAdd.layer.masksToBounds = true
        
        btnDropDown.layer.cornerRadius = btnDropDown.frame.width/2
        btnDropDown.layer.masksToBounds = true
        
        appDelegate.setShadow(vMain)
        
        txtProductName.setPlaceHolderColor(.lightGray)
        txtProductProvider.setPlaceHolderColor(.lightGray)
        txtProductPrice.setPlaceHolderColor(.lightGray)
        lblDesc.textColor = appDelegate.CRGB(r: 170, g: 170, b: 170)
        
        appDelegate.setBottomBorder(textfield: txtProductName)
        appDelegate.setBottomBorder(textfield: txtProductProvider)
        appDelegate.setBottomBorder(textfield: txtProductPrice)
        
        txtProductDesc.layer.cornerRadius = 10
        txtProductDesc.layer.masksToBounds = true
        txtProductDesc.layer.borderWidth = 1
        txtProductDesc.layer.borderColor = UIColor.lightGray.cgColor
        txtProductDesc.textContainerInset = UIEdgeInsets(top: 20, left: 15, bottom: 15, right: 15)

        vTopline.layer.cornerRadius = 10
        vTopline.layer.masksToBounds = true
        
        txtProductName.delegate = self
        txtProductProvider.delegate = self
        txtProductPrice.delegate = self
        pickerProvider.delegate = self
        
        txtProductProvider.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonClicked))

        retrieveProvidersData()
        
        if isEdit {
            print(dicProduct[0]);
            
            txtProductName.text! = dicProduct[0].value(forKey: "product_name") as! String
            txtProductProvider.text! = dicProduct[0].value(forKey: "product_provider") as! String
            txtProductPrice.text! = dicProduct[0].value(forKey: "product_price") as! String
            txtProductDesc.text! = dicProduct[0].value(forKey: "product_desc") as! String
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Core Data Providers
    
    func retrieveProvidersData() {
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
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
            pickerProvider.reloadAllComponents()
            
        } catch {
            
            print("Failed")
        }
    }
    
    // MARK: - Core Data
    
    func storeData() {
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Now let’s create an entity and new user records.
        let productEntity = NSEntityDescription.entity(forEntityName: "Product", in: managedContext)!
    
        // Here data will be stored one by one in database
        let product = NSManagedObject(entity: productEntity, insertInto: managedContext)
        
        //Now let’s create an entity and new user records.
        let managedContextPro = appDelegate.persistentContainer.viewContext
        let providerEntity = NSEntityDescription.entity(forEntityName: "Provider", in: managedContextPro)!
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Provider")
        fetchRequest.predicate = NSPredicate(format: "product_provider = %@", txtProductProvider.text!)
        let provider = NSManagedObject(entity: providerEntity, insertInto: managedContextPro)
        
        if CUserDefaults.value(forKey: "primaryID") != nil {
            primaryID = CUserDefaults.value(forKey: "primaryID") as! NSInteger
        }
        
        print(primaryID)
        
        product.setValue(primaryID + 1, forKeyPath: "id")
        product.setValue(txtProductName.text!, forKey: "product_name")
        product.setValue(txtProductPrice.text!, forKey: "product_price")
        product.setValue(txtProductDesc.text!, forKey: "product_desc")
        product.setValue(txtProductProvider.text!, forKey: "product_provider")
        
        do
        {
            let test = try managedContextPro.fetch(fetchRequest)
            
            if test.count == 0 {
                provider.setValue(txtProductProvider.text!, forKey: "product_provider")
                provider.setValue(primaryID + 1, forKeyPath: "provider_id")
                
                do {
                    try managedContextPro.save()
                    
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
            else{
                //
            }
        }
        catch
        {
            print(error)
        }
        
        CUserDefaults.set(primaryID + 1, forKey: "primaryID")
        CUserDefaults.synchronize()
        
        //Now we have set all the values. The next step is to save them inside the Core Data
        
        do {
            try managedContext.save()
            
            appDelegate.topMostController()?.dismiss(animated: false, completion: nil)
            NotificationCenter.default.post(name: Notification.Name("ProductRefresh"), object: nil)
            appDelegate.window?.makeToast("Product added!", duration: 3.0, position: .bottom)
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    func updateData(){
        
        // Product
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Product")
        fetchRequest.predicate = NSPredicate(format: "id = %ld", dicProduct[0].value(forKey: "id") as! NSInteger)
        
        
        // Provider
        //Now let’s create an entity and new user records.
        let managedContextPro = appDelegate.persistentContainer.viewContext
        let providerEntity = NSEntityDescription.entity(forEntityName: "Provider", in: managedContextPro)!
        let fetchRequestPro:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Provider")
        fetchRequestPro.predicate = NSPredicate(format: "product_provider = %@", txtProductProvider.text!)
        let provider = NSManagedObject(entity: providerEntity, insertInto: managedContextPro)

        do
        {
            do
            {
                let testPro = try managedContextPro.fetch(fetchRequestPro)
                
                if testPro.count == 0 {
                    if CUserDefaults.value(forKey: "primaryID") != nil {
                        primaryID = CUserDefaults.value(forKey: "primaryID") as! NSInteger
                    }
                    provider.setValue(txtProductProvider.text!, forKey: "product_provider")
                    provider.setValue(primaryID + 1, forKeyPath: "provider_id")
                    
                    do {
                        try managedContextPro.save()
                        
                        CUserDefaults.set(primaryID + 1, forKey: "primaryID")
                        CUserDefaults.synchronize()
                        
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                }
                else{
                    //
                }
            }
            catch
            {
                print(error)
            }
            
            let test = try managedContext.fetch(fetchRequest)
            
            let objectUpdate = test[0] as! NSManagedObject
            objectUpdate.setValue(txtProductName.text!, forKey: "product_name")
            objectUpdate.setValue(txtProductPrice.text!, forKey: "product_price")
            objectUpdate.setValue(txtProductDesc.text!, forKey: "product_desc")
            objectUpdate.setValue(txtProductProvider.text!, forKey: "product_provider")
            
            do{
                try managedContext.save()
                
                appDelegate.topMostController()?.dismiss(animated: false, completion: nil)
                NotificationCenter.default.post(name: Notification.Name("ProductRefresh"), object: nil)
                appDelegate.window?.makeToast("Product updated!", duration: 3.0, position: .bottom)
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
    
    // MARK:- Button Actions
    
    @IBAction func clickOnSubmit(_ sender: UIButton)
    {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
        
        if txtProductName.text!.isEmpty {
            self.view.makeToast("Please enter Product Name", duration: 3.0, position: .bottom)
        }else if txtProductProvider.text!.isEmpty {
            self.view.makeToast("Please enter Product Provider", duration: 3.0, position: .bottom)
        }else if txtProductPrice.text!.isEmpty {
            self.view.makeToast("Please enter Product Price", duration: 3.0, position: .bottom)
        }else if txtProductDesc.text!.isEmpty {
            self.view.makeToast("Please enter Description", duration: 3.0, position: .bottom)
        }else{
            if isEdit {
                updateData()
            }else{
                storeData()
            }
        }
    }
    
    @IBAction func clickOnClose(_ sender: UIButton)
    {
        appDelegate.topMostController()?.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func clickOnDropDown(_ sender: UIButton)
    {
        txtProductProvider.inputView = pickerProvider
        txtProductProvider.tintColor = UIColor.clear
        txtProductProvider.becomeFirstResponder()
    }
    
    // MARK: UIPickerView Delegation
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return arrProviders.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let provider = arrProviders[row]
        return provider.value(forKeyPath: "product_provider") as? String
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let provider = arrProviders[row]
        txtProductProvider.text = provider.value(forKeyPath: "product_provider") as? String
        intAccountIndex = row
    }
    
    //MARK:- Helper
    
    @objc func doneButtonClicked(_ sender: Any) {
        txtProductProvider.inputView = .none
        txtProductProvider.tintColor = UIColor.systemBlue
    }
    
    // MARK: - Textfield Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
}
extension UIViewController {
    /// Call this once to dismiss open keyboards by tapping anywhere in the view controller
    func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }
    
    /// Dismisses the keyboard from self.view
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
}
