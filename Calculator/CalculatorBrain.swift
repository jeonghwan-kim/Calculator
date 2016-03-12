//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Chris on 3/11/16.
//  Copyright © 2016 WePlanet. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double) // function, squar
        case BinaryOperation(String, (Double, Double) -> Double) // function +, -, *, /
        
        var description: String { // for debugging print
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]() // Array<Op>()
    
    private var knownOps = [String:Op]() // ar knownOps = Dictionary<String, Op>()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("-", {$1 - $0}))
        learnOp(Op.BinaryOperation("÷", {$1 / $0}))
    }
    
    // return Double or Rest of stack. Recursive
    private func evaluate(var ops: [Op]) -> (result: Double?, remaingingOps: [Op]) {
        if !ops.isEmpty {
            let op = ops.removeLast() // let is immutable, readonly
            let remainingOps = ops // copy of this, var is immutable
            print("evaluate. op = \(op)")
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation): // _ is that I don't care
                print("unaryOperation")
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remaingingOps)
                }
            case .BinaryOperation(_, let operation):
                print("binaryOperation")
                let op1Evaluation = evaluate(remainingOps)
                if let  operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remaingingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remaingingOps)
                    }
                }
            }
        }
        return (nil, ops)
        
    }
    
    func evaluate() -> Double? { // return Double or nil
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
}