//
//  BBNewsDetailController.swift
//  BBAccountantTool
//
//  Created by Bonway on 2018/7/17.
//  Copyright © 2018年 Bonway. All rights reserved.
//

import UIKit

class BBNewsDetailController: BBGestureBaseController {

    let cellOneID = "newsChildOnePicCell"
    let cellMoreID = "newsChildMorePicCell"
    var aid : String!
    var model: BBNewsDetailModel?
    var headerView = BBNewsDetailHeaderView()
    
    private lazy var navitionView : UIView = {
        let navitionView = UIView(frame: CGRect(x: 0, y: 0, width: bbScreenWidth, height: bbNavBarHeight))
        navitionView.backgroundColor = UIColor.white
        
        let leftBtn = UIButton(frame: CGRect(x: 2, y: bbNavBarHeight - 2 - 40, width: 40, height: 40))
        leftBtn.setImage(UIImage(named: "navigation_news_back"), for: .normal)
        leftBtn.addTarget(self, action: #selector(backClick), for: .touchUpInside)
        navitionView.addSubview(leftBtn)
        
        let menuBtn = UIButton(frame: CGRect(x: bbScreenWidth - 40 - 5, y: bbNavBarHeight - 2 - 40, width: 40, height: 40))
        menuBtn.setImage(UIImage(named: "navigation_news_menu"), for: .normal)
        menuBtn.addTarget(self, action: #selector(menuClick), for: .touchUpInside)
        navitionView.addSubview(menuBtn)
        
        return navitionView
    }()
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: bbNavBarHeight, width: bbScreenWidth, height: bbScreenHeight))
        tableView.register(UINib.init(nibName: "BBNewsChildOnePicCell", bundle: nil), forCellReuseIdentifier: cellOneID)
        tableView.register(UINib.init(nibName: "BBNewsChildMorePicCell", bundle: nil), forCellReuseIdentifier: cellMoreID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = BBColor(rgbValue: 0xF6F6F6)
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = 140
        return tableView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        UIApplication.shared.statusBarStyle = .default
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        UIApplication.shared.statusBarStyle = .lightContent
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupView()
//        loadDatas()
    }

    private func setupNavigation() {
        view.addSubview(navitionView)
        
        
    }
    
    private func setupView() {
        view.addSubview(tableView)
    }
    
    private func loadDatas() {

        BBNetworkTool.loadData(API: NewsIndexType.self, target: .article(aid: aid, token: aid.tokenString), cache: true , success: { (json)in
            let decoder = JSONDecoder()
            let model = try? decoder.decode(BBNewsDetailModel.self, from: json)
            self.model = model
            self.headerView.model = self.model
            self.headerView.frame = CGRect(x: 0, y: 0, width: bbScreenWidth, height: 0)
            self.headerView.delegate = self
            self.tableView.reloadData()
            
        }) { (error_code, message) in
            self.addBlankView(blankType: .requestFailed)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
// MARK: - Action
extension BBNewsDetailController {
    @objc private func backClick() {
        navigationController?.popViewController(animated: true)
    }
    @objc private func menuClick() {
        let v = BBShareView.shareView(shareType: .three)
        v.show {(clsName) in
            
            if clsName! == "微信" {
                self.share(type: .typeWechat)
            }
            
            if clsName! == "朋友圈" {
                self.share(type: .subTypeWechatTimeline)
            }
            
            
            if clsName! == "复制链接" {
                self.pasteBoard(str: "self.urlString")
            }
            
            
            
            v.removeFromSuperview()
        }
    }
    
    private func share(type:SSDKPlatformType){
        // 1.创建分享参数
        let shareParames = NSMutableDictionary()
        shareParames.ssdkSetupShareParams(byText: "shareDscription",
                                          images : "iconurl",
                                          url : NSURL(string:"urlString") as URL?,
                                          title : "shareTitle",
                                          type : .auto)
        
        //2.进行分享
        ShareSDK.share(type, parameters: shareParames) { (state : SSDKResponseState, nil, entity : SSDKContentEntity?, error :Error?) in
            
            switch state{
                
            case SSDKResponseState.success:  MBProgressHUD.showTitle("分享成功", to: self.view)
            case SSDKResponseState.fail:    MBProgressHUD.showTitle("授权失败,错误描述:\(String(describing: error))",to: self.view)
            case SSDKResponseState.cancel:  MBProgressHUD.showTitle("操作取消",to: self.view)
                
            default:
                break
            }
            
        }
    }
    
    private func pasteBoard(str:String) {
        //就这两句话就实现了
        let paste = UIPasteboard.general
        paste.string = str
        MBProgressHUD.showTitle("链接已复制", to: view)
    }
}


// MARK: - UITableViewDataSource
extension BBNewsDetailController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = model?.likearticle.count ?? 0
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let count = model?.likearticle[indexPath.row].imgList.list.count ?? 0
        if count > 1 {
            let moreCell = tableView.dequeueReusableCell(withIdentifier: cellMoreID) as! BBNewsChildMorePicCell
            moreCell.cellModel = model?.likearticle[indexPath.row]
            return moreCell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: cellOneID) as! BBNewsChildOnePicCell
        cell.cellModel = model?.likearticle[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let count = model?.likearticle[indexPath.row].imgList.list.count ?? 0
        if count > 1 {
            return UITableViewAutomaticDimension
        }
        return 140
    }
}

// MARK: - UITableViewDelegate
extension BBNewsDetailController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.headerView.height = self.headerView.headerHeight
    }

}

// MARK: - UITableViewDelegate
extension BBNewsDetailController: BBNewsDetailHeaderViewDelegate {
    func headerHeight(height: CGFloat) {
        
        self.headerView.height = height
        self.tableView.tableHeaderView = self.headerView
    }
}
    
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.headerView.height = self.headerView.headerHeight
//    }
    

