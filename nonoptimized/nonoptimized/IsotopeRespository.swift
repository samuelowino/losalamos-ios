//
//  IsotopeRespository.swift
//  nonoptimized
//
//  Created by Samuel Owino on 21/12/2024.
//
import Foundation
import RealmSwift
struct IsotopeRespository {
    static func countIsotopes(then: @escaping(Int) -> ()) {
        guard let database = BaseRepository.getDatabase() else { then(0);return }
        let result: Int = database.objects(IsotopeEntity.self).count
        then(result)
    }
    static func getIsotopes(then: @escaping([IsotopeModel]) -> ()) {
        guard let database = BaseRepository.getDatabase() else { then([]);return }
        var result: [IsotopeModel] = database.objects(IsotopeEntity.self)
            .map { IsotopeModel(
                id: $0.id,
                name: $0.name,
                atomicNumber: $0.atomicNumber,
                neutronCount: $0.neutronCount,
                massNumber: $0.massNumber,
                halfLife: $0.halfLife,
                decayMode: $0.decayMode,
                isotopicAbundance: $0.isotopicAbundance,
                stability: $0.stability
            )}
        print("getIsotopes : \(result.count)")
        result.sort {$0.massNumber > $1.massNumber}
        then(result)
    }
    static func saveIsotopes(_ isotopes: [IsotopeModel], then: @escaping() -> ()) {
        print("saveIsotopes : \(isotopes.count)")
        guard let database = BaseRepository.getDatabase() else { then();return }
        do {
            try database.write {
                let entities: [IsotopeEntity] = isotopes.map { $0.toEntity()}
                database.add(entities)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    static func deleteAll(){
        do {
            guard let database = BaseRepository.getDatabase() else { return }
            try database.write {
                database.objects(IsotopeEntity.self)
                    .forEach { database.delete($0)}
            }
        } catch {
            print("Error in  delete \(error.localizedDescription)")
        }
    }
}
struct BaseRepository {
    static func getDatabase() -> Realm? {
        do {
            let databaseConfig = IsotopeDatabaseConfig()
            return try databaseConfig.getDatabase()
        } catch {
            return nil
        }
    }
}
class IsotopeEntity: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var name: String
    @Persisted var decayMode: String
    @Persisted var stability: String
    @Persisted var atomicNumber: Int
    @Persisted var neutronCount: Int
    @Persisted var massNumber: Int
    @Persisted var halfLife: TimeInterval
    @Persisted var atomicWeight: Double
    @Persisted var isotopicAbundance: Double
    @Persisted var group: Int
    @Persisted var period: Int
    @Persisted var isodescription: String
    @Persisted var imageURL: String
}
class IsotopeDatabaseConfig{
    init(){}
    func getDatabase() throws -> Realm {
        var database: Realm
        let configuration = Realm.Configuration(schemaVersion: 1,
                                                migrationBlock: nil,
                                                deleteRealmIfMigrationNeeded: false)
        Realm.Configuration.defaultConfiguration = configuration
        database = try Realm()
        print(database.configuration.fileURL!.path)
        return database
    }
}
