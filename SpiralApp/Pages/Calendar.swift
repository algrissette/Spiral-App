//
//  Calendar.swift
//  SpiralApp
//
//  Created by Alan Grissette on 10/19/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth



struct ShowMiniJournal: View {
    @Binding var showMiniJournal: [(String, Int, Int)]
    @EnvironmentObject var checkAuth: AuthModel
    @State private var tasks: [String] = []
    @State private var isLoading = true
    @State private var listener: ListenerRegistration?

    // MARK: - Extract current tuple safely
    private var currentTuple: (day: String, month: Int, year: Int)? {
        showMiniJournal.first
    }

    // MARK: - Convert tuple to Date
    private var date: Date? {
        guard let tuple = currentTuple, let dayInt = Int(tuple.day), tuple.month >= 1, tuple.month <= 12 else { return nil }
        var components = DateComponents()
        components.day = dayInt
        components.month = tuple.month
        components.year = tuple.year
        return Calendar.current.date(from: components)
    }


    private var monthName: String {
        guard let month = currentTuple?.month, month >= 1, month <= 12 else { return "" }
        return Calendar.current.monthSymbols[month - 1]
    }

    // MARK: - Firestore listening
    func listenForTasks() {
        guard let userID = checkAuth.currentUser?.id else {
            print("⚠️ User not logged in")
            isLoading = false
            return
        }
        guard let date = date else { return }

        let db = Firestore.firestore()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        listener?.remove()
        listener = db.collection("users")
            .document(userID)
            .collection("tasks")
            .document(dateString)
            .collection("entries")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("🔥 Error listening for tasks: \(error.localizedDescription)")
                    return
                }
                let loadedTasks = snapshot?.documents.compactMap { $0.data()["task"] as? String } ?? []
                DispatchQueue.main.async {
                    self.tasks = loadedTasks
                    self.isLoading = false
                }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    // MARK: - View Body
    var body: some View {
        if let tuple = currentTuple {
            ZStack {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { showMiniJournal = [] }

                VStack(spacing: 16) {
                    Text("Tasks for \(monthName) \(tuple.day), \(tuple.year)")
                        .font(.custom("AlegreyaSansSC-Bold", size: 16))
                        .foregroundColor(.black)
                        .padding(.top)

                    Divider().background(Color.white)

                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else if tasks.isEmpty {
                        Text("No tasks for this date!")
                            .font(.custom("AlegreyaSansSC-regular", size: 14))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(tasks, id: \.self) { task in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(task)
                                        .font(.custom("AlegreyaSansSC-regular", size: 14))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer()

                    HStack(spacing: 12) {
                        // Close button
                        Button(action: { showMiniJournal = [] }) {
                            Text("X")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.cornerRadius(10))
                                .foregroundColor(.white)
                        }

                        // Open Full Journal using your NavLink
                        NavLink(
                            destination: Home(currentDate: date ?? Date()),
                            image: Image(systemName: "book"),
                            text: "Open Full Journal"
                        )
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .frame(width: 300, height: 280)
                .background(Color.secondary)
                .cornerRadius(20)
                .shadow(radius: 10)
                .onAppear { listenForTasks() }
                .onDisappear { stopListening() }
            }
        }
    }
}


// MARK: - CalendarPage View

struct CalendarPage: View {
    @State private var showSideBar = false
    @State private var selectedMonth  = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var isUpdatingMonthYear = false
    @State private var showMiniJournal: [(String, Int, Int)] = []
    @State var showClearTaskMenu : Bool = false

    
    func setMonthsBefore(_ currentMonth: Int, _ currentYear: Int) -> [(Int, Int)] {
        var monthsArray: [(Int, Int)] = []
        var month = currentMonth
        var year = currentYear

        for _ in 1...12 { // 12 months before
            month -= 1
            if month < 1 { month = 12; year -= 1 }
            monthsArray.append((month, year))
        }
        return monthsArray.reversed()
    }

    func setMonthsAfter(_ currentMonth: Int, _ currentYear: Int) -> [(Int, Int)] {
        var monthsArray: [(Int, Int)] = []
        var month = currentMonth
        var year = currentYear

        for _ in 1...12 { // 12 months after
            month += 1
            if month > 12 { month = 1; year += 1 }
            monthsArray.append((month, year))
        }
        return monthsArray
    }

    private var monthsBefore: [(Int, Int)] { setMonthsBefore(selectedMonth, selectedYear) }
    private var monthsAfter: [(Int, Int)] { setMonthsAfter(selectedMonth, selectedYear) }
    
    private let months = Calendar.current.monthSymbols
    private let years = Array(1900...2100)
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                VStack {
                    Navbar(showSidebar: $showSideBar, headerText: "Calendar")
                }
                .background(Color.secondary)
                
                VStack (spacing:0){
                    VStack (spacing: 0){
                        HStack(spacing: 12) {
                            Button(action: { changeMonth(by: -1) }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size:16))
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .clipShape(Circle())
                            }
                            Spacer()
                            
                            Picker("Month", selection: $selectedMonth) {
                                ForEach(1...12, id: \.self) { index in
                                    Text(months[index - 1]).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .font(.custom("AlegreyaSansSC-Bold", size: 16))
                            .padding(.horizontal, 8)
                            .cornerRadius(6)
                            
                            Picker("Year", selection: $selectedYear) {
                                ForEach(years, id: \.self) { year in
                                    Text(String(year))
                                        .font(.custom("AlegreyaSansSC-Bold", size: 16))
                                        .foregroundColor(.black)
                                        .tag(year)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(.horizontal, 8)
                            .cornerRadius(6)
                            
                            Spacer()
                            
                            Button(action: { changeMonth(by: 1) }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size:16))
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .clipShape(Circle())
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))

                        
                    }
                    .background(Color.secondary)
                    CalendarHeader()
                    
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack {
                                GeometryReader { geo in
                                    let minY = geo.frame(in: .global).minY
                                    Color.clear
                                        .onChange(of: minY) {
                                            if !isUpdatingMonthYear && minY > 150 {
                                                isUpdatingMonthYear = true
                                                changeMonth(by: -12)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    isUpdatingMonthYear = false
                                                }
                                            }
                                        }
                                }
                                .frame(height: 1)
                                
                                ForEach(monthsBefore.indices, id: \.self) { index in
                                    let (month, year) = monthsBefore[index]
                                    MonthHeader(monthNumber: month)
                                    MonthView(month: month, year: year, showMiniJournal: $showMiniJournal)
                                }
                                
                                MonthHeader(monthNumber: selectedMonth)
                                
                                MonthView(month: selectedMonth, year: selectedYear, showMiniJournal: $showMiniJournal)
                                    .id("myMonth")
                                
                                ForEach(monthsAfter.indices, id: \.self) { index in
                                    let (month, year) = monthsAfter[index]
                                    MonthHeader(monthNumber: month)
                                    MonthView(month: month, year: year, showMiniJournal: $showMiniJournal)
                                }
                                
                                GeometryReader { geo in
                                    let maxY = geo.frame(in: .global).maxY
                                    let screenHeight = UIScreen.main.bounds.height
                                    Color.clear
                                        .onChange(of: maxY) {
                                            if !isUpdatingMonthYear && maxY < screenHeight + 150 {
                                                isUpdatingMonthYear = true
                                                changeMonth(by: 12)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    isUpdatingMonthYear = false
                                                }
                                            }
                                        }
                                }
                                .frame(height: 1)
                                
                                Spacer()
                            }
                            .onAppear {
                                DispatchQueue.main.async { proxy.scrollTo("myMonth", anchor: .center) }
                            }
                            .onChange(of: selectedMonth) {
                                DispatchQueue.main.async { proxy.scrollTo("myMonth", anchor: .center) }
                            }
                            .onChange(of: selectedYear) {
                                DispatchQueue.main.async { proxy.scrollTo("myMonth", anchor: .center) }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
            .background(Color.primary)
            
            if selectedMonth != Calendar.current.component(.month, from: Date()) ||
               selectedYear != Calendar.current.component(.year, from: Date()) {
                
                Button(action: {
                    let today = Date()
                    let calendar = Calendar.current
                    selectedMonth = calendar.component(.month, from: today)
                    selectedYear = calendar.component(.year, from: today)
                }) {
                    Text("Go to Today")
                        .font(.custom("AlegreyaSansSC-regular", size: 20))
                        .foregroundColor(.white)
                        .frame(width: 65, height: 65)
                        .background(
                            Circle()
                                .fill(Color.red)
                                .shadow(color: Color.black.opacity(1), radius: 10, x: 0, y: 2)
                        )
                }
                .padding(1)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding()
            }
            
            if !showMiniJournal.isEmpty {
                ShowMiniJournal(showMiniJournal: $showMiniJournal)
            }
            
            SideBar(showSideBar: $showSideBar, showClearTaskMenu: $showClearTaskMenu)
                .transition(.move(edge: .leading))
                .animation(.easeInOut, value: showSideBar)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func changeMonth(by value: Int) {
        var newMonth = selectedMonth + value
        var newYear = selectedYear
        
        while newMonth > 12 { newMonth -= 12; newYear += 1 }
        while newMonth < 1 { newMonth += 12; newYear -= 1 }
        
        selectedMonth = newMonth
        selectedYear = newYear
    }
}

// MARK: - MonthHeader View

struct MonthHeader: View {
    var monthNumber: Int
    private let months = Calendar.current.monthSymbols
    
    var body: some View {
        Text(months[monthNumber - 1])
            .font(.custom("sippinOnSunshine", size: 35))
            .foregroundStyle(
                .white
                )
            
            .shadow(color: .black.opacity(0.2), radius: 3, x: 1, y: 1)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
    }
}

// MARK: - CalendarHeader View

struct CalendarHeader: View {
    private let days = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        HStack {
            ForEach(days, id: \.self) { day in
                Text(day)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - MonthView View

struct MonthView: View {
    var month: Int
    var year: Int
    @Binding var showMiniJournal: [(String, Int, Int)]
    
    private let calendar = Calendar.current
    
    private var firstOfMonth: Date? {
        calendar.date(from: DateComponents(year: year, month: month, day: 1))
    }
    
    private var daysInMonth: Int {
        guard let date = firstOfMonth,
              let range = calendar.range(of: .day, in: .month, for: date) else {
            return 0
        }
        return range.count
    }
    
    private var firstWeekday: Int {
        guard let date = firstOfMonth else { return 1 }
        return (calendar.component(.weekday, from: date) + 6) % 7
    }
    
    private var totalItems: [CalendarCell] {
        var items: [CalendarCell] = []
        for _ in 0..<firstWeekday { items.append(.empty) }
        for day in 1...daysInMonth { items.append(.day(day)) }
        return items
    }
    
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(totalItems.indices, id: \.self) { index in
                switch totalItems[index] {
                case .empty:
                    Spacer().frame(width: 60, height: 75)
                case .day(let day):
                    CalendarCellView(
                        emoji: "🌀",
                        date: "\(day)",
                        month: month,
                        year: year,
                        showMiniJournal: $showMiniJournal
                    )
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.primary.opacity(0.5))
                .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

enum CalendarCell {
    case empty
    case day(Int)
}

// MARK: - CalendarCellView View

struct CalendarCellView: View {
    var emoji: String
    var date: String
    var month: Int
    var year: Int
    @Binding var showMiniJournal: [(String, Int, Int)]
    
    var isToday: Bool {
        Int(date) == Calendar.current.component(.day, from: Date()) &&
        month == Calendar.current.component(.month, from: Date()) &&
        year == Calendar.current.component(.year, from: Date())
    }
    
    var body: some View {
        Button(action: {
            showMiniJournal = [(date, month, year)]
        }) {
            VStack(spacing: 4) {
                Text(date)
                    .font(.custom("AlegreyaSansSC-Bold", size: 18))
                    .foregroundColor(isToday ? .white : .primary)
                
                Text(emoji)
                    .font(.system(size: 20))
            }
            .frame(width: 60, height: 75)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            isToday
                            ? AnyShapeStyle(LinearGradient(colors: [Color.blue, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            : AnyShapeStyle(Color.white)
                        )
                    
                    if !isToday {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    }
                }
            )
        }
        .padding(2)
    }
}

#Preview {
    CalendarPage()
        .environmentObject(AuthModel()) // provide dummy auth
}
