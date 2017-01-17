//
//  main.swift
//  q0001
//
//  Created by Hoon H. on 2017/01/17.
//  Copyright © 2017 Eonil. All rights reserved.
//

//
// - Source:
//      https://www.careercup.com/question?id=5750868554022912
//
// - Basica idea:
//      For all slots sequentially,
//          Empty current slot first by moving current value to empty slot.
//          Move final value to current slot.
//
// - Time taken:
//      A few days to be familiar.
//      About 3 hours for figuring out with coding.
//

typealias SwappingIndexes = (Int, Int)
typealias Step = SwappingIndexes

func indexOfEmptySlot(in array: [Int]) -> Int {
    return array.index(of: -1)!
}
extension Array where Element: Hashable {
    mutating func swap(_ indexes: (SwappingIndexes)) {
        guard indexes.0 != indexes.1 else { return }
        Swift.swap(&self[indexes.0], &self[indexes.1])
    }
    func makeIndexMap() -> [Element: Int] {
        var map = [Element: Int]()
        for i in 0..<count {
            map[self[i]] = i
        }
        return map
    }
}

func traceStepsV1(_ src: [Int], _ dest: [Int]) -> [Step] {
    assert(Set(src).count == src.count)
    assert(Set(dest).count == dest.count)
    var steps = [Step]()
    var sample = src
    func makeStepsToSwapValues(_ a: Int, _ b: Int) -> [Step] {
        let i0 = sample.index(of: a)!
        let i1 = sample.index(of: b)!
        guard i0 != i1 else { return [] }
        let i2 = sample.index(of: -1)!
        guard i0 != i2 && i1 != i2 else { return [(i0, i1)] }
        return [
            (i0, i2),
            (i1, i0),
            (i2, i1),
        ]
    }
    print(sample)
    for i in 0..<src.count {
        let newSteps = makeStepsToSwapValues(sample[i], dest[i])
        steps.append(contentsOf: newSteps)
        for s in newSteps {
            sample.swap(s)
            print("#\(i): \(s)")
            print(sample)
        }
        print("----")
    }
    assert(sample == dest)
    return steps
}

// Removed unnecessary 3rd swapping.
//
// - Time complexity (worst case):
//      O(n * (n/2 * 3)) = O(n^2)
//
// - Space complexity (worst case):
//      O(n)
//
// - Problem:
//      This code always need to emulate actual stepping to trace steps.
//      I couldn't figure out solution without actual stepping.
//
func traceStepsV2(_ src: [Int], _ dest: [Int]) -> [Step] {
    assert(Set(src).count == src.count)
    assert(Set(dest).count == dest.count)
    var steps = [Step]()
    var sample = src
    print(sample)
    func makeStepsToSwapValues(_ a: Int, _ b: Int) -> [Step] {
        let i0 = sample.index(of: a)!
        let i1 = sample.index(of: b)!
        if i0 == i1 { return [] }
        let i2 = sample.index(of: -1)!
        if i0 == i1 || i1 == i2 { return [(i0, i1)] }
        return [(i0, i2), (i1, i0)]
    }
    for i in 0..<src.count {
        let newSteps = makeStepsToSwapValues(sample[i], dest[i])
        steps.append(contentsOf: newSteps)
        for s in newSteps {
            sample.swap(s)
            print("#\(i): \(s)")
            print(sample)
        }
        print("----")
    }
    assert(sample == dest)
    return steps
}

// Removed unnecessary 3rd swapping.
// Limits lookup range to unplaced data.
// Remove lookup for empty slot. Now it's O(1) after first O(n).
//
// - Time complexity (worst case):
//      O(n * (n/2 * 3)) = O(n^2)
//
// - Space complexity (worst case):
//      O(n)
//
// - Problem:
//      This code always need to emulate actual stepping to trace steps.
//      I couldn't figure out solution without actual stepping.
//
func traceStepsV3(_ src: [Int], _ dest: [Int]) -> [Step] {
    assert(Set(src).count == src.count)
    assert(Set(dest).count == dest.count)
    var steps = [Step]()
    var sample = src
    print(sample)
    var emptySlotIndex = sample.index(of: -1)!
    for i in 0..<src.count {
        func makeStepsToSwapValues(_ a: Int, _ b: Int) -> [Step] {
            let slice = sample[i..<sample.endIndex]
            let i0 = slice.index(of: a)!
            let i1 = sample.index(of: b)!
            if i0 == i1 { return [] }
            let i2 = emptySlotIndex
            if i0 == i1 || i1 == i2 { return [(i0, i1)] }
            return [(i0, i2), (i1, i0)]
        }
        let newSteps = makeStepsToSwapValues(sample[i], dest[i])
        steps.append(contentsOf: newSteps)
        for s in newSteps {
            sample.swap(s)
            print("#\(i): \(s)")
            print(sample)
            // Swapping always involves using of empty slot.
            if sample[s.0] == -1 {
                emptySlotIndex = s.0
            }
            if sample[s.1] == -1 {
                emptySlotIndex = s.1
            }
        }
        print("----")
    }
    assert(sample == dest)
    return steps
}

// O(n*n).
// Can become armortized O(n) if we have bi-map.
func traceStepsV4(_ src: [Int], _ dest: [Int]) -> [Step] {
    assert(Set(src).count == src.count)
    assert(Set(dest).count == dest.count)
    var steps = [Step]()
    steps.reserveCapacity(src.count * 2)
    var sample = src
    // O(n).
    for i in 0..<sample.count {
        if sample[i] == dest[i] { continue }
        let ei = sample.index(of: -1)! // O(n). This search can be eleiminated by tracking empty slot index.
        if i != ei {
            let s = Step(i, ei)
            sample.swap(s)
            print("#\(i): \(s)")
            print(sample)
            steps.append(s)
        }
        let vi = sample.index(of: dest[i])! // O(n). We need a bi-map to eliminate this search.
        if i != vi {
            let s = Step(i, vi)
            sample.swap(s)
            print("#\(i): \(s)")
            print(sample)
            steps.append(s)
        }
        print("----")
    }
    assert(sample == dest)
    return steps
}

//let steps1 = traceStepsV1([1,2,3,-1,4,5], [5,1,-1,3,2,4])
//print(steps1.count)
//let steps2 = traceStepsV2([1,2,3,-1,4,5], [5,1,-1,3,2,4])
//print(steps2.count)
//let steps3 = traceStepsV3([1,2,3,-1,4,5], [5,1,-1,3,2,4])
//print(steps3.count)
let steps4 = traceStepsV4([1,2,3,-1,4,5], [5,1,-1,3,2,4])
print(steps4.count)










