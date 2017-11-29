//
//  SecondViewController.swift
//  Breakout
//
//  Created by hyf on 17/3/3.
//  Copyright © 2017年 hyf. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {
    
    @IBOutlet weak var ballSpeedSlider: UISlider!
    
    @IBOutlet weak var paddleSizeControl: UISegmentedControl!
    
    @IBOutlet weak var bricksLabel: UILabel!
    
    var pickOption = ["15", "20", "25", "30"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ballSpeedSlider.value = Settings.sharedInstance.ballSpeed
        paddleSizeControl.selectedSegmentIndex = Settings.sharedInstance.paddleSize.rawValue as Int
        bricksLabel.text = String(Settings.sharedInstance.numberOfBricks)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let index = pickOption.index(of: String(Settings.sharedInstance.numberOfBricks)) ?? 0
            MyPickerView.showPickerView( data: pickOption, defaultSelectedIndex: index) {[unowned self] (selectedIndex) in
                //print( "选中了第\(selectedIndex)行----选中的数据为\(self.pickOption[selectedIndex])" )
                if selectedIndex != index {
                    self.bricksLabel.text = self.pickOption[selectedIndex]
                    Settings.sharedInstance.numberOfBricks = Int(self.pickOption[selectedIndex])!
                }
            }
        }
    }

    @IBAction func ballSpeedChanged(_ sender: UISlider) {
        Settings.sharedInstance.ballSpeed = ballSpeedSlider.value
    }
    
    @IBAction func paddleSizeChanged(_ sender: UISegmentedControl) {
        Settings.sharedInstance.paddleSize = Settings.PaddleSize(rawValue: paddleSizeControl.selectedSegmentIndex)!
    }
}

