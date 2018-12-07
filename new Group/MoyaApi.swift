//
//  MoyaApi.swift
//  iou-swift
//
//  Created by 李书康 on 2018/12/6.
//  Copyright © 2018 com.li.www. All rights reserved.
//

import Foundation
import Moya

enum API {
    case verificationCodeForLogin(mobile: String, usageType: String)
    case loginMobile(mobile: String, verificationCode: String, imei: String)
    case getMe
    case page(offset: Int, limit: Int)
    
    case pathDefault
}

extension API:TargetType{
    
    //baseURL 也可以用枚举来区分不同的baseURL，不过一般也只有一个BaseURL
    var baseURL: URL {
        return URL.init(string: "https://wx.iousave.com")!
    }
    //不同接口的路径字段
    var path: String {
        switch self {
        case .verificationCodeForLogin:
            return "/api/common/verificationCode"
        case .loginMobile:
            return "/api/auth/signin/mobile"
        case .getMe:
            return "/api/users/me"
        case .page(let offset, let limit):
            return "/page/\(offset)/\(limit)"
        default:
            return "pathDefault"
        }
    }
    
    // 请求方式 get post put delete
    var method: Moya.Method {
        switch self {
        case .verificationCodeForLogin:
            return .post
        case .loginMobile:
            return .post
        case .getMe:
            return .get
        default:
            return .get
        }
    }
    
    /// 这个是做单元测试模拟的数据，必须要实现，只在单元测试文件中有作用
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    /// 这个就是API里面的核心。嗯。。至少我认为是核心，因为我就被这个坑过
    //类似理解为AFN里的URLRequest
    var task: Task {
        switch self {
        case .verificationCodeForLogin(let mobile, let usageType):
            return .requestParameters(parameters: ["mobile" : mobile, "usageType" : usageType], encoding: URLEncoding.default)
        case .loginMobile(let mobile, let verificationCode, let imei):
            return .requestParameters(parameters: ["mobile" : mobile, "verificationCode" : verificationCode, "imei" : imei], encoding: URLEncoding.default)
        case .getMe:
            return .requestPlain
        default:
            return .requestPlain
        }
    }
    
    /// 设置请求头header
    var headers: [String : String]? {
        //同task，具体选择看后台 有application/x-www-form-urlencoded 、application/json
        return ["Content-Type":"application/x-www-form-urlencoded",
                "x-user-client":"IOS",
                "authorization":"Bearer \(getLocal(key: .token))"]
        
        /*
         如果接口返回的http状态码为401时，则表示token失效，客户端应直接跳转到登陆页面
         所有的请求header中都需要添加：x-user-client，微信(WECHAT) 安卓(ANDROID) 苹果(IOS)
         所有的需要权限的接口请求header中都需要添加：authorization: Bearer + ' ' + 登录时获取的token
         以下所有的password都需要先md5再传回服务器端
         出借日期，还款日期，展期日期的比较都只比较年月日部分
         */
    }
}


