import Foundation

extension String
{
    func split(every length:Int) -> [Substring] {
        guard length > 0 && length < count else { return [suffix(from:startIndex)] }

        return (0 ... (count - 1) / length).map { dropFirst($0 * length).prefix(length) }
    }

    func split(backwardsEvery length:Int) -> [Substring] {
        guard length > 0 && length < count else { return [suffix(from:startIndex)] }

        return (0 ... (count - 1) / length).map { dropLast($0 * length).suffix(length) }.reversed()
    }
}

class BigInteger {
    //let string: String
    static let UpperBound: UInt64 = 1000000000
    let array: [UInt32] //UINT32_MAX 4294967295;
                                    //999999999
    init(raw: String) {
        //string = raw
        array = raw.split(backwardsEvery: 9).map{ UInt32($0) ?? 0 }
    }
    
    init(num: [UInt32]) {
        array = num
    }
    
    func multiply(scale: UInt32) -> BigInteger {
        
        var result = [UInt32]()
        var extra = UInt32(0)
        for i in 0..<array.count {
            let index = array.count - 1 - i
            let tmp:UInt64 = UInt64(extra) + UInt64(scale) * UInt64(array[index])
            
            if tmp >= BigInteger.UpperBound {
                
                extra = UInt32(tmp / BigInteger.UpperBound)
                let remain = tmp % BigInteger.UpperBound
                
                result.insert(UInt32(remain), at: 0)
            } else {
                result.insert(UInt32(tmp), at: 0)
            }
            extra = 0
        }
        
        if 0 != extra {
            result.insert(UInt32(extra), at: 0)
        }
        
        return BigInteger(num: result)
    }
    
    func string() -> String {
        
        var result = String(array[0])
        for i in 1..<array.count {
            result += String(format: "%09d", array[i])
        }
        
        return result
    }
}

class ACNode
{
    var endMark: Bool
    var failLink: ACNode?

    var children: [ACNode?]
    
    init() {
        endMark = false
        failLink = nil
        
        children = [ACNode?](repeating: nil, count: 10)
    }
}

func buildACTree(power: UInt32) -> ACNode {
    
    let root = ACNode()
    var bigTwo = BigInteger(raw: "1")
    
    for _ in 0...power {
        
        let string = bigTwo.string()
        bigTwo = bigTwo.multiply(scale:2)
        
        var currentNode = root;
        
        for char in string {
            let index = char.unicodeScalars.first!.value - UnicodeScalar("0").value
            let childIndex = Int(index)
            
            if let cachedNode = currentNode.children[childIndex] {
                currentNode = cachedNode
                continue
            }
            
            let newNode = ACNode()
            currentNode.children[childIndex] = newNode
            currentNode = newNode
        }
        
        currentNode.endMark = true
    }
    
    buildFailLink(root: root)
    return root
}

func buildFailLink(root: ACNode) {
    
    var fifo = [ACNode]()
    
    for case let child? in root.children {
        child.failLink = root
        fifo.append(child)
    }
    
    while (fifo.count > 0) {
        let sampleNode = fifo.removeFirst()
        let sampleFailNode = sampleNode.failLink
        
        for (index, child) in sampleNode.children.enumerated() where child != nil {
            
            var testFailNode = sampleFailNode
            
            while testFailNode != nil {
                if nil != testFailNode!.children[index] {
                    child!.failLink = testFailNode!.children[index]
                    break
                }
                testFailNode = testFailNode?.failLink
            }
            if nil == testFailNode {
                child!.failLink = root
            }
            
            fifo.append(child!)
        }
    }
}

func matching(root: ACNode, text: String) -> Int {
    
    var result = 0
    var p: ACNode? = root
    let zvalue = UnicodeScalar("0").value
    
    for char in text {
        
        let number = Int(char.unicodeScalars.first!.value - zvalue)
        
        while (nil == p?.children[number] && p !== root) {
            p = p?.failLink
        }
        p = p?.children[number]
        if nil == p {
            p = root
        }
        
        var testNode: ACNode? = p
        while(testNode !== root) {
        
            if (testNode?.endMark ?? false) {
                result += 1
            }
            testNode = testNode?.failLink
        }
    }
    
    return result
}

let tree = buildACTree(power: 800)

//let c1 = matching(root: tree, text: "2222222") // 7
//let c2 = matching(root: tree, text: "24256") // 4
//let c3 = matching(root: tree, text: "65536") // 1
//let c4 = matching(root: tree, text: "023223") // 4
//let c5 = matching(root: tree, text: "33579") // 0
//let c6 = matching(root: tree, text: "32") // 2

func twoTwo(a: String) -> Int {
    /*
     * Write your code here.
     */
    let c = matching(root: tree, text: a)
    return Int(c)
}

freopen("testcases/input08.txt", "r", stdin)

//let stdout = ProcessInfo.processInfo.environment["OUTPUT_PATH"]!
//FileManager.default.createFile(atPath: stdout, contents: nil, attributes: nil)
//let fileHandle = FileHandle(forWritingAtPath: stdout)!

guard let t = Int((readLine()?.trimmingCharacters(in: .whitespacesAndNewlines))!)
else { fatalError("Bad input") }

for _ in 1...t {
    guard let a = readLine() else { fatalError("Bad input") }

    let result = twoTwo(a: a)
    print(String(result) + "\n")

    //fileHandle.write(String(result).data(using: .utf8)!)
    //fileHandle.write("\n".data(using: .utf8)!)
}
