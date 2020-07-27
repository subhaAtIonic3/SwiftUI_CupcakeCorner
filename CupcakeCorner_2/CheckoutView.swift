//
//  CheckoutView.swift
//  CupcakeCorner_2
//
//  Created by Subhrajyoti Chakraborty on 25/07/20.
//  Copyright © 2020 Subhrajyoti Chakraborty. All rights reserved.
//

import SwiftUI

struct CheckoutView: View {
    
    @ObservedObject var order: Order
    @State private var confirmationMessage = ""
    @State private var showAlert = false
    @State private var alertTitle = ""
    
    func placeOrder() {
        guard let encoded = try? JSONEncoder().encode(order.cakeItem) else {
            print("Unable to encode order data")
            return
        }

        let url = URL(string: "https://reqres.in/api/cupcakes")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = encoded

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
                self.alertTitle = "Error!"
                self.confirmationMessage = error?.localizedDescription ?? "Some error occurred. Please try again later."
                self.showAlert = true
                return
            }

            if let decodedOrder = try? JSONDecoder().decode(CakeItem.self, from: data) {
                self.alertTitle = "Thank you!"
                self.confirmationMessage = "Your order for \(decodedOrder.quantity)x \(CakeItem.types[decodedOrder.type].lowercased()) cupcakes is on its way!"
                } else {
                print("Invalid response from server")
                self.alertTitle = "Error!"
                self.confirmationMessage = "Some error occurred. Please try again later."
            }
            self.showAlert = true
        }.resume()
        
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    Image("cupcakes")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width)
                    
                    Text("Your total is $\(self.order.cakeItem.cost, specifier: "%.2f")")
                    .font(.title)
                    
                    Button("Place Order") {
                        self.placeOrder()
                    }
                .padding()
                }
            }
        }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(self.alertTitle), message: Text(confirmationMessage), dismissButton: .default(Text("OK")))
            }
        .navigationBarTitle("Check out", displayMode: .inline)
        
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(order: Order())
    }
}
