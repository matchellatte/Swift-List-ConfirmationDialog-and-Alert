import SwiftUI


// LIST NG COFFEE SHOPS DETAILS
struct ContentView: View {
    
    var restaurantNames = ["Cafe Deadend", "Homei", "Teakha", "Cafe Loisl", "Petite Oyster", "For Kee Restaurant", "Po's Atelier", "Bourke Street Bakery", "Haigh's Chocolate", "Palomino Espresso", "Upstate", "Traif", "Graham Avenue Meats", "Waffle & Wolf", "Five Leaves", "Cafe Lore", "Confessional", "Barrafina", "Donostia", "Royal Oak", "CASK Pub and Kitchen"]
        
    var restaurantImages = ["cafedeadend", "homei", "teakha", "cafeloisl", "petiteoyster", "forkee", "posatelier", "bourkestreetbakery", "haigh", "palomino", "upstate", "traif", "graham", "waffleandwolf", "fiveleaves", "cafelore", "confessional", "barrafina", "donostia", "royaloak", "cask"]
        
    var restaurantLocations = ["Hong Kong", "Hong Kong", "Hong Kong", "Hong Kong", "Hong Kong", "Hong Kong", "Hong Kong", "Sydney", "Sydney", "Sydney", "New York", "New York", "New York", "New York", "New York", "New York", "New York", "London", "London", "London", "London"]
            
    var restaurantTypes = ["Coffee & Tea Shop", "Cafe", "Tea House", "Austrian / Casual Drink", "French", "Bakery", "Bakery", "Chocolate", "Cafe", "American / Seafood", "American", "American", "Breakfast & Brunch", "Coffee & Tea", "Coffee & Tea", "Latin American", "Spanish", "Spanish", "Spanish", "British", "Thai"]


    @State private var searchText = ""
    @State private var favorites: Set<String> = []
    @State private var reservations: [String: Date] = [:]

    var filteredRestaurants: [String] {
        if searchText.isEmpty {
            return restaurantNames
        } else {
            return restaurantNames.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }

    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .padding(.top)

                List {
                    ForEach(filteredRestaurants.indices, id: \.self) { index in
                        if let originalIndex = restaurantNames.firstIndex(of: filteredRestaurants[index]) {
                            HStack {
                                NavigationLink(destination: RestaurantDetailView(
                                    restaurantName: restaurantNames[originalIndex],
                                    restaurantImage: restaurantImages[originalIndex],
                                    restaurantLocation: restaurantLocations[originalIndex],
                                    restaurantType: restaurantTypes[originalIndex],
                                    isFavorite: favorites.contains(restaurantNames[originalIndex]),
                                    toggleFavorite: {
                                        if favorites.contains(restaurantNames[originalIndex]) {
                                            favorites.remove(restaurantNames[originalIndex])
                                        } else {
                                            favorites.insert(restaurantNames[originalIndex])
                                        }
                                    },
                                    reservationDate: reservations[restaurantNames[originalIndex]],
                                    updateReservation: { selectedDate in
                                        reservations[restaurantNames[originalIndex]] = selectedDate
                                    }
                                )) {
                                    HStack {
                                        Image(restaurantImages[originalIndex])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(8)
                                            .clipped()

                                        VStack(alignment: .leading) {
                                            Text(restaurantNames[originalIndex])
                                                .font(.headline)
                                            Text(restaurantLocations[originalIndex])
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Text(restaurantTypes[originalIndex])
                                                .font(.subheadline)
                                                .foregroundColor(.gray)

                                       
                                            if let reservationDate = reservations[restaurantNames[originalIndex]] {
                                                Text("Reserved for \(formattedDate(reservationDate))")
                                                    .font(.footnote)
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                        .padding(.leading, 8)

                                        Spacer()
                                        
                                       
                                        Button(action: {
                                            if favorites.contains(restaurantNames[originalIndex]) {
                                                favorites.remove(restaurantNames[originalIndex])
                                            } else {
                                                favorites.insert(restaurantNames[originalIndex])
                                            }
                                        }) {
                                            Image(systemName: favorites.contains(restaurantNames[originalIndex]) ? "heart.fill" : "heart")
                                                .foregroundColor(favorites.contains(restaurantNames[originalIndex]) ? .red : .gray)
                                                .font(.title2)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Restaurants")
            .background(Color.white)
            .edgesIgnoringSafeArea(.bottom)
        }
        .accentColor(.black)
    }

  
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
// SEARCH BAR
struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(7)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .padding(.trailing)
                }
            }
        }
    }
}

// RESTAURANT DETAILS VIEW
struct RestaurantDetailView: View {
    var restaurantName: String
    var restaurantImage: String
    var restaurantLocation: String
    var restaurantType: String
    @State var isFavorite: Bool
    var toggleFavorite: () -> Void
    
    @State var reservationDate: Date?
    var updateReservation: (Date) -> Void

    @State private var showingDatePicker = false
    @State private var selectedDate = Date()
    @State private var showingConfirmationDialog = false
    @State private var showingAlert = false
    @State private var showingFavoriteAlert = false

    var body: some View {
        VStack {
            Image(restaurantImage)
                .resizable()
                .scaledToFit()
                .frame(height: 350)
                .cornerRadius(10)

            Text(restaurantName)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            Text(restaurantLocation)
                .font(.title2)
                .foregroundColor(.secondary)

            Text(restaurantType)
                .font(.title3)
                .foregroundColor(.gray)

            HStack {
                
                Button(action: {
                    toggleFavorite()
                    isFavorite.toggle()
                    // ALERT
                    showingFavoriteAlert = true
                }) {
                    Label(isFavorite ? "Remove from Favorites" : "Add to Favorites", systemImage: isFavorite ? "heart.fill" : "heart")
                        .font(.subheadline)
                        .padding(8)
                        .background(isFavorite ? Color.red : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top)

                Button(action: {
                    showingDatePicker = true
                }) {
                    Text("Make a Reservation")
                        .font(.subheadline)
                        .padding(8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top)
                .sheet(isPresented: $showingDatePicker) {
                    VStack {
                        DatePicker("Select Date and Time", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                        // COMFIRMDIALOG
                        Button("Confirm Reservation") {
                            showingConfirmationDialog = true
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .confirmationDialog("Confirm Reservation", isPresented: $showingConfirmationDialog) {
                            Button("Confirm") {
                                updateReservation(selectedDate)
                                showingAlert = true
                                showingDatePicker = false
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("Are you sure you want to confirm this reservation?")
                        }
                    }
                    .padding()
                }
            }

            Spacer()

            
            if let reservation = reservationDate {
                VStack {
                    Text("Reservation Details")
                        .font(.headline)
                        .padding(.top)

                    Text("Date & Time: \(formattedDate(reservation))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
            }
        }
        .navigationTitle(restaurantName)
        .background(Color.white)

        .alert(isPresented: $showingFavoriteAlert) {
            Alert(
                title: Text(isFavorite ? "Added to Favorites" : "Removed from Favorites"),
                message: Text(isFavorite ? "\(restaurantName) was added to your favorites." : "\(restaurantName) was removed to from favorites."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}


#Preview {
    ContentView()
}
