import SwiftUI

struct CollegeAppView: View {
    @ObservedObject var subjectsManager: SubjectsManager
    @Environment(\.dismiss) var dismiss
    @FocusState private var isECFocused: Bool
    
    @State private var grade9: String = ""
    @State private var grade10: String = ""
    @State private var grade11: String = ""
    @State private var grade12: String = ""
    @State private var extracurriculars: String = ""
    @State private var needsAid: Bool = false
    @State private var location: CollegeApplication.Location = .india
    @State private var selectedCountries: Set<String> = []
    @State private var isSaving: Bool = false
    @State private var showSuccess: Bool = false
    @State private var isLoading: Bool = true
    
    let availableCountries = ["USA", "UK", "Canada", "Australia", "Germany", "France", "Singapore", "Japan", "South Korea", "Netherlands"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("College Application")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Text("Tell us about yourself to get personalized university recommendations")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 20) {
                            // High School Grades
                            VStack(alignment: .leading, spacing: 16) {
                                Text("High School Grades")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                GradeSelectorView(
                                    grade9: $grade9,
                                    grade10: $grade10,
                                    grade11: $grade11,
                                    grade12: $grade12
                                )
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Extracurriculars
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Extracurriculars (Optional)")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                ZStack(alignment: .topLeading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                    
                                    if extracurriculars.isEmpty {
                                        Text("Enter your extracurricular activities...")
                                            .foregroundColor(.gray.opacity(0.5))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 8)
                                    }
                                    
                                    TextEditor(text: $extracurriculars)
                                        .frame(height: 100)
                                        .scrollContentBackground(.hidden)
                                        .foregroundColor(.black)
                                        .padding(4)
                                        .focused($isECFocused)
                                        .toolbar {
                                            ToolbarItemGroup(placement: .keyboard) {
                                                Spacer()
                                                Button("Done") {
                                                    isECFocused = false
                                                }
                                            }
                                        }
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Financial Aid
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Financial Aid")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Toggle("Do you need financial aid?", isOn: $needsAid)
                                    .padding(.vertical, 4)
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Location
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Study Location")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                HStack(spacing: 10) {
                                    Button(action: {
                                        location = .india
                                    }) {
                                        Text("India")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(location == .india ? .white : .black)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(location == .india ? Color.blue : Color.white)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(location == .india ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1.5)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Button(action: {
                                        location = .abroad
                                    }) {
                                        Text("Abroad")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(location == .abroad ? .white : .black)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(location == .abroad ? Color.blue : Color.white)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(location == .abroad ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1.5)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                if location == .abroad {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Select Countries (Optional)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                            ForEach(availableCountries, id: \.self) { country in
                                                Button(action: {
                                                    if selectedCountries.contains(country) {
                                                        selectedCountries.remove(country)
                                                    } else {
                                                        selectedCountries.insert(country)
                                                    }
                                                }) {
                                                    HStack {
                                                        Image(systemName: selectedCountries.contains(country) ? "checkmark.circle.fill" : "circle")
                                                            .foregroundColor(selectedCountries.contains(country) ? .blue : .gray)
                                                        Text(country)
                                                            .font(.subheadline)
                                                            .foregroundColor(.black)
                                                    }
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 8)
                                                    .background(selectedCountries.contains(country) ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                                    .cornerRadius(8)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                    }
                                    .padding(.top, 8)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Submit Button
                            Button(action: saveApplication) {
                                HStack {
                                    if isSaving {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Save Application")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(grade9.isEmpty ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(grade9.isEmpty || isSaving)
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
                
                // Success Overlay
                if showSuccess {
                    VStack {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            Text("Application Saved!")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            Text("Coming Soon: University Recommendations")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(40)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 20)
                        .padding(40)
                        Spacer()
                    }
                    .background(Color.black.opacity(0.3))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showSuccess = false
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("College App")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadExistingApplication()
            }
        }
    }
    
    private func loadExistingApplication() {
        Task {
            if let existing = await subjectsManager.loadCollegeApplication() {
                await MainActor.run {
                    grade9 = existing.grade9 ?? ""
                    grade10 = existing.grade10 ?? ""
                    grade11 = existing.grade11 ?? ""
                    grade12 = existing.grade12 ?? ""
                    extracurriculars = existing.extracurriculars ?? ""
                    needsAid = existing.needsAid
                    location = existing.location
                    selectedCountries = Set(existing.countries)
                    isLoading = false
                }
            } else {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
    
    private func saveApplication() {
        guard !grade9.isEmpty else { return }
        
        isSaving = true
        
        Task {
            let success = await subjectsManager.saveCollegeApplication(
                grade9: grade9,
                grade10: grade10.isEmpty ? nil : grade10,
                grade11: grade11.isEmpty ? nil : grade11,
                grade12: grade12.isEmpty ? nil : grade12,
                extracurriculars: extracurriculars.isEmpty ? nil : extracurriculars,
                needsAid: needsAid,
                location: location,
                countries: Array(selectedCountries)
            )
            
            await MainActor.run {
                isSaving = false
                if success {
                    showSuccess = true
                }
            }
        }
    }
}

struct GradeSelectorView: View {
    @Binding var grade9: String
    @Binding var grade10: String
    @Binding var grade11: String
    @Binding var grade12: String
    
    @State private var selectedGradeLevel: String? = nil
    
    let gradeLevels = [
        ("9th Grade", "9th", true),
        ("10th Grade", "10th", false),
        ("11th Grade", "11th", false),
        ("12th Grade", "12th", false)
    ]
    
    let gradeOptions = ["A+", "A", "A-", "B+", "B", "B-", "C+", "C", "C-", "D", "F"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Step 1: Select Grade Level (Multiple selection allowed)
            VStack(alignment: .leading, spacing: 8) {
                Text("Step 1: Select Grade Level(s)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(gradeLevels, id: \.1) { level in
                            Button(action: {
                                // 9th grade is required, can't deselect it if it's the only one
                                if level.1 == "9th" && grade9.isEmpty && selectedGradeLevel != "9th" {
                                    selectedGradeLevel = "9th"
                                } else if selectedGradeLevel == level.1 {
                                    // Only allow deselecting if it's not 9th or if 9th has a grade
                                    if level.1 != "9th" || !grade9.isEmpty {
                                        selectedGradeLevel = nil
                                    }
                                } else {
                                    selectedGradeLevel = level.1
                                }
                            }) {
                                HStack {
                                    Text(level.0)
                                        .font(.system(size: 14, weight: .medium))
                                    if level.2 {
                                        Text("*")
                                            .foregroundColor(.red)
                                    }
                                }
                                .foregroundColor(selectedGradeLevel == level.1 ? .white : .black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(selectedGradeLevel == level.1 ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedGradeLevel == level.1 ? Color.blue : (hasGrade(for: level.1) ? Color.green : Color.gray.opacity(0.3)), lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
            
            // Step 2: Select Grade (MCQ) - Only show if grade level is selected
            if let selectedLevel = selectedGradeLevel {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Step 2: Select Your Grade")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(gradeOptions, id: \.self) { grade in
                                Button(action: {
                                    let currentGrade = getCurrentGrade(for: selectedLevel)
                                    if currentGrade == grade {
                                        // Only allow clearing if it's not 9th grade
                                        if selectedLevel != "9th" {
                                            setGrade(for: selectedLevel, value: "")
                                            selectedGradeLevel = nil
                                        }
                                    } else {
                                        setGrade(for: selectedLevel, value: grade)
                                        // After selecting, allow selecting another grade level
                                        selectedGradeLevel = nil
                                    }
                                }) {
                                    Text(grade)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(getCurrentGrade(for: selectedLevel) == grade ? .white : .black)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(getCurrentGrade(for: selectedLevel) == grade ? Color.blue : Color.white)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(getCurrentGrade(for: selectedLevel) == grade ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1.5)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Show selected grades summary
            if !grade9.isEmpty || !grade10.isEmpty || !grade11.isEmpty || !grade12.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Selected Grades:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if !grade9.isEmpty {
                            HStack {
                                Text("9th Grade:")
                                    .foregroundColor(.black)
                                Text(grade9)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                            .font(.subheadline)
                        }
                        if !grade10.isEmpty {
                            HStack {
                                Text("10th Grade:")
                                    .foregroundColor(.black)
                                Text(grade10)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                            .font(.subheadline)
                        }
                        if !grade11.isEmpty {
                            HStack {
                                Text("11th Grade:")
                                    .foregroundColor(.black)
                                Text(grade11)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                            .font(.subheadline)
                        }
                        if !grade12.isEmpty {
                            HStack {
                                Text("12th Grade:")
                                    .foregroundColor(.black)
                                Text(grade12)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                            .font(.subheadline)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
    }
    
    private func hasGrade(for level: String) -> Bool {
        return !getCurrentGrade(for: level).isEmpty
    }
    
    private func getCurrentGrade(for level: String) -> String {
        switch level {
        case "9th": return grade9
        case "10th": return grade10
        case "11th": return grade11
        case "12th": return grade12
        default: return ""
        }
    }
    
    private func setGrade(for level: String, value: String) {
        switch level {
        case "9th": grade9 = value
        case "10th": grade10 = value
        case "11th": grade11 = value
        case "12th": grade12 = value
        default: break
        }
    }
}

