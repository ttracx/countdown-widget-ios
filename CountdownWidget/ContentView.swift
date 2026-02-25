import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CountdownViewModel()
    @State private var showingAddEvent = false
    @State private var showingPaywall = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Active Countdowns")) {
                    if viewModel.events.isEmpty {
                        Text("No countdowns yet. Tap + to add one!")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.events) { event in
                            EventRow(event: event)
                        }
                        .onDelete(perform: viewModel.deleteEvent)
                    }
                }
                
                Section {
                    Button(action: { showingPaywall = true }) {
                        HStack {
                            Image(systemName: viewModel.isPro ? "checkmark.circle.fill" : "crown.fill")
                            Text(viewModel.isPro ? "Pro Active" : "Upgrade to Pro - $0.99")
                        }
                        .foregroundColor(viewModel.isPro ? .green : .orange)
                    }
                    .disabled(viewModel.isPro)
                }
            }
            .navigationTitle("Countdown")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if viewModel.canAddMore() {
                            showingAddEvent = true
                        } else {
                            showingPaywall = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView(viewModel: viewModel)
            }
        }
    }
}

struct EventRow: View {
    let event: CountdownEvent
    
    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: event.date).day ?? 0
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.name)
                    .font(.headline)
                Text(event.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(daysRemaining)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(daysRemaining <= 7 ? .red : .blue)
                Text("days")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddEventView: View {
    @ObservedObject var viewModel: CountdownViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var date = Date().addingTimeInterval(86400)
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Event Name", text: $name)
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
            .navigationTitle("New Countdown")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    viewModel.addEvent(name: name, date: date)
                    dismiss()
                }
                .disabled(name.isEmpty)
            )
        }
    }
}

struct PaywallView: View {
    @ObservedObject var viewModel: CountdownViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                
                Text("Countdown Pro")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack { Image(systemName: "infinity").foregroundColor(.blue); Text("Unlimited countdowns") }
                    HStack { Image(systemName: "paintbrush").foregroundColor(.blue); Text("Custom widget themes") }
                    HStack { Image(systemName: "photo").foregroundColor(.blue); Text("Add photos to events") }
                    HStack { Image(systemName: "bell").foregroundColor(.blue); Text("Reminder notifications") }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Text("$0.99")
                        .font(.system(size: 48, weight: .bold))
                    
                    Text("One-time purchase")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Button(action: {
                    viewModel.purchasePro()
                    dismiss()
                }) {
                    Text("Purchase Pro")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarItems(trailing: Button("Close") { dismiss() })
        }
    }
}
