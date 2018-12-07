//
//  DataModel.swift
//  iou-swift
//
//  Created by 李书康 on 2018/12/6.
//  Copyright © 2018 com.li.www. All rights reserved.
//

import Foundation
import HandyJSON


extension Array: HandyJSON{}

struct ReturnData<T: HandyJSON>: HandyJSON {
    var error : String?
    var payload : T?
    var requestId : String?
}

struct ResponseData<T: HandyJSON>: HandyJSON {
    var code: Int = 0
    var data: ReturnData<T>?
}
