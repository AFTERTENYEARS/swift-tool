//
//  UFresh.swift
//  iou-swift
//
//  Created by 李书康 on 2018/12/10.
//  Copyright © 2018 com.li.www. All rights reserved.
//

import Foundation
import MJRefresh

extension UIScrollView {
    var uHead: MJRefreshHeader {
        get { return mj_header }
        set { mj_header = newValue }
    }
    
    var uFoot: MJRefreshFooter {
        get { return mj_footer }
        set { mj_footer = newValue }
    }
}

class URefreshHeader: MJRefreshGifHeader {
    override func prepare() {
        super.prepare()
        setImages([UIImage(named: "refresh")!], for: .idle)
        setImages([UIImage(named: "refresh")!], for: .pulling)
        setImages([UIImage(named: "refresh")!,
                   UIImage(named: "refresh")!,
                   UIImage(named: "refresh")!], for: .refreshing)
        
        lastUpdatedTimeLabel.isHidden = true
        stateLabel.isHidden = true
    }
}

class URefreshAutoHeader: MJRefreshHeader {}

class URefreshFooter: MJRefreshBackNormalFooter {}

class URefreshAutoFooter: MJRefreshAutoFooter {}


class URefreshDiscoverFooter: MJRefreshBackGifFooter {
    
    override func prepare() {
        super.prepare()
        backgroundColor = UIColor.init(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1)
        setImages([UIImage(named: "refresh")!], for: .idle)
        stateLabel.isHidden = true
        refreshingBlock = { self.endRefreshing() }
    }
}

class URefreshTipKissFooter: MJRefreshBackFooter {
    
    lazy var tipLabel: UILabel = {
        let tl = UILabel()
        tl.textAlignment = .center
        tl.textColor = UIColor.lightGray
        tl.font = UIFont.systemFont(ofSize: 14)
        tl.numberOfLines = 0
        return tl
    }()
    
    lazy var imageView: UIImageView = {
        let iw = UIImageView()
        iw.image = UIImage(named: "refresh")
        return iw
    }()
    
    override func prepare() {
        super.prepare()
        backgroundColor = UIColor.init(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1)
        mj_h = 240
        addSubview(tipLabel)
        addSubview(imageView)
    }
    
    override func placeSubviews() {
        tipLabel.frame = CGRect(x: 0, y: 40, width: bounds.width, height: 60)
        imageView.frame = CGRect(x: (bounds.width - 80 ) / 2, y: 110, width: 80, height: 80)
    }
    
    convenience init(with tip: String) {
        self.init()
        refreshingBlock = { self.endRefreshing() }
        tipLabel.text = tip
    }
}
