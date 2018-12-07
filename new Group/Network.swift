//
//  Network.swift
//  iou-swift
//
//  Created by 李书康 on 2018/12/6.
//  Copyright © 2018 com.li.www. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import SwiftyJSON
import SVProgressHUD

/// 超时时长
private var requestTimeOut:Double = 30
///endpointClosure
private let myEndpointClosure = { (target: API) -> Endpoint in
    ///这里的endpointClosure和网上其他实现有些不太一样。
    ///主要是为了解决URL带有？无法请求正确的链接地址的bug
    let url = target.baseURL.absoluteString + target.path
    var endpoint = Endpoint(
        url: url,
        sampleResponseClosure: { .networkResponse(200, target.sampleData) },
        method: target.method,
        task: target.task,
        httpHeaderFields: target.headers
    )
    switch target {
    case .getMe:
        requestTimeOut = 10
        return endpoint
    default:
        requestTimeOut = 30//设置默认的超时时长
        return endpoint
    }
}

private let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
    do {
        var request = try endpoint.urlRequest()
        //设置请求时长
        request.timeoutInterval = requestTimeOut
        // 打印请求参数
        if let requestData = request.httpBody {
            print("url \(request.url!)"+"\n"+"请求方式 "+"\(request.httpMethod ?? "")"+"\n"+"参数 "+"\(String(data: request.httpBody!, encoding: String.Encoding.utf8) ?? "")")
        }else{
            print("\(request.url!)"+"\(String(describing: request.httpMethod))")
        }
        done(.success(request))
    } catch {
        done(.failure(MoyaError.underlying(error, nil)))
    }
}

/*   设置ssl
 let policies: [String: ServerTrustPolicy] = [
 "example.com": .pinPublicKeys(
 publicKeys: ServerTrustPolicy.publicKeysInBundle(),
 validateCertificateChain: true,
 validateHost: true
 )
 ]
 */

// 用Moya默认的Manager还是Alamofire的Manager看实际需求。HTTPS就要手动实现Manager了
public func defaultAlamofireManager() -> Manager {

    let configuration = URLSessionConfiguration.default

    configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders

    let policies: [String: ServerTrustPolicy] = [
        "ap.grtstar.cn": .disableEvaluation
    ]
    let manager = Alamofire.SessionManager(configuration: configuration,serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies))

    manager.startRequestsImmediately = false

    return manager
}


/// NetworkActivityPlugin插件用来监听网络请求
private let networkPlugin = NetworkActivityPlugin.init { (changeType, targetType) in
    
    //print("networkPlugin \(changeType)")
    //targetType 是当前请求的基本信息
    switch(changeType){
    case .began:
        //print("开始请求网络")
        SVProgressHUD.show()
        break
        
    case .ended:
        //print("结束")
        SVProgressHUD.dismiss()
        break
    }
}

// https://github.com/Moya/Moya/blob/master/docs/Providers.md  参数使用说明
//stubClosure   用来延时发送网络请求

let Provider = MoyaProvider<API>(endpointClosure: myEndpointClosure, requestClosure: requestClosure, plugins: [networkPlugin], trackInflights: false)

//先添加一个闭包用于成功时后台返回数据的回调
typealias successCallback = ((String) -> (Void))
//再次用一个方法封装provider.request()
func NetWorkRequest(_ target: API, completion: @escaping successCallback ){
    //先判断网络是否有链接 没有的话直接返回--代码略
    
    //显示hud
    Provider.request(target) { (result) in
        //隐藏hud
        switch result {
        case let .success(response):
            do {
                switch target {
                case .loginMobile:
                    print(response.response?.allHeaderFields["x-user-token"] as! String)
                    setLocal(key: .token, value: response.response?.allHeaderFields["x-user-token"] as? String ?? "")
                default:
                    //这里转JSON用的swiftyJSON框架
                    let jsonData = try JSON(data: response.data)
                    
                    //判断后台返回是否有问题
                    if jsonData["payload"] == JSON.init(NSNull()) {
                        print("请求失败: \(jsonData["error"].stringValue)")
                    } else {
                        completion(String(data: response.data, encoding: String.Encoding.utf8)!)
                    }
                }
            } catch {
            }
        case let .failure(error):
            print(error)
//            guard (error as? CustomStringConvertible) != nil else {
//                //网络连接失败，提示用户
//                print("网络连接失败")
//                break
//            }
        }
    }
}


typealias successCallback2 = ((JSON) -> (Void))
//增加了错误回调
typealias failureCallback = ((String) -> (Void))

func NetWorkRequest2(_ target: API, completion: @escaping successCallback2, failure: @escaping failureCallback){
    //先判断网络是否有链接 没有的话直接返回--代码略
    
    //显示hud
    Provider.request(target) { (result) in
        //隐藏hud
        switch result {
        case let .success(response):
            do {
                switch target {
                case .loginMobile:
                    print(response.response?.allHeaderFields["x-user-token"] as! String)
                    setLocal(key: .token, value: response.response?.allHeaderFields["x-user-token"] as! String)
                default:
                    //这里转JSON用的swiftyJSON框架
                    let jsonData = try JSON(data: response.data)
                    
                    //判断后台返回是否有问题
                    if jsonData["payload"] == JSON.init(NSNull()) {
                        failure(jsonData["error"].stringValue)
                    } else {
                        completion(jsonData["payload"])
                    }
                }
            } catch {
            }
        case let .failure(error):
            print(error)
            //            guard (error as? CustomStringConvertible) != nil else {
            //                //网络连接失败，提示用户
            //                print("网络连接失败")
            //                break
            //            }
        }
    }
}
