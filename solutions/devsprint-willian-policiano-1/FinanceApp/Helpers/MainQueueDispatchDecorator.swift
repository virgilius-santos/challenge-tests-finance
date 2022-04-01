//
//  MainQueueDispatchDecorator.swift
//  FinanceApp
//
//  Created by Willian Policiano on 01/04/22.
//

import Foundation

class MainQueueDispatchDecorator<Decoratee> {
    let decoratee: Decoratee

    init(decoratee: Decoratee) {
        self.decoratee = decoratee
    }
}

extension DispatchQueue {
    static func dispatchOnMainIfNeeded(execute: @escaping () -> Void) {
        if Thread.isMainThread {
            execute()
        } else {
            DispatchQueue.main.async {
                execute()
            }
        }
    }
}
