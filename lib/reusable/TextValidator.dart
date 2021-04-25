enum TextValidatorErrors { TooShort, TooLong, ContainsIllegalChars }

class TextValidator {
  static final RegExp numberRegExp = RegExp(r'\d');
  static final RegExp validCharacters = RegExp(r'^[a-zA-Z0-9 ]+$');
  static TextValidatorErrors validate(
      String text, {
        int minLength = 20,
        int maxLength = 100,
        bool numbersAllowed = true,
        bool specialCharsAllowed = true,
      }) {
    if (text.length < minLength) return TextValidatorErrors.TooShort;
    if (text.length > maxLength) return TextValidatorErrors.TooLong;
    if (numberRegExp.hasMatch(text) && !numbersAllowed) return TextValidatorErrors.ContainsIllegalChars;
    if (!validCharacters.hasMatch(text) && !specialCharsAllowed) return TextValidatorErrors.ContainsIllegalChars;
    return null;
  }
}
