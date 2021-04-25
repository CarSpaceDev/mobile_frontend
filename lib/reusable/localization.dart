

import 'EmailValidator.dart';
import 'PasswordValidator.dart';
import 'TextValidator.dart';
import 'localization_en.dart';

final CSLocalization kLocale = CSLocalizationEn();
// final GGLocalization kLocale = GGLocalizationGb();

abstract class CSLocalization {
  String get actionAgreeAndContinue;
  String get allergies;
  String get actionCreatePassword;
  String get orderEmpty;
  String get orderEmptyCaption;
  String get actionOrUseEmail;
  String get actionTapToViewAndReorder;
  String get actionUseAsDefault;
  String get ordersActive;
  String get ordersPast;
  String get ordersRecent;
  String get accountActivateAction;
  String get account;
  String get orderMinValue; //possible unused
  String get addAnother;
  String get orderMinValueCaption;
  String get addressDeliveryArea;
  String get addressFloorAndDoor;
  String get addressDelivery;
  String get phoneNumberAddAction;
  String get addressActionTapSave;
  String get addressValidating;
  String get addressDeliveryZoneCaption;
  String get addressActionRemove;
  String get addressLine2Hint; //unused?
  String get addressActionRemoveConfirmation; //unused?
  String get addressSaved;
  String get addressNoDelivery;
  String get addressNoDeliveryCaption;
  String get completeCombo;
  String get back;
  String get backToTop;
  String get bonusesEarned;
  String get goToCheckout;
  String get continueAction;
  String get checkout;
  String get continueWith;
  String get continueOrder;
  String get continueOrderPrompt;
  String get copyright;
  String get continueWithEmail;
  String get completeComboCaption;
  String get callUsAction;
  String get deliveryTimeAndFee;
  String get pickUpTimeAndFee;
  String get cardNew;
  String get cardAdd;
  String get cardHolder;
  String get customerDetails;
  String get deliveryFee;
  String get deliveryTo;
  String get checkValidation;
  String get accept;
  String get reject;
  String get someProductsRemoved;
  String get discoverLocations;
  String get extra;
  String get earnAction;
  String get someProductsRemovedCaption;
  String get edit;
  String get editProfile;
  String get email;
  String get emailForReceipt;
  String get forgotPassword;
  String get insufficientFundsCaption;
  String get home;
  String get insufficientFunds;
  String get item;
  String get items;
  String get kContinue;
  String get marketingAgreeAction;
  String get logout;
  String get deleteAccount;
  String get deleteAccountBody1;
  String get deleteAccountBody2;
  String get termsOfServiceAgreeAction;
  String get noteForKitchenCaption;
  String get menu;
  String get noteForCourierCaption;
  String get name;
  String get noteForCourier;
  String get noteForCourierAction;
  String get noteForKitchen;
  String get noteForKitchenAction;
  String get noComment;
  String get open;
  String get orWhenSoldOut;
  String get order;
  String get orders;
  String get orderFood;
  String get ok;
  String get orderAddToAction;
  String get orderUpdateAction;
  String get orderSummary;
  String get other;
  String get passwordUpdate;
  String get orderCancelAction;
  String get passwordForgot;
  String get passwordForgotSub;
  String get orderCancelActionCaption;
  String get passwordEnter;
  String get payWith;
  String get passwordExisting;
  String get passwordNew;
  String get pay;
  String get payment;
  String get paymentMethods;
  String get paymentMethodAdd;
  String get paymentMethodsSaved;
  String get paymentOptionAction;
  String get paymentNewCardAction;
  String get permissions;
  String get permissionsLocationPushNotif;
  String get permissionsLocationPushNotifH1;
  String get permissionsLocationPushNotifH2;
  String get phoneNumber;
  String get pickupFee;
  String get pickupFrom;
  String get pointsShopInfo;
  String get pointsShopInfoBody;
  String get policies;
  String get promotionalProducts;
  String get pickupLocations;
  String get phoneNumberMissing;
  String get promptBackToTop;
  String get promptAccountActivateInstructions;
  String get promptPasswordLimits;
  String get variationAdded;
  String get chooseCombinationAction;
  String get variationsAdded;
  String get reorder;
  String get pointShopComingSoon;
  String get remove;
  String get reset;
  String get save;
  String get saveNewCard;
  String get updateCustomerDetails;
  String get pointsReceived;
  String get signIn;
  String get signUp;
  String get submit;
  String get tapToRemoveIngredients;
  String get termsAndConditions;
  String get termsAndConditionsH1;
  String get termsAndConditionsH2;
  String get timeSlot;
  String get timeSlotExpired;
  String get timeSlotExpiredPrompt;
  String get subtotal;
  String get total;
  String get vat25;
  String get work;
  String get stampsReceived;
  String get welcome;
  String get chooseDayAction;
  String get yourName;
  String get mailArrived;

  //LOYALTY
  String get yourMerchPoints;
  String get yourStampCard;
  String get cards;
  String get howToUseStamps;
  String get faqContent;

  //FEEDBACK STRINGS
  String get passwordMismatch;
  String get error;
  String get tooLong;
  String get tooShort;
  String get containsIllegalChars;
  String get missingCharType;
  String get emailError;
  String get needAddress;
  String get needStore;
  String get noStoresAvailable;
  String get noOrderDatesAvailable;
  String get noTimeSlotsAvailable;
  String get notImplemented;
  String get missing;
  String get cvvValidationMessage;
  String get dateValidationMessage;
  String get numberValidationMessage;
  String get closed;
  String get errorCreatingCard;
  String get errorItemsInOrderUnavailable;
  String get errorItemsInOrderUnavailableSub;
  String get wrongLogin;
  String get emailTaken;

