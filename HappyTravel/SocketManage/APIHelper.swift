//
//  APIHelper.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 17/1/9.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import Foundation

class APIHelper {
    
    private static var _userAPI = UserAPI()
    class func userAPI() -> UserAPI {
        return _userAPI
    }
    
    private static var _commonAPI = CommonAPI()
    class func commonAPI() -> CommonAPI {
        return _commonAPI
    }
    
    private static var _consumeAPI = ConsumeSocketAPI()
    class func consumeAPI() -> ConsumeSocketAPI {
        return _consumeAPI
    }

    private static var _servantAPI = ServantAPI()
    class func servantAPI() -> ServantAPI {
        return _servantAPI
    }
    
    private static var _followAPI = FollowAPI()
    class func followAPI() -> FollowAPI {
        return _followAPI
    }
}
