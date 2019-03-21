# RungeKutta
Runge-Kutta method to solve differential equation

This repository offers an alternative approach for the Runge-Kutta method Swift implementation that's available here: https://rosettacode.org/wiki/Runge-Kutta_method#Swift

Runge-Kutta 4th order is available now, but more methods are planned. Other derivative functions can also be found in this repository.

In order to use the playground, please build `Calculus` target first. Also please notice that more playground pages are available, not only the first one.

To calculate each Runge-Kutta step, first thing is to configure the function by giving the differential equation with the shape `(x: Decimal, y: Decimal) -> Decimal`. This will return a function that, given the last point and the delta x (time interval) since the last point, will return the delta y, having the shape `(RungeKuttaPoint, Decimal) -> Decimal`. The whole function implementation can be seen below:

```swift
public func rungeKutta4(fn: @escaping (Decimal, Decimal) -> Decimal) -> (RungeKuttaPoint, Decimal) -> Decimal {
    return { pt𝓃, Δx in
        let Δy1 = Δx * fn(pt𝓃.x, pt𝓃.y)
        let Δy2 = Δx * fn(pt𝓃.x + Δx / 2, pt𝓃.y + Δy1 / 2)
        let Δy3 = Δx * fn(pt𝓃.x + Δx / 2, pt𝓃.y + Δy2 / 2)
        let Δy4 = Δx * fn(pt𝓃.x + Δx, pt𝓃.y + Δy3)
        return (Δy1 + 2 * Δy2 + 2 * Δy3 + Δy4) / 6
    }
}
```

The easiest way to collect points across time is by using a reduce function, so the Runge-Kutta Point struct offers a helper to simplify that. First thing is to configure the function by giving the time interval (delta x) and the step calculator (our `rungeKutta4(fn:)` function above). This will return a new function exactly in the shape of a `reduce` function, that is, `(pointsAccumulated: [RungeKuttaPoint], currentTimeElapsed: Decimal) -> [RungeKuttaPoint]`.

```swift
extension RungeKuttaPoint {
    public static func calculateNextPoint(Δx: Decimal, stepCalculator: @escaping (RungeKuttaPoint, Decimal) -> Decimal) -> ([RungeKuttaPoint], Decimal) -> [RungeKuttaPoint] {
        return { points, currentPointInTime in
            let lastPoint = points.last!
            let Δy = stepCalculator(lastPoint, Δx)
            return points + [.init(x: lastPoint.x + Δx,
                                   y: lastPoint.y + Δy)]
        }
    }
}
```

To bake everything together, let's give a differential equation example as suggested by the rosettacode website.

```swift
public func differentialEquation(x: Decimal, y: Decimal) -> Decimal {
    return x * Decimal(sqrt(NSDecimalNumber(decimal: y).doubleValue))
}

public func equationExactSolution(x: Decimal, y: Decimal) -> Decimal {
    return pow(x * x + 4, 2) / 16
}
```

Now we can run it 100 times from 0 to 10 with steps of 0.10 of time. That means we can start with an array having all the intervals and reduce it as shown below:

```swift
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
```

That's all!

Please also check the derivative functions that can be useful for other scenarios.