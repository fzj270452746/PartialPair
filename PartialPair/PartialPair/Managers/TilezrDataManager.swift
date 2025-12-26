//
//  TilezrDataManager.swift
//  PartialPair
//
//  Created by Zhao on 2025/12/21.
//

import Foundation
import CoreData
import UIKit

class TilezrDataManager {
    
    static let shared = TilezrDataManager()
    
    private init() {}
    
    // MARK: - Core Data Context
    
    var context: NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get AppDelegate")
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - Save Game Record
    
    func saveGameRecord(mode: Int, score: Int, rounds: Int, time: Double) {
        let record = TilezrGameRecord(context: context)
        record.gameMode = Int16(mode)
        record.finalScore = Int64(score)
        record.roundsCompleted = Int64(rounds)
        record.totalTime = time
        record.timestamp = Date()
        
        do {
            try context.save()
        } catch {
            print("Error saving game record: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetch Game Records
    
    func fetchAllRecords() -> [TilezrGameRecord] {
        let request: NSFetchRequest<TilezrGameRecord> = TilezrGameRecord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching records: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Delete Game Record
    
    func deleteRecord(_ record: TilezrGameRecord) {
        context.delete(record)
        
        do {
            try context.save()
        } catch {
            print("Error deleting record: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Delete All Records
    
    func deleteAllRecords() {
        let records = fetchAllRecords()
        records.forEach { context.delete($0) }
        
        do {
            try context.save()
        } catch {
            print("Error deleting all records: \(error.localizedDescription)")
        }
    }
    
}

