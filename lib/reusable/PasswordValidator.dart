enum PasswordValidatorErrors { TooShort, TooLong, MissingCharType }

class PasswordValidator {
  static final RegExp charRegExp = RegExp(r'^[A-Za-z]+$');
  static final RegExp numberRegExp = RegExp(r'\d');
  static final RegExp charUpperRegExp = RegExp(r'^[A-Z]+$');
  static final RegExp charLowerRegExp = RegExp(r'^[a-z]+$');
  //used for negative check
  static final RegExp specialRegExp = RegExp(r'^[a-zA-Z0-9]+$');
  static PasswordValidatorErrors validate(
      String password, {
        int minLength = 6,
        int maxLength,
        bool mustContainChars = false,
        bool mustContainNums = false,
        bool mustContainUpperAndLowerCase = false,
        bool mustContainSpecialChars = false,
      }) {
    if (password.length < minLength) {
      print('Failed minLength');
      return PasswordValidatorErrors.TooShort;
    }
    if (maxLength != null) {
      if (password.length > maxLength) {
        print('Failed maxLength');
        return PasswordValidatorErrors.TooLong;
      }
    }
    print('passed Length checks');
    if (mustContainChars && mustContainNums) {
      if (!specialRegExp.hasMatch(password)) {
        print('Failed mustContain Chars and Nums');
        return PasswordValidatorErrors.MissingCharType;
      }

      print('Passed mustContain Chars and Nums');
    }
    if (mustContainNums && !numberRegExp.hasMatch(password)) {
      print('Failed mustContainNums');
      return PasswordValidatorErrors.MissingCharType;
    }
    print('Passed mustContainNums');
    if (mustContainSpecialChars && specialRegExp.hasMatch(password)) {
      print('Failed mustContainSpecial');
      return PasswordValidatorErrors.MissingCharType;
    }
    print('Passed mustContainSpecial');
    if (mustContainChars && !charRegExp.hasMatch(password)) {
      print('Failed mustContainChars');
      return PasswordValidatorErrors.MissingCharType;
    }
    if (mustContainUpperAndLowerCase && !charRegExp.hasMatch(password)) {
      return PasswordValidatorErrors.MissingCharType;
    }
    return null;
  }
}
