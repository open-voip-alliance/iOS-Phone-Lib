//
//  LogDelegate.swift
//  PIL
//
//  Created by Jeremy Norman on 18/03/2021.
//

import Foundation

public protocol LogDelegate {
    func onLogReceived(message: String, level: LogLevel)
}
