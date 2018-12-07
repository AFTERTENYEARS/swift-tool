//
//  LocalData.swift
//  iou-swift
//
//  Created by 李书康 on 2018/12/6.
//  Copyright © 2018 com.li.www. All rights reserved.
//

import Foundation

func getLocal(key: local) -> String {
    return UserDefaults.standard.object(forKey: getKey(key: key)) as? String ?? ""
}

func setLocal(key: local, value: Any) {
    UserDefaults.standard.set(value, forKey: getKey(key: key))
}

enum local {
    case token
    case user
}

private func getKey(key: local) -> String {
    switch key {
    case .token:
        return "token"
    default:
        return ""
    }
}


