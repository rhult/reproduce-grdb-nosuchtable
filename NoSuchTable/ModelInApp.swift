//
//  TestModel.swift
//  NoSuchTable
//
//  Created by Richard Hult on 2022-12-07.
//

import Foundation
import GRDB

struct ModelInApp: Codable, Identifiable {
    static var databaseTableName: String = "testModel"
    let id: String
}
extension ModelInApp: FetchableRecord, TableRecord, PersistableRecord { }

func saveModelInApp(_ db: Database) throws {
    let model = ModelInApp(id: "id")
    try model.save(db)
}

func writeModelInApp(database: DatabaseWriter) throws {
    try database.write { db in
        try saveModelInApp(db)
    }
}

func createDatabaseInApp() throws -> DatabaseWriter {
    let database: DatabaseWriter
    let path = documentsURL().appendingPathComponent(UUID().uuidString).path
    database = try DatabasePool(path: path)

    return database
}

func documentsURL() -> URL {
    let paths = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    )
    return paths[0]
}

let v1 = """
CREATE TABLE IF NOT EXISTS testModel (
id TEXT NOT NULL,
PRIMARY KEY (id) ON CONFLICT FAIL
);
"""

func migrateInApp(database: DatabaseWriter) throws {
    var migrator = DatabaseMigrator()

    migrator.registerMigration("v1") { db in
        try db.execute(sql: v1)
    }

    try migrator.migrate(database)
}
