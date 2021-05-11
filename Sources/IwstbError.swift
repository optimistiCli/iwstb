import Foundation

/**
 An error that is aware of its raison d'etre and is capable of augmenting it with contextual insights.

 # Intended use

 ## Create a domain specific implementation

 This is strictly optional but generally a good practice.
 ```
 class SomeAcitivityError: Iwstb.Error {}

 class UnicornError: SomeAcitivityError {
    internal init() { super.init(because: "Unicorn ran away") }
 }

 class PuniError: SomeAcitivityError {
    internal init() { super.init(because: "Punies attacked") }
 }
 ```

 ## Throw it
 ```
 class SomeActivity {
    …
    public func doSmth() throws {
        …
        guard let uni = _unicorn else {
            throw UnicornError()
        }
        …
    }
    …
 }
 ```

 ## Augment the error in enclosing context
 ```
 func performActivities() throws {
    …
    let activity = SomeActivity()
    activity.unicorn = _unicornProvider.getUnicorn()
    do {
        try activity.doSmth()
    } catch let iwstbError as IwstbError {
        iwstbError.augment("with a unicorn from \(_unicornProvider.name)")
        throw iwstbError
    }
 }
 ```

 ## Fail gracefully
 ```
 // main.swift
 …
 fileprivate func main() -> Int32 {
     …
     do {
        try performActivities()
     } catch {
         return Iwstb.brag(error)
     }
 }

 exit(main())
 ```
  */
public protocol IwstbError: Error {
    /**
     The message that explains why this particular error was thrown.
     */
    var reason: String { get }

    /**
     Adds to the error's `reason` some details, that were not available in the context where it was thrown.

     - Parameters:
       - aAny: Arbitrary, implementation-specific information about the error.
     */
    func augment(_ aAny: Any)
}

public extension Iwstb {
    // MARK: Errors base

    /**
     Basic implementation of the `IwstbError` protocol.

     Intended as super-class for domain-specific errors. But it can be used as-is too.

     Please see `IwstbError` for more docs.
     */
    open class Error: IwstbError {
        private var _reason: String

        public var reason: String {
            get {
                return _reason
            }
        }

        /**
         Creates an error compliant with `IwstbError` setting its reason.

         - Parameters:
           - aReason: A message describing the reason why this particular error was thrown.
         */
        public init(because aReason: String) {
            _reason = aReason
        }

        /**
         Appends the error's `reason` with extra message.

         - Parameters:
           - aAny: Additional message text
         */
        public func augment(_ aAny: Any) {
            _reason += " " + "\(aAny)".trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
