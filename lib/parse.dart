class ParsedID {
  final String? address;
  final String? idType;

  ParsedID({this.address = '', required this.idType});
}

ParsedID parsePhilID(String text) {
  final lines = text.split("\n").map((l) => l.trim()).toList();

  int addressIndex = lines.indexWhere(
    (l) =>
        l.toUpperCase().contains("TIRAHAN") ||
        l.toUpperCase().contains("ADDRESS"),
  );

  String? address;

  if (addressIndex != -1) {
    for (int i = addressIndex + 1; i < lines.length; i++) {
      final line = lines[i];

      // Skip headers / irrelevant lines
      if (line.isEmpty ||
          line.toUpperCase().contains("REPUBLIKA") ||
          line.toUpperCase().contains("PILIPINAS") ||
          line.toUpperCase().contains("PAMBANSANG") ||
          line.toUpperCase().contains("PHILIPPINE") ||
          line.toUpperCase().contains("CARD") ||
          line.toUpperCase().contains("APELYIDO") ||
          line.toUpperCase().contains("PANGALAN") ||
          line.toUpperCase().contains("BIRTH") ||
          line.toUpperCase().contains("KAPANGANAKAN") ||
          line.toUpperCase().contains("DATE") ||
          line.toUpperCase().contains("PHL")) {
        continue;
      }

      // 🚫 Skip date formats (month + day + year)
      if (RegExp(
        r'(JANUARY|FEBRUARY|MARCH|APRIL|MAY|JUNE|JULY|AUGUST|SEPTEMBER|OCTOBER|NOVEMBER|DECEMBER)\s+\d{1,2},\s+\d{4}',
        caseSensitive: false,
      ).hasMatch(line)) {
        continue;
      }

      // ✅ Detect address (must contain both digits + letters, not a date)
      final hasDigits = RegExp(r'\d').hasMatch(line);
      final hasLetters = RegExp(r'[A-Za-z]').hasMatch(line);

      if (hasDigits && hasLetters) {
        address = line;

        // Merge continuation lines
        int j = i + 1;
        while (j < lines.length) {
          final nextLine = lines[j];

          // Stop if line looks like a header or date
          if (nextLine.toUpperCase().contains("PHL") ||
              nextLine.toUpperCase().contains("DATE") ||
              nextLine.toUpperCase().contains("APELYIDO") ||
              RegExp(
                r'(JANUARY|FEBRUARY|MARCH|APRIL|MAY|JUNE|JULY|AUGUST|SEPTEMBER|OCTOBER|NOVEMBER|DECEMBER)\s+\d{1,2},\s+\d{4}',
                caseSensitive: false,
              ).hasMatch(nextLine)) {
            break;
          }

          address = "${address!} ${nextLine.trim()}";
          j++;
        }
        break;
      }
    }
  }

  return ParsedID(idType: "Philippine ID", address: address);
}

ParsedID parseDriversLicense(String text) {
  final addressRegex = RegExp(r'ADDRESS\s*:?\s*(.+)');

  final addressMatch = addressRegex.firstMatch(text);

  return ParsedID(
    address: addressMatch?.group(1)?.trim() ?? "",
    idType: "Driver’s License",
  );
}

ParsedID parsePassport(String text) {
  // Address is not in passport, so user must input manually
  return ParsedID(address: "", idType: "Passport");
}

ParsedID parseVotersID(String text) {
  final addressRegex = RegExp(r'ADDRESS\s*:?\s*(.+)');
  final addressMatch = addressRegex.firstMatch(text);

  return ParsedID(
    address: addressMatch?.group(1)?.trim() ?? "",
    idType: "Voter’s ID",
  );
}

String detectIDType(String text) {
  final upperText = text.toUpperCase();

  if (upperText.contains("PHILIPPINE IDENTIFICATION CARD") ||
      upperText.contains("PAMBANSANG PAGKAKAKILANLAN")) {
    return "PhilID";
  } else if (upperText.contains("DRIVER") && upperText.contains("LICENSE")) {
    return "DriverLicense";
  } else if (upperText.contains("POSTAL ID")) {
    return "PostalID";
  } else if (upperText.contains("STUDENT ID") ||
      upperText.contains("SCHOOL ID")) {
    return "SchoolID";
  } else if (upperText.contains("PASSPORT")) {
    return "Passport";
  }
  return "Unknown";
}

ParsedID parseID(String text) {
  final idType = detectIDType(text);

  switch (idType) {
    case "PhilID":
      return parsePhilID(text);
    case "DriverLicense":
      return parseDriversLicense(text);
    case "Passport":
      return parsePassport(text);
    default:
      return ParsedID(address: '', idType: "Unknown");
  }
}
