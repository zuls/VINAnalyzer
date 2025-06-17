//
//  VINValidator.swift
//  VINAnalyzer
//
//  Created by Zularbine Kamal on 6/13/25.
//

import Foundation

struct VINValidator {
    // VIN transliteration values for check digit calculation
    private static let transliterationValues: [Character: Int] = [
        "A": 1, "B": 2, "C": 3, "D": 4, "E": 5, "F": 6, "G": 7, "H": 8,
        "J": 1, "K": 2, "L": 3, "M": 4, "N": 5, "P": 7, "R": 9, "S": 2,
        "T": 3, "U": 4, "V": 5, "W": 6, "X": 7, "Y": 8, "Z": 9,
        "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "0": 0
    ]
    
    // Weight factors for VIN check digit calculation
    private static let weightFactors = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2]
    
    static func extractVINFromText(_ text: String) -> String? {
        let cleanText = text.uppercased().replacingOccurrences(of: " ", with: "")
        
        // Look for 17-character sequences that could be VINs
        let vinPattern = #"[A-HJ-NPR-Z0-9]{17}"#
        let regex = try? NSRegularExpression(pattern: vinPattern)
        let range = NSRange(location: 0, length: cleanText.count)
        
        let matches = regex?.matches(in: cleanText, range: range) ?? []
        
        for match in matches {
            if let matchRange = Range(match.range, in: cleanText) {
                let potentialVIN = String(cleanText[matchRange])
                if isValidVIN(potentialVIN) {
                    return potentialVIN
                }
            }
        }
        
        return nil
    }
    
    static func isValidVIN(_ vin: String) -> Bool {
        // Basic format validation
        guard vin.count == 17 else { return false }
        
        let uppercasedVIN = vin.uppercased()
        
        // Check for invalid characters (I, O, Q are not allowed in VINs)
        let invalidChars = CharacterSet(charactersIn: "IOQ")
        guard uppercasedVIN.rangeOfCharacter(from: invalidChars) == nil else { return false }
        
        // Validate character set (alphanumeric only)
        let allowedChars = CharacterSet.alphanumerics
        guard uppercasedVIN.rangeOfCharacter(from: allowedChars.inverted) == nil else { return false }
        
        // Additional validation: First character should be a letter or number 1-5
        let firstChar = uppercasedVIN.first!
        let validFirstChars = CharacterSet(charactersIn: "12345ABCDEFGHJKLMNPRSTUVWXYZ")
        guard validFirstChars.contains(firstChar.unicodeScalars.first!) else { return false }
        
        // Perform check digit validation
        return validateCheckDigit(uppercasedVIN)
    }
    
    private static func validateCheckDigit(_ vin: String) -> Bool {
        let vinArray = Array(vin)
        var sum = 0
        
        for (index, char) in vinArray.enumerated() {
            guard let value = transliterationValues[char] else { return false }
            sum += value * weightFactors[index]
        }
        
        let remainder = sum % 11
        let checkDigit = remainder == 10 ? "X" : String(remainder)
        
        return String(vinArray[8]) == checkDigit
    }
    
    static func formatVIN(_ vin: String) -> String {
        return vin.uppercased()
    }
}
