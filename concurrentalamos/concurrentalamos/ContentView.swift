//
//  ContentView.swift
//  nonoptimized
//
//  Created by Samuel Owino on 21/12/2024.
//
import SwiftUI
struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Welcome to Los Alamos (Concurrent)")
                Text("Isotopes Inventory Size => \(viewModel.storeSize)")
                NavigationLink(destination: DashbaordView()){
                    Text("See Isotopes Inventory")
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.burnIsotopes()
                        }
                    } label: {
                        Label("Burn Isotope Inventory", systemImage: "flame.circle")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.count()
            }
        }
    }
}
struct DashbaordView: View {
    @StateObject var viewModel = DashbaordViewModel()
    @State var isLoadingComplete: Bool = false
    var body: some View {
        VStack {
            HStack {
                Text("Isotopes Inventory")
                Spacer()
                NavigationLink(destination: IsotopesFormView()){
                    Label("Enrich Isotopes Store", systemImage: "plus")
                }
            }
            .padding()
            Divider()
            if isLoadingComplete == false {
                ProgressView("Loading Inventory...")
            }
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.isotopes){ isotope in
                        VStack {
                            HStack {
                                Text(isotope.name)
                                    .bold()
                                Spacer()
                            }
                            HStack {
                                Text("Mass # ")

                                    .bold()
                                Spacer()
                                Text("\(isotope.massNumber)")
                            }
                            HStack {
                                Text("Decay Model")
                                    .bold()
                                Spacer()
                                Text(isotope.decayMode)
                            }
                            HStack {
                                Text("Neutron Count")
                                    .bold()
                                Spacer()
                                Text("\(isotope.neutronCount)")
                            }
                        }
                        .padding()
                        .background {
                            if isotope.name == "Uranium-235" {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red.opacity(0.3))
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.3))
                            }
                        }
                        Divider()
                    }
                }
            }
            Spacer()
        }
        .padding()
        .onAppear {
            Task {
                await viewModel.loadIsotopes()
                self.isLoadingComplete.toggle()
            }
        }
    }
}
struct IsotopesFormView:View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = IsotopesFormViewModel()
    @State var uranium235: Bool = true
    @State var plutonium239: Bool = false
    @State var isotopesCount: String = "1"
    @State var isSavingIsotopes: Bool = false
    @State var toggleIsotopesAlert: Bool = false
    var body: some View {
        VStack {
            Text("Add to Isotopes Store")
            Form {
                Toggle("uranium-235", isOn: $uranium235)
                Toggle("plutonium-239", isOn: $plutonium239)
                HStack {
                    TextField("Amount in Millions", text: $isotopesCount)
                        .keyboardType(.numberPad)
                    Text("(in millions)")
                    Spacer()
                }
            }
            if isSavingIsotopes == true {
                ProgressView("Saving new isotopes...")
            }
            Button {
                isSavingIsotopes = true
                Task {
                    await viewModel.addIsotopes(isotope: uranium235 ? "Uranium-235" : "Plutonium-239", amountInMillions: 1)
                    self.isSavingIsotopes = false
                    self.toggleIsotopesAlert = true
                }
            } label: {
                Label("Submit New Isotopes", systemImage: "plus")
                    .padding()
            }
        }
        .alert("Finished saving Isotopes", isPresented: $toggleIsotopesAlert){
            Button("Got it!"){
                toggleIsotopesAlert = false
                dismiss()
            }
        }
    }
}
class IsotopesFormViewModel: ObservableObject {
    func addIsotopes(isotope: String, amountInMillions: Double) async {
        var newIsotopes: [IsotopeModel] = []
        for _ in 0..<Int(amountInMillions * 1_000_000){
            newIsotopes.append(IsotopeModel(
                id: UUID(),
                name: isotope,
                atomicNumber: Int.random(in: 235...239),
                neutronCount: Int.random(in: 100...Int.max),
                massNumber: Int.random(in: 100...Int.max),
                halfLife: TimeInterval.random(in: 5000...10_0000),
                decayMode: (Int.random(in: 0...1) == 1 ? "Mode1" : "Mode2"),
                isotopicAbundance: Double.random(in: 1000...10_000),
                stability: Int.random(in: 0...1)  == 1 ? "ST" : "UT")
            )
        }
        await IsotopeRespository.saveIsotopes(newIsotopes)
    }
}
@MainActor
class DashbaordViewModel: ObservableObject {
    @Published var isotopes: [IsotopeModel] = []
    func loadIsotopes() async {
        let isotopes = await IsotopeRespository.getIsotopes()
        DispatchQueue.main.async {
            self.isotopes.removeAll()
            self.isotopes.append(contentsOf: isotopes)
        }
    }
    func deleteAll() async {
        await IsotopeRespository.deleteAll()
    }
}
@MainActor
class ContentViewModel: ObservableObject {
    @Published var storeSize: Int = 0
    func burnIsotopes() async {
        await IsotopeRespository.deleteAll()
    }
    func count() async {
        let count = await IsotopeRespository.countIsotopes()
        DispatchQueue.main.async {
            self.storeSize = count
        }
    }
}
struct IsotopeModel: Identifiable{
    var id:UUID = UUID()
    var name: String = ""
    var atomicNumber: Int = 0
    var neutronCount: Int = 0
    var massNumber: Int = 0
    var halfLife: TimeInterval = 1000
    var decayMode: String = ""
    var isotopicAbundance: Double = 0.0
    var stability: String
    init(id: UUID, name: String, atomicNumber: Int, neutronCount: Int, massNumber: Int, halfLife: TimeInterval, decayMode: String, isotopicAbundance: Double, stability: String) {
        self.id = id
        self.name = name
        self.atomicNumber = atomicNumber
        self.neutronCount = neutronCount
        self.massNumber = massNumber
        self.halfLife = halfLife
        self.decayMode = decayMode
        self.isotopicAbundance = isotopicAbundance
        self.stability = stability
    }
    func toEntity() -> IsotopeEntity {
        let entity = IsotopeEntity()
        entity.name = self.name
        entity.atomicNumber = self.atomicNumber
        entity.neutronCount = self.neutronCount
        entity.massNumber = self.massNumber
        entity.halfLife = self.halfLife
        entity.decayMode = self.decayMode
        entity.isotopicAbundance = self.isotopicAbundance
        entity.stability = self.stability
        return entity
    }
}

#Preview {
    ContentView()
}