  //PAYMENT OPTIONS
  String get paymentOptionApplePay;
  String get paymentOptionGooglePay;

  //Order Types
  String get delivery;
  String get eatIn;
  String get pickUp;
  String get blank;

  //Order Status Tiles
  String get creating;
  String get paymentNeedsAction;
  String get cancelled;
  String get pendingApproval;
  String get live;
  String get ready;
  String get delivering;
  String get done;
  String get rejected;
  String get refunded;

  //Order Short Status Tiles
  String get pendingShort;
  String get readyPickup;
  String get deliveringShort;
  String get liveShort;
  String get late;

  //Order Status Prompt
  String get orderPromptCreating;
  String get orderPromptPaymentNeedsAction;
  String get orderPromptCancelled;
  String get orderPromptPendingApproval;
  String get orderPromptLive;
  String get orderPromptReady;
  String get orderPromptDelivering;
  String get orderPromptDone;
  String get orderPromptError;
  String get orderPromptRejected;
  String get orderPromptRefunded;

  //Relative days
  String get daysAgo;
  String get yesterday;
  String get today;
  String get tomorrow;
  String get kIn;
  String get days;

  //Order Badge
  String get oBDelivery;
  String get oBLate;

  //Credit Card
  String get number;
  String get expiredDate;
  String get cvv;
  String get mmyy;

  // String orderType(OrderType orderType) {
  //   switch (orderType) {
  //     case OrderType.Delivery:
  //       return delivery;
  //     case OrderType.EatIn:
  //       return eatIn;
  //     case OrderType.PickUp:
  //       return pickUp;
  //     default:
  //       return blank;
  //   }
  // }
  //
  // String orderStatusTitle(int status, OrderType orderType) {
  //   switch (status) {
  //     case Status.creating:
  //       return creating;
  //     case Status.paymentNeedsAction:
  //       return paymentNeedsAction;
  //     case Status.cancelled:
  //       return cancelled;
  //     case Status.pendingApproval:
  //       return pendingApproval;
  //     case Status.live:
  //       return live;
  //     case Status.ready:
  //       if (orderType == OrderType.Delivery) return delivering;
  //       return ready;
  //     case Status.delivering:
  //       return delivering;
  //     case Status.done:
  //       return done;
  //     case Status.rejected:
  //       return rejected;
  //     case Status.refunded:
  //       return refunded;
  //     default:
  //       return blank;
  //   }
  // }

  // String timeSlotTipTitle(String term);
  // String timeSlotTipLine1(String term, String duration);
  // String timeSlotTipLine2(String term);
  // String timeSlotTipLine3(String term);
  //
  // String orderStatusShort(int status, OrderType orderType) {
  //   switch (status) {
  //     case Status.pendingApproval:
  //       return pendingShort;
  //     case Status.ready:
  //       if (orderType == OrderType.Delivery) return deliveringShort;
  //       return readyPickup;
  //     case Status.live:
  //       if (orderType == OrderType.Delivery) return deliveringShort;
  //       if (orderType == OrderType.PickUp) return liveShort;
  //       return liveShort;
  //     case Status.delivering:
  //       return deliveringShort;
  //     default:
  //       return blank;
  //   }
  // }
  //
  // String orderStatusBody(int status, OrderType orderType) {
  //   switch (status) {
  //     case Status.creating:
  //       return orderPromptCreating;
  //     case Status.paymentNeedsAction:
  //       return orderPromptPaymentNeedsAction;
  //     case Status.cancelled:
  //       return orderPromptCancelled;
  //     case Status.pendingApproval:
  //       return orderPromptPendingApproval;
  //     case Status.live:
  //       return orderPromptLive;
  //     case Status.ready:
  //       if (orderType == OrderType.Delivery) return orderPromptDelivering;
  //       return orderPromptReady;
  //     case Status.delivering:
  //       return orderPromptDelivering;
  //     case Status.done:
  //       return orderPromptDone;
  //     case Status.rejected:
  //       return orderPromptRejected;
  //     case Status.refunded:
  //       return orderPromptRefunded;
  //     default:
  //       return blank;
  //   }
  // }

  String numberXItems(int qty) {
    return '${qty}X ${qty > 1 ? items.toUpperCase() : item.toUpperCase()}';
  }

  String dayRelativeToNow(int daysFromNow) {
    String result;
    if (daysFromNow < -1) result = "${-daysFromNow} $daysAgo";
    if (daysFromNow == -1) result = yesterday;
    if (daysFromNow == 0) result = today;
    if (daysFromNow == 1) result = tomorrow;
    if (daysFromNow > 1) result = "$kIn $daysFromNow $days";
    return result;
  }

  String emailValidatorErrors(EmailValidatorErrors error) {
    if (error == null)
      return null;
    else
      return emailError.toUpperCase();
  }

  String passwordValidatorErrors(PasswordValidatorErrors error,
      {int min, int max}) {
    if (error == PasswordValidatorErrors.TooLong)
      return "$tooLong ${max ?? ''} characters".toUpperCase();
    if (error == PasswordValidatorErrors.TooShort)
      return "$tooShort ${min ?? ''} characters".toUpperCase();
    if (error == PasswordValidatorErrors.MissingCharType)
      return missingCharType.toUpperCase();
    return null;
  }

  String textValidatorErrors(TextValidatorErrors error, {int min, int max}) {
    if (error == TextValidatorErrors.TooLong)
      return "$tooLong ${max ?? ''} characters".toUpperCase();
    if (error == TextValidatorErrors.TooShort)
      return "$tooShort ${min ?? ''} characters".toUpperCase();
    if (error == TextValidatorErrors.ContainsIllegalChars)
      return containsIllegalChars.toUpperCase();
    return null;
  }
}
