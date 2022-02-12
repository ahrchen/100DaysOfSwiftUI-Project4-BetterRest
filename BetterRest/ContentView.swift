//
//  ContentView.swift
//  BetterRest
//
//  Created by Raymond Chen on 2/10/22.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    let secondsInMinute = 60
    let secondsInHour = 3600
    
    private var toSleep: String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * secondsInHour
            let minute = (components.minute ?? 0) * secondsInMinute
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            return "Your ideal bedtime is...\(sleepTime.formatted(date: .omitted, time:.shortened))"
        } catch {
            return  "Error, there was a problem calculating your bedtime."
        }
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    
                    Picker("Cups of coffee", selection: $coffeeAmount) {
                        ForEach(1...20, id:\.self) { cups in
                            Text(cups.formatted())
                        }
                    }
                    .pickerStyle(.automatic)
                }
                
                Section {
                    Text(toSleep)
                        .font(.largeTitle)
                }
            }
            .navigationTitle("BetterRest")
        }
    }
    
    func exampleDates() -> ClosedRange<Date> {
        let tomorrow = Date.now.addingTimeInterval(86400)
        let range = Date.now...tomorrow
        return range
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
