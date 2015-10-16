//
//  DataService.swift
//  JMFShowcase
//
//  Created by Justin Ferre on 10/16/15.
//  Copyright © 2015 Justin Ferre. All rights reserved.
//

import Foundation
import Firebase


class DataService {

    static let ds = DataService()
    
    private var _REF_BASE = Firebase(url: "https://jmfshowcase.firebaseio.com")
    
    var REF_BASE: Firebase {
        return _REF_BASE
    }
    
    
    
}