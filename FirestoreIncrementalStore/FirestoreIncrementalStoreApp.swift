//
//  FirestoreIncrementalStoreApp.swift
//  FirestoreIncrementalStore
//
//  Created by Lorenzo Fiamingo on 15/04/21.
//

import SwiftUI
import Firebase
import CoreData

@main
struct FirestoreIncrementalStoreApp: App {
    let persistenceController: PersistenceController = .shared
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    @State private var text: String = "Ciao"
    
    var body: some Scene {
        WindowGroup {
//            VStack {
//                Text(text).onAppear {
//                    Firestore.firestore().collection("Item").getDocuments { snap, _ in
//                        print(snap)
//                    }
//                }
//            }
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}


class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        

        return true
    }
}
