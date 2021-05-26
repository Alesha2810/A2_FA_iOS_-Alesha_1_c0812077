//
//  SideMenuViewController.swift
//  A2_FA_iOS_ Alesha_c0812077
//
//  Created by Alesha on 25/05/21.
//  Copyright © 2021 XYZ. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController, UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet var tblSideMenu : UITableView!
    @IBOutlet var imgProfile : UIImageView!
    @IBOutlet var lblName : UILabel!
    
    var arrTitle = NSArray()
    var arrImage = NSArray()
    var selectedIndexpath = NSIndexPath()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrTitle = ["Products", "Providers"]
        
        tblSideMenu.register(UINib(nibName: "LeftViewCell", bundle: nil), forCellReuseIdentifier: "LeftViewCell")
        tblSideMenu.tableFooterView = UIView.init(frame: .zero)
        
        imgProfile.layer.cornerRadius = imgProfile.frame.width/2
        imgProfile.layer.masksToBounds = true
        
        imgProfile.layer.borderWidth = 1
        imgProfile.layer.borderColor = UIColor.white.cgColor
        
        selectedIndexpath = NSIndexPath(item: 0, section: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if UIDevice.current.hasNotch {
            return 60
        }else{
            return 50
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : LeftViewCell = tableView.dequeueReusableCell(withIdentifier: "LeftViewCell") as! LeftViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cell.lblName.text = arrTitle.object(at: indexPath.row) as? String
        
        if indexPath == selectedIndexpath as IndexPath {
            cell.backgroundColor = UIColor.white
            cell.lblName.textColor = UIColor.black
            
            if indexPath.row == 0 {
                cell.imgPic.image = UIImage(named: "ic_product")
            }else{
                cell.imgPic.image = UIImage(named: "ic_provider")
            }
        }
        else {
            cell.backgroundColor = UIColor.clear
            cell.lblName.textColor = UIColor.white
            
            if indexPath.row == 0 {
                cell.imgPic.image = UIImage(named: "ic_product_white")
            }else{
                cell.imgPic.image = UIImage(named: "ic_provider_white")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath != selectedIndexpath as IndexPath {
            tblSideMenu .reloadData()
        }
        
        selectedIndexpath = indexPath as NSIndexPath
        
        switch indexPath.row {
        case 0:
            let viewcontroller = ProductListViewController()
            viewcontroller.isProduct = true
            let home = UINavigationController(rootViewController: viewcontroller)
            self.sidePanelController().centerPanel = home
            break
            
        case 1:
            let viewcontroller = ProductListViewController()
            viewcontroller.isProduct = false
            let home = UINavigationController(rootViewController: viewcontroller)
            self.sidePanelController().centerPanel = home
            break
            
        default:
            break
        }
    }
}
extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}
