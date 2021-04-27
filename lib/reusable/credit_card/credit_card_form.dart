import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/reusable/TextValidator.dart';
import 'package:carspace/reusable/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'credit_card_model.dart';
import 'credit_card_widget.dart';

class CreditCardForm extends StatefulWidget {
  const CreditCardForm(
      {Key key,
      this.cardNumber,
      this.expiryDate,
      this.cardHolderName,
      this.cvvCode,
      this.obscureCvv = false,
      this.obscureNumber = false,
      @required this.onCreditCardModelChange,
      this.themeColor,
      this.textColor = Colors.black,
      this.cursorColor,
      this.cardHolderDecoration = const InputDecoration(
        labelText: 'Card holder',
      ),
      this.cardNumberDecoration = const InputDecoration(
        labelText: 'Card number',
        hintText: 'XXXX XXXX XXXX XXXX',
      ),
      this.expiryDateDecoration = const InputDecoration(
        labelText: 'Expired Date',
        hintText: 'MM/YY',
      ),
      this.cvvCodeDecoration = const InputDecoration(
        labelText: 'CVV',
        hintText: 'XXX',
      ),
      @required this.formKey,
      this.cvvValidationMessage = 'Please input a valid CVV',
      this.dateValidationMessage = 'Please input a valid date',
      this.numberValidationMessage = 'Please input a valid number',
      this.onTap,
      this.submitText = "SUBMIT"})
      : super(key: key);
  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvvCode;
  final String cvvValidationMessage;
  final String dateValidationMessage;
  final String numberValidationMessage;
  final void Function(CreditCardModel) onCreditCardModelChange;
  final Color themeColor;
  final Color textColor;
  final Color cursorColor;
  final bool obscureCvv;
  final bool obscureNumber;
  final GlobalKey<FormState> formKey;
  final InputDecoration cardNumberDecoration;
  final InputDecoration cardHolderDecoration;
  final InputDecoration expiryDateDecoration;
  final InputDecoration cvvCodeDecoration;
  final Function onTap;
  final String submitText;

  @override
  _CreditCardFormState createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  String cardNumber;
  String expiryDate;
  String cardHolderName;
  String cvvCode;
  bool isCvvFocused = false;
  Color themeColor;
  bool validationRequested = false;

  void Function(CreditCardModel) onCreditCardModelChange;
  CreditCardModel creditCardModel;

  final MaskedTextController _cardNumberController = MaskedTextController(mask: '0000 0000 0000 0000');
  final TextEditingController _expiryDateController = MaskedTextController(mask: '00/00');
  final TextEditingController _cardHolderNameController = TextEditingController();
  final TextEditingController _cvvCodeController = MaskedTextController(mask: '0000');

  FocusNode cvvFocusNode = FocusNode();
  FocusNode cardNumberNode = FocusNode();
  FocusNode expiryDateNode = FocusNode();
  FocusNode cardHolderNode = FocusNode();

  void textFieldFocusDidChange() {
    creditCardModel.isCvvFocused = cvvFocusNode.hasFocus;
    onCreditCardModelChange(creditCardModel);
  }

  void createCreditCardModel() {
    cardNumber = widget.cardNumber ?? '';
    expiryDate = widget.expiryDate ?? '';
    cardHolderName = widget.cardHolderName ?? '';
    cvvCode = widget.cvvCode ?? '';

    creditCardModel = CreditCardModel(cardNumber, expiryDate, cardHolderName, cvvCode, isCvvFocused);
  }

