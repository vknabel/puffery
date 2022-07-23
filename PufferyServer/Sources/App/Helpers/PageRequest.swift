import Fluent

extension PageRequest {
    static var standard: PageRequest {
        PageRequest(page: 1, per: 20)
    }
}