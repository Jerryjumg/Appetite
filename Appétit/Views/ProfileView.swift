import SwiftUI
import CoreData

struct ProfileView: View {
    @State private var selectedTimeRange = "7 Days"
    @State private var profileImage = Image(systemName: "person.crop.circle")
    @State private var name = " Name"
    @State private var nutritionGoal = "2000 cal/day"
    @State private var age: Int16 = 25
    @State private var weight: Double = 70.0
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var showingProfileEditView = false

    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            VStack {
                // Profile Section
                VStack(spacing: 20) {
                    // Profile Image
                    ZStack {
                        profileImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 4))
                            .shadow(radius: 10)

                        // Camera Icon
                        Image(systemName: "camera.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.7), in: Circle())
                            .padding(15)
                            .onTapGesture {
                                showingImagePicker = true
                            }
                    }
                    .padding(.top, 40)

                    Text(name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text(nutritionGoal)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    // Profile info
                    Text("Age: \(age)")
                    Text("Weight: \(weight, specifier: "%.1f") kg")

                    Button(action: {
                        showingProfileEditView = true
                    }) {
                        Text("Edit Profile & Goals")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(hex: "#91C788"))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.top, 10)
                }
                .frame(maxWidth: .infinity)
                .padding()
                Spacer()
            }
            .navigationBarTitle("Profile", displayMode: .inline)
            .onAppear {
                loadProfile()
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
                    .onDisappear {
                        loadImage()
                    }
            }
            .sheet(isPresented: $showingProfileEditView) {
                ProfileEditView(name: $name, nutritionGoal: $nutritionGoal, age: $age, weight: $weight)
                    .onDisappear {
                        saveProfile()
                    }
            }
        }
    }

    // Function to load profile image and info
    func loadImage() {
        guard let inputImage = inputImage else { return }
        profileImage = Image(uiImage: inputImage)
        saveImageToCoreData(image: inputImage)
    }

    // Function to save profile image to Core Data
    func saveImageToCoreData(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        
        // Save image data to a file and get the file URL
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory = urls.first else { return }
        let fileURL = documentDirectory.appendingPathComponent("profileImage.jpg")
        
        do {
            try imageData.write(to: fileURL)
            let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
            
            let users = try viewContext.fetch(fetchRequest)
            if let user = users.first {
                user.profileImageUrl = fileURL
            } else {
                let newUser = User(context: viewContext)
                newUser.profileImageUrl = fileURL
            }
            try viewContext.save()
        } catch {
            print("Failed to save image to Core Data: \(error.localizedDescription)")
        }
    }

    // Function to load profile information from Core Data
    func loadProfile() {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            let users = try viewContext.fetch(fetchRequest)
            if let user = users.first {
                name = user.name ?? "Name"
                nutritionGoal = user.nutritionGoal ?? "2000 cal/day"
                age = Int16(user.age)
                weight = user.weight
                if let profileImageUrl = user.profileImageUrl, let imageData = try? Data(contentsOf: profileImageUrl) {
                    profileImage = Image(uiImage: UIImage(data: imageData) ?? UIImage(systemName: "person.crop.circle")!)
                }
            }
        } catch {
            print("Failed to load profile from Core Data: \(error.localizedDescription)")
        }
    }

    // Function to save profile information to Core Data
    func saveProfile() {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            let users = try viewContext.fetch(fetchRequest)
            if let user = users.first {
                user.name = name
                user.nutritionGoal = nutritionGoal
                user.age = Int64(age)
                user.weight = weight
            } else {
                let newUser = User(context: viewContext)
                newUser.name = name
                newUser.nutritionGoal = nutritionGoal
                newUser.age = Int64(age)
                newUser.weight = weight
            }
            try viewContext.save()
        } catch {
            print("Failed to save profile to Core Data: \(error.localizedDescription)")
        }
    }
}


struct ProfileEditView: View {
    @Binding var name: String
    @Binding var nutritionGoal: String
    @Binding var age: Int16
    @Binding var weight: Double
    
    @Environment(\.presentationMode) var presentationMode // To dismiss the view
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Name
                VStack(alignment: .leading, spacing: 10) {
                    Text("Name")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#91C788"))
                    TextField("Enter your name", text: $name)
                        //.keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.vertical, 10)

                // Nutrition Goal
                VStack(alignment: .leading, spacing: 10) {
                    Text("Nutrition Goal")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#91C788"))
                    TextField("Enter your nutrition goal", text: $nutritionGoal)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.vertical, 10)

                // Age
                VStack(alignment: .leading, spacing: 10) {
                    Text("Age")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#91C788"))
                    TextField("Enter your age", value: $age, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 10)
                        .keyboardType(.decimalPad)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.vertical, 10)

                // Weight
                VStack(alignment: .leading, spacing: 10) {
                    Text("Weight (kg)")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#91C788"))
                    TextField("Enter your weight", value: $weight, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.vertical, 10)

                HStack {
                    Spacer()
                    Button(action: {
                        // Validation
                        if name.isEmpty || nutritionGoal.isEmpty || age == 0 || weight == 0 {
                            alertMessage = "All fields must be filled out."
                            showAlert = true
                        } else {
                            // Save changes (simulated)
                            alertMessage = "Your profile has been updated successfully."
                            showAlert = true
                        }
                    }) {
                        Text("Save")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(hex: "#91C788"))
                            .cornerRadius(10)
                    }
                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationBarTitle("Edit Profile", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss() // Dismiss the view
            })
            .padding(.horizontal, 20)
            .alert(isPresented: $showAlert) {
                Alert(title: Text(showAlert ? "Error" : "Success"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                    if !name.isEmpty && !nutritionGoal.isEmpty && age != 0 && weight != 0 {
                        presentationMode.wrappedValue.dismiss() // Dismiss after success
                    }
                })
            }
        }
    }
}


// Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

