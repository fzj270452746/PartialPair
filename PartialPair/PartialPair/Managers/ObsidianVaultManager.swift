//
//  ObsidianVaultManager.swift
//  PartialPair
//
//  Created by Zhao on 2025/12/21.
//

import Foundation
import CoreData
import UIKit

class ObsidianVaultManager {

    static let shared = ObsidianVaultManager()

    private init() {}

    // MARK: - Core Data Context

    var vaultContext: NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get AppDelegate")
        }
        return appDelegate.persistentContainer.viewContext
    }

    // MARK: - Save Game Record

    func saveVaultRecord(mode: Int, score: Int, rounds: Int, time: Double) {
        let record = ObsidianVaultRecord(context: vaultContext)
        record.gameMode = Int16(mode)
        record.finalScore = Int64(score)
        record.roundsCompleted = Int64(rounds)
        record.totalTime = time
        record.timestamp = Date()

        do {
            try vaultContext.save()
        } catch {
            print("Error saving game record: \(error.localizedDescription)")
        }
    }

    // MARK: - Fetch Game Records

    func fetchAllVaultRecords() -> [ObsidianVaultRecord] {
        let request: NSFetchRequest<ObsidianVaultRecord> = ObsidianVaultRecord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        do {
            return try vaultContext.fetch(request)
        } catch {
            print("Error fetching records: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Delete Game Record

    func deleteVaultRecord(_ record: ObsidianVaultRecord) {
        vaultContext.delete(record)

        do {
            try vaultContext.save()
        } catch {
            print("Error deleting record: \(error.localizedDescription)")
        }
    }

    // MARK: - Delete All Records

    func deleteAllVaultRecords() {
        let records = fetchAllVaultRecords()
        records.forEach { vaultContext.delete($0) }

        do {
            try vaultContext.save()
        } catch {
            print("Error deleting all records: \(error.localizedDescription)")
        }
    }

}

