//
// show pickerview as pop window
//

import UIKit

open class MyPickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {

    //MARK:- 常量
    fileprivate let pickerViewHeight:CGFloat = 200.0
    fileprivate let screenWidth = UIScreen.main.bounds.size.width
    fileprivate let screenHeight = UIScreen.main.bounds.size.height
    fileprivate var hideFrame: CGRect {
        return CGRect(x: 0.0, y: screenHeight, width: screenWidth, height: pickerViewHeight)
    }
    fileprivate var showFrame: CGRect {
        return CGRect(x: 0.0, y: screenHeight - pickerViewHeight, width: screenWidth, height: pickerViewHeight)
    }
    
    fileprivate lazy var pickerView: UIPickerView! = { [unowned self] in
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor.white
        return picker
        }()

    private var pickOption: [String] = []

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the # of rows in each component..
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //print(pickOption[row])
        selectedIndex = row
    }

    // MARK:- 初始化
    // 单列
    convenience init(frame: CGRect, data: [String], defaultSelectedIndex: Int) {

        self.init(frame: frame)
        
        pickOption = data
        selectedIndex = defaultSelectedIndex
    
        //设置选择框的默认值
        pickerView.selectRow(defaultSelectedIndex, inComponent: 0, animated: true)
       
        //pickerView放在frame下方，showFrame才有view上升的效果
        //hideView=CGRect(x: 0.0, y: screenHeight, width: 0, height: 0); 效果：view从左下角出现
        pickerView.frame = hideFrame//maskView
        addSubview(pickerView)
        // 点击背景移除self
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(_:)))
        addGestureRecognizer(tap)
    
    }
    
    // MARK:- selector
  
    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        let location = tap.location(in: self)
        // 点击空白背景移除self
        if location.y <= screenHeight - pickerViewHeight {
            DoneOnClick?()
            self.hidePicker()
        }
    }
  

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
       // print("\(self.debugDescription) --- 销毁")
    }
    
    // MARK:- 弹出和移除self
    fileprivate func showPicker() {
        // 通过window 弹出view
        let window = UIApplication.shared.keyWindow
        guard let currentWindow = window else { return }
        currentWindow.addSubview(self)
            
        UIView.animate(withDuration: 0.5, animations: {[unowned self] in
            self.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.1)
            self.pickerView.frame = self.showFrame//popView
            }, completion: nil)
    }
        
    func hidePicker() {
        // 把self从window中移除
        UIView.animate(withDuration: 0.5, animations: { [unowned self] in
            self.backgroundColor = UIColor.clear
            self.pickerView.frame = self.hideFrame
            }, completion: {[unowned self] (_) in
                self.removeFromSuperview()
        })
    }
    
   
    //MARK:- back value
    public typealias BackValue = (_ selectedIndex: Int) -> Void
    
    fileprivate var selectedIndex: Int = 0
    private var DoneOnClick: (() -> Void)?
    
    fileprivate var doneAction: BackValue? = nil {
        didSet {
            DoneOnClick =  {[unowned self] in
                self.doneAction?(self.selectedIndex)
            }
        }
    }

    // MARK: -  快速使用方法
    public class func showPickerView(data: [String], defaultSelectedIndex: Int, backValue: BackValue?) {
        let window = UIApplication.shared.keyWindow
        guard let currentWindow = window else { return }
        let testView = MyPickerView(frame: currentWindow.bounds, data: data, defaultSelectedIndex: defaultSelectedIndex )
        testView.doneAction = backValue
        testView.showPicker()
    }
    

}



 
    



