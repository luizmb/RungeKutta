import Calculus
import Foundation

let startY: Decimal = 1.0
let startTime: Decimal = 0.0
let endTime: Decimal = 10.0
let Δtime: Decimal = 0.10

let graphPoints =
    stride(from: startTime,
           to: endTime + Δtime,
           by: Δtime)
        .reduce([RungeKuttaPoint(x: startTime, y: startY)],
                RungeKuttaPoint.calculateNextPoint(Δx: Δtime,
                                                   stepCalculator: rungeKutta4(fn: differentialEquation)))

graphPoints
    .filter(shouldPrint)
    .forEach(printPoint)
