//
//  Home.swift
//  SpiralApp
//
//  Created by Alan Grissette on 10/16/25.
//

import SwiftUI
import FirebaseFirestore

struct Home: View {
    var currentDate: Date
    @State private var showSideBar: Bool = false
    @State private var showTaskView: Bool = false
    @State private var showClearTaskMenu: Bool = false
    @State private var showDeletePrompt: Bool = false
    @State private var task: String = ""
    @State private var refreshTrigger: Bool = false
    
    init(currentDate: Date = Date.now) {
        self.currentDate = currentDate
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                Color.secondary
                    .ignoresSafeArea()
                
                DeletePrompt(
                    showDeletePrompt: $showDeletePrompt,
                    task: $task,
                    date: currentDate
                ) {
                    ClearTaskMenu(showClearTaskMenu: $showClearTaskMenu) {
                        TaskMenu(date: currentDate, showTaskView: $showTaskView) {
                            VStack(spacing: 0) {
                                ZStack {
                                    VStack {
                                        Navbar(
                                            showSidebar: $showSideBar,
                                            refreshTrigger: $refreshTrigger,
                                            headerText: "Journal"
                                           
                                        )
                                        Hero(
                                            date: currentDate,
                                            showTaskView: $showTaskView,
                                            showDeletePrompt: $showDeletePrompt,
                                            task: $task,
                                            refreshTrigger: $refreshTrigger
                                        )
                                    }
                                    
                                    SideBar(
                                        showSideBar: $showSideBar,
                                        showClearTaskMenu: $showClearTaskMenu
                                    )
                                    .transition(.backSlide.combined(with: .identity))
                                    .animation(.linear, value: showSideBar)
                                }
                            }
                            .frame(maxHeight: .infinity, alignment: .topLeading)
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

// MARK: - Navbar
extension Home {
    struct Navbar: View {
        @Binding var showSidebar: Bool
        @Binding var refreshTrigger: Bool
        var headerText: String
        
        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Button(action: { showSidebar.toggle() }) {
                        Image(systemName: "chevron.forward")
                            .font(.system(size: 16))
                            .padding()
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Text(headerText)
                        .font(.custom("AlegreyaSansSC-Bold", size: 20))
                        .lineLimit(1)
                        .tracking(5)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        // Trigger refresh
                        refreshTrigger.toggle()
                    }) {
                        Image("SpiralLogo")
                            .resizable()
                            .frame(width: 25, height: 25)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 500, y: 0))
                }
                .stroke(Color.black, lineWidth: 1)
                .shadow(color: Color.black, radius: 3, y: 3)
                .frame(maxHeight: 4)
            }
        }
    }
}

// MARK: - Hero
extension Home {
    struct Hero: View {
        let date: Date
        @Binding var showTaskView: Bool
        @Binding var showDeletePrompt: Bool
        @Binding var task: String
        @Binding var refreshTrigger: Bool
        
        @EnvironmentObject var checkAuth: AuthModel
        
        @State private var tasks: [String] = []
        @State private var isLoading: Bool = true
        @State private var listener: ListenerRegistration?
        
        // MARK: - Date Formatters
        private var day: String {
            String(Calendar.current.component(.day, from: date))
        }
        
        private var month: Int {
            Calendar.current.component(.month, from: date)
        }
        
        private var year: String {
            String(Calendar.current.component(.year, from: date))
        }
        
        private var dayOfWeek: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        }
        
        private var monthName: String {
            Calendar.current.monthSymbols[month - 1]
        }
        
