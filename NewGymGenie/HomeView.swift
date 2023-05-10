//
//  HomeView.swift
//  GymGenie
//
//  Created by Jake Meissner on 4/3/23.
//

// HomeView.swift
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import HealthKit
import SwiftUICharts

struct HomeView: View {
    @State private var totalCaloriesBurned: Double = 0
    @EnvironmentObject var workoutData: WorkoutData
    @State private var recentWorkoutsToShow: Int = 4
    @State private var dailyCaloriesBurnedData: [(String, Double)] = [] // Updated
    @State private var dailyCaloriesBurnedDates: [String] = []
    @State private var sleepData: [HKSample] = []
    @State private var sleepHoursData: [(String, Double)] = [] // Updated
    
    private let grid = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("This Week's Accomplishments")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    // Other content
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 15)
                
                VStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Recent Exercise Data")
                                .font(.title3)
                                .foregroundColor(.black)
                                .padding(.top, 15)
                                .padding(.bottom, 3)
                            Spacer()
                        }
                        .padding(.bottom, 5)
                        
                        LazyVGrid(columns: grid, spacing: 10) {
                            ForEach(workoutData.recentWorkouts.prefix(recentWorkoutsToShow), id: \.id) { workout in
                                NavigationLink(destination: WorkoutDescriptionView(workoutName: workout.workoutName, documentId: workout.id)) {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(workout.formattedDate)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        
                                        HStack {
                                            Text(workout.workoutName)
                                                .font(.body)
                                            Spacer()
                                            VStack(alignment: .leading) {
                                                Text("\(workout.sets) sets")
                                                    .font(.body)
                                                Text("\(workout.weight) lbs")
                                                    .font(.body)
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGroupedBackground))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(LinearGradient(gradient: Gradient(colors: [color1, color3]), startPoint: .top, endPoint: .bottom), lineWidth: 2)
                                )
                                .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 4)
                            }
                        }

                        
                        Button(action: {
                            recentWorkoutsToShow = recentWorkoutsToShow == 4 ? workoutData.recentWorkouts.count : 4
                        }) {
                            Text(recentWorkoutsToShow == 4 ? "View All" : "Show Less")
                                .font(.headline)
                                .foregroundColor(color1)
                                .padding(.top, 10)
                        }
                    }
                    .padding(.horizontal)
                }
                
                VStack(alignment: .leading) {
                    Text("Average Calories Burned per Day")
                        .font(Font.custom("Poppins-Regular", size:18))
                        .foregroundColor(color1)
                    let averageCaloriesBurned = totalCaloriesBurned / Double(dailyCaloriesBurnedData.count)
                    Text("\(averageCaloriesBurned, specifier: "%.0f") cal")
                        .font(Font.custom("Poppins-Regular", size:14))
                        .fontWeight(.bold)
                }
                .padding(.horizontal)
                .padding(.top, 30)
                .frame(height: 100)
                VStack(alignment: .leading) {
                    Text("Calories Burned per Day")
                        .font(Font.custom("Poppins-Regular", size:18))
                        .foregroundColor(color1)
                        .padding(.top, 15)
                    LineView(data: ChartData(points: dailyCaloriesBurnedData).points.map { $0.1 },
                             title: "c",
                             legend: "calories",
                             style: lineChartStyle(),
                             valueSpecifier: "%.0f")
                        .id(UUID())
                        .padding(.horizontal, 5)
                        .padding(.top, 3)
                        .padding(.bottom, 320) // Adjust this value to change the spacing
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 30) {
                            ForEach(dailyCaloriesBurnedDates, id: \.self) { date in
                                Text(date)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 50) // Adjust this value to change the spacing
                    }
                    .padding(.bottom, 100)
                }
                Section(header: Text("Sleep Hours in Last 7 Days").font(.title3).foregroundColor(.black).padding(.top, 15).padding(.bottom, 3)) {
                    VStack(alignment: .leading) {
                        BarChartView(data: ChartData(values: sleepHoursData),
                                     title: "",
                                     style: barChartStyle(),
                                     cornerImage: Image(systemName: "hourglass"),
                                     valueSpecifier: "%.1f")
                            .padding(.horizontal, 5)
                            .padding(.top, 3)
                            .padding(.bottom, 40) // Adjust this value to change the spacing

                        ForEach(sleepData, id: \.uuid) { sleepSample in
                            if let sleepSample = sleepSample as? HKCategorySample,
                               let value = HKCategoryValueSleepAnalysis(rawValue: sleepSample.value) {
                                Text("\(value == .asleepUnspecified ? "Asleep" : "InBed"): \(sleepSample.startDate) - \(sleepSample.endDate)")
                                    .padding(.bottom, 2)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            workoutData.fetchRecentWorkouts()
            requestHealthKitPermissions()
            fetchCaloriesBurned { caloriesBurned in
                totalCaloriesBurned = caloriesBurned
            }
            fetchDailyCaloriesBurned { dailyCaloriesData in
                dailyCaloriesBurnedData = dailyCaloriesData
            }
            fetchSleepData { fetchedSleepData in
                sleepData = fetchedSleepData
                self.sleepHoursData = parseSleepDataForChart(samples: fetchedSleepData).points
            }
        }
        .padding(.bottom, 120)
    }

    func fetchCaloriesBurned(completion: @escaping (Double) -> Void) {
        let healthStore = HKHealthStore()
        let caloriesBurnedType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: caloriesBurnedType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if let error = error {
                print("Error fetching calories burned: \(error.localizedDescription)")
                completion(0)
            } else {
                let totalCaloriesBurned = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie())
                completion(totalCaloriesBurned ?? 0)
                print("Total calories burned: \(totalCaloriesBurned ?? 0)")
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchDailyCaloriesBurned(completion: @escaping ([(String, Double)]) -> Void) { // Updated
        let healthStore = HKHealthStore()
        let caloriesBurnedType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsCollectionQuery(quantityType: caloriesBurnedType, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: startDate, intervalComponents: DateComponents(day: 1))
        
        query.initialResultsHandler = { query, results, error in
            if let error = error {
                print("Error fetching daily calories burned: \(error.localizedDescription)")
                completion([])
            } else {
                let dailyStatistics = results!.statistics()
                
                let chartDataPoints: [(String, Double)] = dailyStatistics.map { stat -> (String, Double) in // Updated
                    let value = stat.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
                    let formattedDate = DateFormatter.localizedString(from: stat.startDate, dateStyle: .short, timeStyle: .none)
                    return (formattedDate, value)
                }
                
                dailyCaloriesBurnedDates = dailyStatistics.map { stat -> String in
                    DateFormatter.localizedString(from: stat.startDate, dateStyle: .short, timeStyle: .none)
                }
                
                completion(chartDataPoints)
                print("Daily calories burned data points: \(chartDataPoints)")
                print("Daily calories burned dates: \(dailyCaloriesBurnedDates)")
            }
        }
        healthStore.execute(query)
    }

    func requestHealthKitPermissions() {
        let healthStore = HKHealthStore()
        let allTypes = Set([
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ])

        healthStore.requestAuthorization(toShare: nil, read: allTypes) { (success, error) in
            if !success {
                print("Error requesting authorization: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }
    
    func lineChartStyle() -> ChartStyle {
        var style = ChartStyle(backgroundColor: Color.white,
                               accentColor: Color.orange,
                               secondGradientColor: Color.orange,
                               textColor: Color.black,
                               legendTextColor: Color.black,
                               dropShadowColor: Color.gray)
        return style
    }

    func barChartStyle() -> ChartStyle {
        var style = ChartStyle(backgroundColor: Color.white,
                               accentColor: Color.blue,
                               secondGradientColor: Color.blue.opacity(0.6),
                               textColor: Color.black,
                               legendTextColor: Color.black,
                               dropShadowColor: Color.gray)
        return style
    }
    
    func fetchSleepData(completion: @escaping ([HKSample]) -> Void) {
        let healthStore = HKHealthStore()
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            if let error = error {
                print("Error fetching sleep data: \(error.localizedDescription)")
                completion([])
            } else {
                completion(samples ?? [])
            }
        }
        healthStore.execute(query)
    }
    
    func parseSleepDataForChart(samples: [HKSample]) -> ChartData {
        var sleepDataByDate: [String: Double] = [:]
        
        for sample in samples {
            if let sleepSample = sample as? HKCategorySample,
               let value = HKCategoryValueSleepAnalysis(rawValue: sleepSample.value),
               value == .asleepUnspecified {
                let calendar = Calendar.current
                let startDate = calendar.startOfDay(for: sleepSample.startDate)
                let endDate = calendar.startOfDay(for: sleepSample.endDate)
                let duration = sleepSample.endDate.timeIntervalSince(sleepSample.startDate)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd"
                
                let startDateString = dateFormatter.string(from: startDate)
                let endDateString = dateFormatter.string(from: endDate)
                
                if startDateString == endDateString {
                    sleepDataByDate[startDateString, default: 0] += duration
                } else {
                    let nextDay = calendar.date(byAdding: .day, value: 1, to: startDate)!
                    let remainingDuration = sleepSample.endDate.timeIntervalSince(nextDay)
                    sleepDataByDate[startDateString, default: 0] += duration - remainingDuration
                    sleepDataByDate[endDateString, default: 0] += remainingDuration
                }
            }
        }
        
        let sortedSleepData = sleepDataByDate.sorted(by: { $0.key < $1.key })
            return ChartData(points: sortedSleepData.map { ($0.key, $0.value / 3600) }) // Convert time intervals to hours
    }
    
    func sleepHoursDataValues() -> [Double] {
        return sleepHoursData.map { $0.1 }
    }
}
struct BarChartData {
    var points: [Double]
    
    init(points: [Double]) {
        self.points = points
    }
}
public struct ChartData {
    public var points: [(String, Double)]

    public init(points: [(String, Double)]) {
        self.points = points
    }

    public init(sleepData: [String: TimeInterval]) {
        self.points = sleepData.map { ($0.key, $0.value / 3600) } // Convert time intervals to hours
    }
}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(WorkoutData())
    }
}