  @override
  void initState() {
    super.initState();

    createCreditCardModel();

    onCreditCardModelChange = widget.onCreditCardModelChange;

    cvvFocusNode.addListener(textFieldFocusDidChange);

    _cardNumberController.addListener(() {
      setState(() {
        cardNumber = _cardNumberController.text;
        creditCardModel.cardNumber = cardNumber;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _expiryDateController.addListener(() {
      setState(() {
        expiryDate = _expiryDateController.text;
        creditCardModel.expiryDate = expiryDate;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _cardHolderNameController.addListener(() {
      setState(() {
        cardHolderName = _cardHolderNameController.text;
        creditCardModel.cardHolderName = cardHolderName;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _cvvCodeController.addListener(() {
      setState(() {
        cvvCode = _cvvCodeController.text;
        creditCardModel.cvvCode = cvvCode;
        onCreditCardModelChange(creditCardModel);
      });
    });
  }

  @override
  void dispose() {
    cardHolderNode.dispose();
    cvvFocusNode.dispose();
    expiryDateNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    themeColor = widget.themeColor ?? Theme.of(context).primaryColor;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      child: Form(
        key: widget.formKey,
        child: CSTile(
          dottedDivider: false,
          child: Column(
            children: <Widget>[
              CSTile(
                dottedDivider: false,
                padding: EdgeInsets.only(bottom: 8),
                child: TextFormField(
                  obscureText: widget.obscureNumber,
                  controller: _cardNumberController,
                  cursorColor: widget.cursorColor ?? themeColor,
                  onEditingComplete: () {
                    FocusScope.of(context).requestFocus(expiryDateNode);
                  },
                  onChanged: (t) {
                    if (validationRequested) widget.formKey.currentState.validate();
                  },
                  style: csStyle.headline3.copyWith(color: widget.textColor, fontWeight: FontWeight.w900),
                  decoration: widget.cardNumberDecoration,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (String value) {
                    if (value.isEmpty || value.length < 16) {
                      return widget.numberValidationMessage;
                    }
                    return null;
                  },
                ),
              ),
              CSTile(
                dottedDivider: false,
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: TextFormField(
                          controller: _expiryDateController,
                          cursorColor: widget.cursorColor ?? themeColor,
                          focusNode: expiryDateNode,
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(cvvFocusNode);
                          },
                          onChanged: (t) {
                            if (validationRequested) widget.formKey.currentState.validate();
                          },
                          style: csStyle.headline3.copyWith(color: widget.textColor, fontWeight: FontWeight.w900),
                          decoration: widget.expiryDateDecoration,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          validator: (String value) {
                            if (value.isEmpty) {
                              return widget.dateValidationMessage;
                            }

                            final DateTime now = DateTime.now();
                            final List<String> date = value.split(RegExp(r'/'));
                            final int month = int.parse(date.first);
                            final int year = int.parse('20${date.last}');
                            final DateTime cardDate = DateTime(year, month);

                            if (cardDate.isBefore(now) || month > 12 || month == 0) {
                              return widget.dateValidationMessage;
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(
                          left: 8,
                        ),
                        child: TextFormField(
                          obscureText: widget.obscureCvv,
                          focusNode: cvvFocusNode,
                          controller: _cvvCodeController,
                          cursorColor: widget.cursorColor ?? themeColor,
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(cardHolderNode);
                          },
                          style: csStyle.headline3.copyWith(color: widget.textColor, fontWeight: FontWeight.w900),
                          decoration: widget.cvvCodeDecoration,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          onChanged: (String text) {
                            if (validationRequested) widget.formKey.currentState.validate();
                            setState(() {
                              cvvCode = text;
                            });
                          },
                          validator: (value) {
                            if (value.isEmpty || value.length < 3) {
                              return widget.cvvValidationMessage;
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CSTile(
                dottedDivider: false,
                padding: EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  controller: _cardHolderNameController,
                  cursorColor: widget.cursorColor ?? themeColor,
                  focusNode: cardHolderNode,
                  style: csStyle.headline3.copyWith(color: widget.textColor, fontWeight: FontWeight.w900),
                  decoration: widget.cardHolderDecoration,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  onChanged: (t) {
                    if (validationRequested) widget.formKey.currentState.validate();
                  },
                  onEditingComplete: () {
                    onCreditCardModelChange(creditCardModel);
                    cardHolderNode.unfocus();
                  },
                  validator: (value) {
                    return kLocale.textValidatorErrors(TextValidator.validate(value, minLength: 3, maxLength: 20),
                        min: 3, max: 20);
                  },
                ),
              ),
              Center(
                child: TextButton(
                  child: CSText(
                    kLocale.cardAdd,
                    textColor: TextColor.Primary,
                    textType: TextType.H3,
                  ),
                  onPressed: () async {
                    validationRequested = true;
                    widget.onTap();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