        // MARK: - Listen for Tasks
        private func listenForTasks() {
            guard let userID = checkAuth.currentUser?.id else {
                print("⚠️ User not logged in")
                isLoading = false
                return
            }
            
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
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    let loadedTasks = documents.compactMap { $0.data()["task"] as? String }
                    
                    DispatchQueue.main.async {
                        self.tasks = loadedTasks
                        self.isLoading = false
                    }
                }
        }
        
        private func stopListening() {
            listener?.remove()
            listener = nil
        }
        
        // MARK: - Body
        var body: some View {
            ZStack {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    Text(dayOfWeek)
                        .font(.custom("sippinOnSunshine", size: 25))
                        .foregroundStyle(.black)
                        .underline()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                        .padding(.horizontal)
                    
                    Text("\(monthName) \(day), \(year)")
                        .font(.custom("sippinOnSunshine", size: 20))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // Content
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView("Loading tasks...")
                                .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                            Spacer()
                        }
                        .padding(.top, 30)
                    } else if tasks.isEmpty {
                        Text("Add Tasks to Generate Your Personal Journal!")
                            .font(.custom("AlegreyaSansSC-Bold", size: 16))
                            .foregroundColor(.black)
                            .padding(.top, 30)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(tasks, id: \.self) { taskItem in
                                    Button(action: {
                                        showDeletePrompt.toggle()
                                        self.task = taskItem
                                    }) {
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                            Text(taskItem)
                                                .font(.custom("AlegreyaSansSC-Regular", size: 18))
                                                .foregroundColor(.black)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                
                                Collage(tasks: tasks)
                                    .padding(.top, 20)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 20)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .task {
                    listenForTasks()
                }
                .onDisappear {
                    stopListening()
                }
                .onChange(of: showTaskView) { _ in
                    if !showTaskView {
                        listenForTasks()
                    }
                }
                .onChange(of: refreshTrigger) { _ in
                    // Refresh tasks when trigger changes
                    isLoading = true
                    listenForTasks()
                }
                
                // Add Task Button
                VStack {
                    Spacer()
                    Button(action: { showTaskView.toggle() }) {
                        Text("Add Task")
                            .font(.custom("AlegreyaSansSC-Regular", size: 16))
                            .foregroundColor(.white)
                            .frame(width: 100, height: 50)
                            .background(Color.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .shadow(color: Color.black.opacity(0.4), radius: 2, y: 2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)
                }
            }
        }
    }
}

// MARK: - SideBar
extension Home {
    struct SideBar: View {
        @Binding var showSideBar: Bool
        @Binding var showClearTaskMenu: Bool
        
        var body: some View {
            if showSideBar {
                ZStack {
                    HStack {
                        VStack(spacing: 0) {
                            Rectangle()
                                .frame(maxWidth: 250, maxHeight: 215, alignment: .leading)
                                .foregroundColor(Color.primary)
                                .shadow(color: .black, radius: 1)
                            
                            Rectangle()
                                .frame(maxWidth: 250, maxHeight: .infinity, alignment: .leading)
                                .foregroundColor(Color.primary)
                                .shadow(color: .black, radius: 1)
                        }
                        .overlay(
                            Rectangle()
                                .frame(width: 2)
                                .foregroundColor(.black),
                            alignment: .trailing
                        )
                        
                        Spacer()
                    }
                    .ignoresSafeArea()
                    
                    VStack(alignment: .leading) {
                        VStack {
                            HStack(alignment: .top, spacing: 0) {
                                Button(action: { showSideBar.toggle() }) {
                                    Image(systemName: "chevron.backward")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16))
                                        .padding()
                                }
                                
                                Image("Vector")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .padding(.horizontal, 50)
                            }
                            .frame(maxWidth: 245, maxHeight: 65, alignment: .topLeading)
                            
                            Text("Spiral")
                                .foregroundColor(.white)
                                .font(.custom("sippinOnSunshine", size: 25))
                                .padding(.horizontal, 75)
                        }
                        .padding(.bottom, 30)
                        
                        Spacer()
                        
                        VStack(spacing: 35) {
                            NavLink(
                                destination: Home(currentDate: Date.now),
                                image: Image(systemName: "house"),
                                text: "Home"
                            )
                            
                            NavLink(
                                destination: CalendarPage(),
                                image: Image(systemName: "calendar.circle"),
                                text: "Calendar"
                            )
                            
                            Button(action: { showClearTaskMenu.toggle() }) {
                                HStack {
                                    Image(systemName: "clear")
                                        .font(.system(size: 20))
                                        .foregroundStyle(.white)
                                    Text("Clear Tasks")
                                        .foregroundColor(.white)
                                        .font(.custom("AlegreyaSansSC-Bold", size: 16))
                                        .padding(.horizontal, 16)
                                }
                                .frame(width: 175, alignment: .leading)
                                .padding()
                                .background(Color.primary)
                                .ignoresSafeArea()
                            }
                            
                            NavLink(
                                destination: AddWidget(),
                                image: Image(systemName: "plus.rectangle.on.rectangle"),
                                text: "Add Widget"
                            )
                            
                            NavLink(
                                destination: Settings(),
                                image: Image(systemName: "gear.badge.questionmark"),
                                text: "Settings"
                            )
                        }
                        .frame(maxWidth: 220, maxHeight: .infinity, alignment: .trailing)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: .infinity)
            }
        }
    }
}

