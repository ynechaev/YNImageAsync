import Foundation

class DoublyLinkedList<Element> {
    class Node {
        var value: Element
        var next: Node?
        weak var previous: Node?

        init(value: Element) {
            self.value = value
        }
    }

    private(set) var head: Node?
    private(set) var tail: Node?

    func insertAtFront(_ value: Element) -> Node {
        let newNode = Node(value: value)
        if let head = head {
            newNode.next = head
            head.previous = newNode
        } else {
            tail = newNode
        }
        head = newNode
        return newNode
    }

    func moveToFront(_ node: Node) {
        guard node !== head else { return }
        remove(node)
        node.next = head
        head?.previous = node
        head = node
    }

    func remove(_ node: Node) {
        node.previous?.next = node.next
        node.next?.previous = node.previous

        if node === head {
            head = node.next
        }
        if node === tail {
            tail = node.previous
        }
        
        node.next = nil
        node.previous = nil
    }

    func removeAll() {
        head = nil
        tail = nil
    }
}
