//
//  ProductListViewController.swift
//  A2_FA_iOS_ Alesha_c0812077
//
//  Created by Alesha on 24/05/21.
//  Copyright © 2021 XYZ. All rights reserved.
//

import UIKit
import CoreData


// MARK:- Global Function
func CRGB(r red:CGFloat, g:CGFloat, b:CGFloat) -> UIColor {
    return UIColor(red: red/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
}

class ProductListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var txtSearch : UITextField!
    @IBOutlet var tblProduct : UITableView!
    var arrProduts: [NSManagedObject] = []
    var strSearchText: String = ""
    
    // static data to store in database
    let arrDemoData : NSArray = [["id": 1,
                                  "product_name": "Television",
                                  "product_price": "15000",
                                  "product_desc": "Television (TV), sometimes shortened to tele or telly, is a telecommunication medium used for transmitting moving images in monochrome (black and white), or in color, and in two or three dimensions and sound. The term can refer to a television set, a television show, or the medium of television transmission. Television is a mass medium for advertising, entertainment, news, and sports.",
                                  "product_provider": "Reliance Digital"],
                                 ["id": 2,
                                  "product_name": "Washing Machine",
                                  "product_price": "25000",
                                  "product_desc": "A washing machine (laundry machine, clothes washer, or washer) is a home appliance used to wash laundry. The term is mostly applied to machines that use water as opposed to dry cleaning (which uses alternative cleaning fluids and is performed by specialist businesses) or ultrasonic cleaners. The user adds laundry detergent, which is sold in liquid or powder form, to the wash water.",
                                  "product_provider": "Croma"],
                                 ["id": 3,
                                  "product_name": "Cooker",
                                  "product_price": "1200",
                                  "product_desc": "Cooker may refer to several types of cooking appliances and devices used for cooking foods.",
                                  "product_provider": "Radhe Electronics"],
                                 ["id": 4,
                                  "product_name": "Flower Pot",
                                  "product_price": "250",
                                  "product_desc": "A flowerpot, flower pot, planter, planterette, or alternatively plant pot is a container in which flowers and other plants are cultivated and displayed. Historically, and still to a significant extent today, they are made from plain terracotta with no ceramic glaze, with a round shape, tapering inwards. Flowerpots are now often also made from plastic, metal, wood, stone, or sometimes biodegradable material. An example of biodegradable pots are ones made of heavy brown paper, cardboard, or peat moss in which young plants for transplanting are grown.",
                                  "product_provider": "Shyam General Stores"],
                                 ["id": 5,
                                  "product_name": "Computer",
                                  "product_price": "40000",
                                  "product_desc": "A computer is a machine that can be programmed to carry out sequences of arithmetic or logical operations automatically. Modern computers can perform generic sets of operations known as programs. These programs enable computers to perform a wide range of tasks. A computer system is a complete computer that includes the hardware, operating system (main software), and peripheral equipment needed and used for full operation. This term may also refer to a group of computers that are linked and function together, such as a computer network or computer cluster.",
                                  "product_provider": "Earth Tech"],
                                 ["id": 6,
                                  "product_name": "Laptop",
                                  "product_price": "55000",
                                  "product_desc": "A laptop, laptop computer, or notebook computer is a small, portable personal computer (PC) with a screen and alphanumeric keyboard.",
                                  "product_provider": "Earth Tech"],
                                 ["id": 7,
                                  "product_name": "Mobile",
                                  "product_price": "22000",
                                  "product_desc": "A mobile phone, cellular phone, cell phone, cellphone, handphone, or hand phone, sometimes shortened to simply mobile, cell or just phone, is a portable telephone that can make and receive calls over a radio frequency link while the user is moving within a telephone service area",
                                  "product_provider": "Reliance Digital"],
                                 ["id": 8,
                                  "product_name": "Refrigerator",
                                  "product_price": "27000",
                                  "product_desc": "A refrigerator (colloquially fridge) is a home appliance consisting of a thermally insulated compartment and a heat pump (mechanical, electronic or chemical) that transfers heat from its inside to its external environment so that its inside is cooled to a temperature below the room temperature.",
                                  "product_provider": "Croma"],
                                 ["id": 9,
                                  "product_name": "Chair",
                                  "product_price": "7500",
                                  "product_desc": "One of the basic pieces of furniture, a chair is a type of seat.",
                                  "product_provider": "Woodland Furniture"],
                                 ["id": 10,
                                  "product_name": "Air Conditioner",
                                  "product_price": "44000",
                                  "product_desc": "Air conditioning (also A/C, air conditioner) is the process of removing heat and controlling the humidity (as well as removing dust in some cases) of the air within a building or vehicle, in order to achieve a more comfortable interior environment. ",
                                  "product_provider": "Raj Sales"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.title = "Products"
        
        configureNavBar()
        
        tblProduct.register(UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "ProductCell")
        txtSearch.setLeftImage(UIImage(named: "ic_search"), with: CGSize(width: 20, height: 20))
        
        txtSearch.layer.cornerRadius = 5
        txtSearch.layer.masksToBounds = true
        
        txtSearch.layer.borderWidth = 1
        txtSearch.layer.borderColor = CRGB(r: 220, g: 220, b: 220).cgColor
        
        txtSearch.delegate = self
        
        txtSearch.returnKeyType = .done
        
        deleteData()
        storeData()
    }
    
    // MARK: - Core Data
    
    func storeData() {
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Now let’s create an entity and new user records.
        let productEntity = NSEntityDescription.entity(forEntityName: "Product", in: managedContext)!
    
        // Here data will be stored one by one in database
        for i in 0...arrDemoData.count - 1 {
                        
            let dic: NSDictionary = arrDemoData.object(at: i) as! NSDictionary
            
            let product = NSManagedObject(entity: productEntity, insertInto: managedContext)
            product.setValue(i+1, forKeyPath: "id")
            product.setValue(dic.value(forKey: "product_name"), forKey: "product_name")
            product.setValue(dic.value(forKey: "product_price"), forKey: "product_price")
            product.setValue(dic.value(forKey: "product_desc"), forKey: "product_desc")
            product.setValue(dic.value(forKey: "product_provider"), forKey: "product_provider")
        }
        
        //Now we have set all the values. The next step is to save them inside the Core Data
        
        do {
            try managedContext.save()
            
            retrieveData()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    func retrieveData() {
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
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
            
        } catch {
            
            print("Failed")
        }
    }
    
    func deleteData() {
        let appDel:AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.persistentContainer.viewContext
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
    
    
    // MARK: - Local Funtion
    
    func configureNavBar() {
        self.navigationController?.navigationBar.tintColor =  CRGB(r: 255, g: 255, b: 255)
        self.navigationController?.navigationBar.barTintColor = CRGB(r: 0, g: 149, b: 225)
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
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
}

extension UIColor {
    
    class func getRandomColor() -> UIColor {
        let colors = [CRGB(r: 164, g: 191, b: 247), CRGB(r: 189, g: 168, b: 251), CRGB(r: 248, g: 177, b: 174)]
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