// MARK: - Clear Task Menu
extension Home {
    struct ClearTaskMenu<Content: View>: View {
        let content: Content
        @Binding var showClearTaskMenu: Bool
        @EnvironmentObject var checkAuth: AuthModel
        
        init(
            showClearTaskMenu: Binding<Bool>,
            @ViewBuilder content: () -> Content
        ) {
            self._showClearTaskMenu = showClearTaskMenu
            self.content = content()
        }
        
        private func clearTasks() {
            guard let userID = checkAuth.currentUser?.id else {
                print("⚠️ User not logged in")
                return
            }
            
            let db = Firestore.firestore()
            let tasksRef = db.collection("users").document(userID).collection("tasks")
            
            tasksRef.getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching tasks: \(error)")
                    return
                }
                
                guard let dateDocs = snapshot?.documents, !dateDocs.isEmpty else {
                    print("ℹ️ No tasks to clear")
                    return
                }
                
                let batch = db.batch()
                var pendingFetches = dateDocs.count
                
                for dateDoc in dateDocs {
                    let dateRef = dateDoc.reference
                    let entriesRef = dateRef.collection("entries")
                    
                    entriesRef.getDocuments { entrySnap, entryErr in
                        if let entryErr = entryErr {
                            print("❌ Error fetching entries for \(dateDoc.documentID): \(entryErr)")
                        } else {
                            entrySnap?.documents.forEach { entryDoc in
                                batch.deleteDocument(entryDoc.reference)
                            }
                        }
                        
                        batch.deleteDocument(dateRef)
                        pendingFetches -= 1
                        
                        if pendingFetches == 0 {
                            batch.commit { commitErr in
                                if let commitErr = commitErr {
                                    print("❌ Failed to clear tasks: \(commitErr)")
                                } else {
                                    print("✅ All tasks cleared successfully")
                                }
                            }
                        }
                    }
                }
            }
        }
        
        var body: some View {
            ZStack {
                content
                
                if showClearTaskMenu {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showClearTaskMenu = false
                        }
                    
                    VStack(spacing: 20) {
                        Text("Clear Tasks")
                            .font(.custom("AlegreyaSansSC-Bold", size: 20))
                            .foregroundColor(.white)
                        
                        Image("Vector")
                            .resizable()
                            .frame(width: 40, height: 40)
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                clearTasks()
                                showClearTaskMenu = false
                            }) {
                                Text("Yes")
                                    .font(.custom("AlegreyaSansSC-Bold", size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: 100, height: 40)
                                    .background(Color.primary)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white, lineWidth: 3)
                                    )
                            }
                            
                            Button(action: {
                                showClearTaskMenu = false
                            }) {
                                Text("No")
                                    .font(.custom("AlegreyaSansSC-Bold", size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: 100, height: 40)
                                    .background(Color.primary)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white, lineWidth: 3)
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 25)
                    .frame(width: 300)
                    .background(Color.primary)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                }
            }
        }
    }
}

// MARK: - Task Menu
extension Home {
    struct TaskMenu<Content: View>: View {
        @State private var currentTask: String = ""
        @Binding var showTaskView: Bool
        var date: Date
        let content: Content
        
        @EnvironmentObject var checkAuth: AuthModel
        
        init(
            date: Date,
            showTaskView: Binding<Bool>,
            @ViewBuilder content: () -> Content
        ) {
            self._showTaskView = showTaskView
            self.content = content()
            self.date = date
        }
        
        private func addTask(_ task: String, date: Date) {
            guard let userID = checkAuth.currentUser?.id else {
                print("⚠️ User not logged in")
                return
            }
            
            let db = Firestore.firestore()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date)
            
            let dateDocRef = db.collection("users")
                .document(userID)
                .collection("tasks")
                .document(dateString)
            
            dateDocRef.setData([:], merge: true)
            
