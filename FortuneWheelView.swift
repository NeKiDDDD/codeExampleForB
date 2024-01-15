//
//  FortuneWheelView.swift
//  SweetFrenzyBonanza
//
//  Created by Nikita Kuznetsov on 28.12.2023.
//

import SwiftUI

struct FortuneWheelView: View {

    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var selectedPrize: String?
    @EnvironmentObject var coordinator: Coordinator
    @ObservedObject var userModel = UserModel.shared
    let colors: [Color] = [.yellow, .gray, .blue, .pink, .purple, .peach]
    let prizes = ["coin", "hearthBalance", "coin", "lollyPop", "coin", "coin", "hearthBalance", "coin", "lollyPop", "gift"]
    var win: () -> Void
    var loose: () -> Void
    
    
    let numberOfSections = 52
    
    var body: some View {
        ZStack {
            Image("wheelBack")
                .resizable()
                .ignoresSafeArea()
            VStack {
                ZStack {
                    Image("spinArrow")
                    Image("rainbowCandy")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .offset(y: -10)
                }
                .zIndex(1)
                .offset(y: 25)
                
                ZStack {
                    ForEach(0..<numberOfSections) { i in
                        WheelSection(angle: 360 / Double(numberOfSections), color: colors[i % colors.count], image: prizes[i % prizes.count])
                            .rotationEffect(Angle(degrees: Double(i) * 360 / Double(numberOfSections)))
                    }
                    .frame(width: 300, height: 300)
                    Image("wheelCenter")
                        .resizable()
                        .frame(width: 300, height: 300)
                    Circle()
                        .stroke(Color.orange, lineWidth: 8)
                        .frame(width: 300, height: 300)
                        .background(Circle()
                            .stroke(Color.black, lineWidth: 10)
                            .frame(width: 300, height: 300))

                }
                .rotationEffect(Angle(degrees: rotation))
                .animation(isSpinning ? .easeOut(duration: 3) : .none)
                
                AllWinsView(coins: userModel.sumMoney, lifes: userModel.sumHearts)
                SpinsView(action: { self.spinWheel(); userModel.spinned() }, spins: userModel.spins)
                    .offset(x: 7)
                    .disabled(isSpinning)
                
            }
        }
    }
    
    func spinWheel() {
        isSpinning = true
        selectedPrize = nil
        let newAngle = Double.random(in: 360...1080)
        withAnimation {
            rotation += newAngle
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isSpinning = false
            determinePrize()
        }
    }
    func determinePrize() {
        let normalizedRotation = rotation.truncatingRemainder(dividingBy: 360)
        let winningIndex = Int((normalizedRotation / (360 / Double(numberOfSections))).rounded())
        selectedPrize = prizes[winningIndex % prizes.count]
        if selectedPrize == "coin" {
            userModel.sumMoney += 100
            userModel.money += 100
            userModel.timeMoney += 100
            win()
        } else if selectedPrize == "hearthBalance" {
            userModel.sumHearts += 1
            userModel.extraLifes += 1
            win()
        } else if selectedPrize == "lollyPop" {
            userModel.sumMoney += 350
            userModel.money += 350
            userModel.timeMoney += 350
            win()
        } else {
            loose()
        }
    }
}


// Форма сектора колеса
struct WheelSection: View {
    var angle: Double
    var color: Color
    var image: String
    
    var body: some View {
        GeometryReader { geometry in
            let width = min(geometry.size.width, geometry.size.height)
            let height = width / 2
            
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: width / 2, y: height))
                    path.addArc(center: CGPoint(x: width / 2, y: height), radius: height, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: angle), clockwise: false)
                }
                .fill(color)
                
                Image(image)
                    .resizable()
                    .frame(width: 15, height: 15)
                    .position(x: width / 2, y: height)
                    .offset(x: height - 12)
                    .rotationEffect(Angle(degrees: angle / 3.4), anchor: .leading)
            }
            .rotationEffect(Angle(degrees: -angle / 2))
        }
    }
}


#Preview {
    FortuneWheelView(win: {}, loose: {})
}

