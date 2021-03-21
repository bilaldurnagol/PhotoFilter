//
//  RxArray.swift
//  PhotoFilter
//
//  Created by Bilal Durnagöl on 5.03.2021.
//
import UIKit
import RxSwift
import RxCocoa
import Photos

 class StorageManager {
    static let shared = StorageManager()
    
    private let storage: BehaviorRelay<[PHAsset]>
    private let lock = NSRecursiveLock()
    
    var items: Observable<[PHAsset]> {
        return storage.asObservable()
    }
    
    var count: Observable<Int> {
        return storage.map { $0.count }
    }
    var lastItem: Observable<PHAsset?> {
        return storage.map({$0.last})
    }
    
    init(elements: [PHAsset] = []) {
        storage = BehaviorRelay(value: elements)
    }
    
    func append(_ element: PHAsset) {
        lock.lock(); defer { lock.unlock() }
        storage.accept(storage.value + [element])
    }
    
    func removeFirst(_ element: PHAsset) {
        lock.lock(); defer { lock.unlock() }
        
        var items = storage.value
        guard let idx = items.firstIndex(of: element) else { return }
        
        items.remove(at: idx)
        storage.accept(items)
    }
    
    func removeAll() {
        lock.lock(); defer { lock.unlock() }
        var items = storage.value
        items.removeAll()
        storage.accept(items)
    }
}
