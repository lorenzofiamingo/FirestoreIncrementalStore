//
//  NSFirebaseStore.swift
//  FirestoreIncrementalStore
//
//  Created by Lorenzo Fiamingo on 20/04/21.
//

import Foundation
import CoreData
import Firebase

let NSFirebaseStoreType: String = "Firebase"


class NSFirebaseStore: NSIncrementalStore {
    
    lazy private var firestore: Firestore = .firestore()
    
//    override class func initialize() {
//        NSPersistentStoreCoordinator.registerStoreClass(self, forStoreType: "FirestoreIncrementalStoreType")
//    }
    
    
    // MARK: - Setting Up an Incremental Store
    
    override func loadMetadata() throws {
        guard let storeURL = self.url else {
            throw NSFirebaseStoreError.noStoreURL
        }
        // ... metadata validation
        self.metadata = [
            NSStoreUUIDKey: UUID(),
            NSStoreTypeKey: NSFirebaseStoreType,
            // NSStoreModelVersionHashesKey: "",
        ]
    }
    
    override var type: String {
        NSFirebaseStoreType
    }
    
    // MARK: - Translating Between Custom Unique Identifiers and Managed Object IDs
    
//    override func newObjectID(for entity: NSEntityDescription, referenceObject data: Any) -> NSManagedObjectID {
//        <#code#>
//    }
    
//    override func referenceObject(for objectID: NSManagedObjectID) -> Any {
//        <#code#>
//    }
    
    // MARK: - Responding to Fetch Requests
    
    override func execute(_ request: NSPersistentStoreRequest, with context: NSManagedObjectContext?) throws -> Any {
        print(request.requestType)
        switch request {
        case let fetchRequest as NSFetchRequest<NSManagedObject>:
            return try execute(fetchRequest, with: context)
//        case let saveChangesRequest as NSSaveChangesRequest:
//            break
//        case let batchDeleteRequest as NSBatchDeleteRequest:
//            break
//        case let batchInsertRequest as NSBatchInsertRequest:
//            break
//        case let batchUpdateRequest as NSBatchUpdateRequest:
//            break
        default:
            fatalError()
        }
    }
    
    private func execute(_ request: NSFetchRequest<NSManagedObject>, with context: NSManagedObjectContext?) throws -> Any {
        guard let path = request.entity?.firestoreCollectionPath else { fatalError() }
        
        let dispatchGroup = DispatchGroup()
        var syncSnapshot: QuerySnapshot? = nil
        dispatchGroup.enter()
        let settings = FirestoreSettings()
        settings.dispatchQueue = DispatchQueue(label: "com.test.my-thread")
        firestore.settings = settings
        firestore.collection(path).getDocuments { snapshot, error in
            guard let snapshot = snapshot else { return }
            syncSnapshot = snapshot
            print("Async", syncSnapshot as Any)
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
        print("Sync", syncSnapshot as Any)
        return syncSnapshot!.documents.map { doc -> Item in
            let item = Item()
            item.timestamp = doc.data()["timestamp"] as? Date
            return item
        }
    }
    
    override func newValuesForObject(with objectID: NSManagedObjectID, with context: NSManagedObjectContext) throws -> NSIncrementalStoreNode {
        fatalError()
    }
    
    override func newValue(forRelationship relationship: NSRelationshipDescription, forObjectWith objectID: NSManagedObjectID, with context: NSManagedObjectContext?) throws -> Any {
        fatalError()
    }
    
    override func obtainPermanentIDs(for array: [NSManagedObject]) throws -> [NSManagedObjectID] {
        fatalError()
    }
    
    override class func identifierForNewStore(at storeURL: URL) -> Any {
        fatalError()
    }
    
    override func managedObjectContextDidRegisterObjects(with objectIDs: [NSManagedObjectID]) {
    }
    
    override func managedObjectContextDidUnregisterObjects(with objectIDs: [NSManagedObjectID]) {
    }
}

extension NSFirebaseStore {
    
    enum NSFirebaseStoreError: Error {
        case noStoreURL
    }
}

extension NSEntityDescription {
    
    var firestoreCollectionPath: String? {
        name
    }
}

