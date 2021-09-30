import Foundation

public extension CharacterSet {
    /**
     * Portable Character Set as specified by the Open Group:
     * https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap06.html
     */
    @inlinable static var portable: CharacterSet {
        Iwstb.portableCharacterSet
    }
}