            let entriesRef = dateDocRef.collection("entries")
            entriesRef.addDocument(data: [
                "task": task,
                "timestamp": Timestamp(date: Date())
            ]) { error in
                if let error = error {
                    print("❌ Error adding task: \(error.localizedDescription)")
                } else {
                    print("✅ Task added successfully for \(dateString)")
                }
            }
        }
        
        var body: some View {
            ZStack {
                content
                
                if showTaskView {
                    Color.black.opacity(0.2)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showTaskView = false
                        }
                    
                    VStack(spacing: 20) {
                        Text("Add Task")
                            .font(.custom("AlegreyaSansSC-Bold", size: 20))
                            .foregroundColor(.white)
                        
                        Image("Vector")
                            .resizable()
                            .frame(width: 40, height: 40)
                        
                        TextField("Write your Task", text: $currentTask)
                            .font(.custom("AlegreyaSansSC-Bold", size: 20))
                            .padding()
                            .foregroundStyle(.black)
                            .frame(width: 300, height: 50)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                        
                        Button(action: {
                            addTask(currentTask, date: date)
                            currentTask = ""
                            showTaskView = false
                        }) {
                            Text("Save Task")
                                .font(.custom("AlegreyaSansSC-Bold", size: 20))
                                .foregroundColor(.white)
                                .frame(width: 200, height: 40)
                                .background(Color.primary)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white, lineWidth: 3)
                                )
                        }
                    }
                    .padding(.vertical, 25)
                    .background(Color.primary)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                }
            }
        }
    }
}

// MARK: - Nav Link
extension Home {
    struct NavLink<Destination: View>: View {
        var destination: Destination
        var image: Image
        var text: String
        
        var body: some View {
            NavigationLink(destination: destination) {
                HStack {
                    image
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                    Text(text)
                        .foregroundColor(.white)
                        .font(.custom("AlegreyaSansSC-Bold", size: 16))
                        .padding(.horizontal, 16)
                }
                .frame(width: 175, alignment: .leading)
                .padding()
                .background(Color.primary)
                .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Delete Prompt
struct DeletePrompt<Content: View>: View {
    @Binding var showDeletePrompt: Bool
    @Binding var task: String
    var date: Date
    let content: Content
    
    @EnvironmentObject var checkAuth: AuthModel
    
    init(
        showDeletePrompt: Binding<Bool>,
        task: Binding<String>,
        date: Date,
        @ViewBuilder content: () -> Content
    ) {
        self._showDeletePrompt = showDeletePrompt
        self._task = task
        self.date = date
        self.content = content()
    }
    
    private func deleteTask(task: String, date: Date) {
        guard let userID = checkAuth.currentUser?.id else {
            print("⚠️ User not logged in")
            return
        }
        
        let db = Firestore.firestore()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        let entriesRef = db.collection("users")
            .document(userID)
            .collection("tasks")
            .document(dateString)
            .collection("entries")
        
        entriesRef.whereField("task", isEqualTo: task)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error finding task to delete: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("⚠️ No matching task found to delete")
                    return
                }
                
                for doc in documents {
                    doc.reference.delete { err in
                        if let err = err {
                            print("❌ Error deleting task: \(err)")
                        } else {
                            print("🗑️ Deleted task: \(task)")
                        }
                    }
                }
            }
    }
    
    var body: some View {
        ZStack {
            content
            
            if showDeletePrompt {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { showDeletePrompt = false }
                    }
                
                VStack(spacing: 20) {
                    Text("Delete Task?")
                        .font(.custom("AlegreyaSansSC-Bold", size: 20))
                        .padding(.top, 10)
                    
                    Text("Are you sure you want to delete \(task)?")
                        .font(.custom("AlegreyaSansSC-regular", size: 16))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    HStack {
                        Button("Cancel") {
                            withAnimation { showDeletePrompt = false }
                        }
                        .frame(maxWidth: .infinity)
                        
                        Button("Delete") {
                            deleteTask(task: task, date: date)
                            showDeletePrompt = false
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 25)
                .frame(maxWidth: 300)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(radius: 12)
                .transition(.scale)
                .zIndex(10)
            }
        }
    }
}

// MARK: - Transitions
extension AnyTransition {
    static var backSlide: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: .leading),
            removal: .move(edge: .leading)
        )
    }
}

// MARK: - Preview
#Preview {
    Home()
        .environmentObject(AuthModel())
}
