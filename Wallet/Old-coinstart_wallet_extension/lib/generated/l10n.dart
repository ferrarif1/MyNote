// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Unlock`
  String get Unlock {
    return Intl.message(
      'Unlock',
      name: 'Unlock',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password?`
  String get Forgot_Password {
    return Intl.message(
      'Forgot Password?',
      name: 'Forgot_Password',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your password`
  String get Please_enter_your_password {
    return Intl.message(
      'Please enter your password',
      name: 'Please_enter_your_password',
      desc: '',
      args: [],
    );
  }

  /// `Buy`
  String get Buy {
    return Intl.message(
      'Buy',
      name: 'Buy',
      desc: '',
      args: [],
    );
  }

  /// `Sell`
  String get Sell {
    return Intl.message(
      'Sell',
      name: 'Sell',
      desc: '',
      args: [],
    );
  }

  /// `Receive`
  String get Receive {
    return Intl.message(
      'Receive',
      name: 'Receive',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get Send {
    return Intl.message(
      'Send',
      name: 'Send',
      desc: '',
      args: [],
    );
  }

  /// `Swap`
  String get Swap {
    return Intl.message(
      'Swap',
      name: 'Swap',
      desc: '',
      args: [],
    );
  }

  /// `Balance`
  String get Balance {
    return Intl.message(
      'Balance',
      name: 'Balance',
      desc: '',
      args: [],
    );
  }

  /// `Copy Successfully`
  String get Copy_successfully {
    return Intl.message(
      'Copy Successfully',
      name: 'Copy_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get Copy {
    return Intl.message(
      'Copy',
      name: 'Copy',
      desc: '',
      args: [],
    );
  }

  /// `Copy Address`
  String get Copy_Address {
    return Intl.message(
      'Copy Address',
      name: 'Copy_Address',
      desc: '',
      args: [],
    );
  }

  /// `Receive Address`
  String get Receive_Address {
    return Intl.message(
      'Receive Address',
      name: 'Receive_Address',
      desc: '',
      args: [],
    );
  }

  /// `Send Address`
  String get Send_Address {
    return Intl.message(
      'Send Address',
      name: 'Send_Address',
      desc: '',
      args: [],
    );
  }

  /// `Add Currency`
  String get Add_currency {
    return Intl.message(
      'Add Currency',
      name: 'Add_currency',
      desc: '',
      args: [],
    );
  }

  /// `Add Currency`
  String get Add_currency_1 {
    return Intl.message(
      'Add Currency',
      name: 'Add_currency_1',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get Token_Send {
    return Intl.message(
      'Send',
      name: 'Token_Send',
      desc: '',
      args: [],
    );
  }

  /// `Select Token`
  String get Select_the_currency_to_receive {
    return Intl.message(
      'Select Token',
      name: 'Select_the_currency_to_receive',
      desc: '',
      args: [],
    );
  }

  /// `Select transfer network`
  String get Select_transfer_network {
    return Intl.message(
      'Select transfer network',
      name: 'Select_transfer_network',
      desc: '',
      args: [],
    );
  }

  /// `Add your NFT`
  String get Please_add_your_NFT {
    return Intl.message(
      'Add your NFT',
      name: 'Please_add_your_NFT',
      desc: '',
      args: [],
    );
  }

  /// `transfer network`
  String get Transfer_network {
    return Intl.message(
      'transfer network',
      name: 'Transfer_network',
      desc: '',
      args: [],
    );
  }

  /// `Enter {coin} Address`
  String Enter_Receiving_Address(Object coin) {
    return Intl.message(
      'Enter $coin Address',
      name: 'Enter_Receiving_Address',
      desc: '',
      args: [coin],
    );
  }

  /// `Enter Receiving Number`
  String get Enter_Receiving_Number {
    return Intl.message(
      'Enter Receiving Number',
      name: 'Enter_Receiving_Number',
      desc: '',
      args: [],
    );
  }

  /// `Please enter transaction password`
  String get Please_enter_transaction_password {
    return Intl.message(
      'Please enter transaction password',
      name: 'Please_enter_transaction_password',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get Confirm {
    return Intl.message(
      'Confirm',
      name: 'Confirm',
      desc: '',
      args: [],
    );
  }

  /// `Fuel cost`
  String get fuel_cost {
    return Intl.message(
      'Fuel cost',
      name: 'fuel_cost',
      desc: '',
      args: [],
    );
  }

  /// `Selling price`
  String get selling_price {
    return Intl.message(
      'Selling price',
      name: 'selling_price',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get price {
    return Intl.message(
      'Price',
      name: 'price',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Fees`
  String get Transaction_Fees {
    return Intl.message(
      'Transaction Fees',
      name: 'Transaction_Fees',
      desc: '',
      args: [],
    );
  }

  /// `ADD Token`
  String get ADD_Token {
    return Intl.message(
      'ADD Token',
      name: 'ADD_Token',
      desc: '',
      args: [],
    );
  }

  /// `Token name`
  String get Token_name {
    return Intl.message(
      'Token name',
      name: 'Token_name',
      desc: '',
      args: [],
    );
  }

  /// `Project name`
  String get Project_name {
    return Intl.message(
      'Project name',
      name: 'Project_name',
      desc: '',
      args: [],
    );
  }

  /// `total circulation`
  String get Total_circulation {
    return Intl.message(
      'total circulation',
      name: 'Total_circulation',
      desc: '',
      args: [],
    );
  }

  /// `Transaction details`
  String get Transaction_details {
    return Intl.message(
      'Transaction details',
      name: 'Transaction_details',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get Amount {
    return Intl.message(
      'Amount',
      name: 'Amount',
      desc: '',
      args: [],
    );
  }

  /// `Quantity`
  String get Quantity {
    return Intl.message(
      'Quantity',
      name: 'Quantity',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get Success {
    return Intl.message(
      'Success',
      name: 'Success',
      desc: '',
      args: [],
    );
  }

  /// `Fail`
  String get Fail {
    return Intl.message(
      'Fail',
      name: 'Fail',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get Address {
    return Intl.message(
      'Address',
      name: 'Address',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get Date {
    return Intl.message(
      'Date',
      name: 'Date',
      desc: '',
      args: [],
    );
  }

  /// `Collection`
  String get Collection {
    return Intl.message(
      'Collection',
      name: 'Collection',
      desc: '',
      args: [],
    );
  }

  /// `Scan the QR code and pay me`
  String get Collection_Tip_1 {
    return Intl.message(
      'Scan the QR code and pay me',
      name: 'Collection_Tip_1',
      desc: '',
      args: [],
    );
  }

  /// `Collection network`
  String get Collection_network {
    return Intl.message(
      'Collection network',
      name: 'Collection_network',
      desc: '',
      args: [],
    );
  }

  /// `NFT Details`
  String get NFT_Details {
    return Intl.message(
      'NFT Details',
      name: 'NFT_Details',
      desc: '',
      args: [],
    );
  }

  /// `Current price`
  String get Current_price {
    return Intl.message(
      'Current price',
      name: 'Current_price',
      desc: '',
      args: [],
    );
  }

  /// `Creator`
  String get Creator {
    return Intl.message(
      'Creator',
      name: 'Creator',
      desc: '',
      args: [],
    );
  }

  /// `Owner`
  String get Owner {
    return Intl.message(
      'Owner',
      name: 'Owner',
      desc: '',
      args: [],
    );
  }

  /// `Product details`
  String get Product_details {
    return Intl.message(
      'Product details',
      name: 'Product_details',
      desc: '',
      args: [],
    );
  }

  /// `Token Standard`
  String get Token_Standard {
    return Intl.message(
      'Token Standard',
      name: 'Token_Standard',
      desc: '',
      args: [],
    );
  }

  /// `Network`
  String get Network {
    return Intl.message(
      'Network',
      name: 'Network',
      desc: '',
      args: [],
    );
  }

  /// `Enter wallet`
  String get Enter_wallet {
    return Intl.message(
      'Enter wallet',
      name: 'Enter_wallet',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get All {
    return Intl.message(
      'All',
      name: 'All',
      desc: '',
      args: [],
    );
  }

  /// `View All`
  String get View_All {
    return Intl.message(
      'View All',
      name: 'View_All',
      desc: '',
      args: [],
    );
  }

  /// `Collect`
  String get Collect {
    return Intl.message(
      'Collect',
      name: 'Collect',
      desc: '',
      args: [],
    );
  }

  /// `Browsing history`
  String get Browsing_history {
    return Intl.message(
      'Browsing history',
      name: 'Browsing_history',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get Create_Account {
    return Intl.message(
      'Create Account',
      name: 'Create_Account',
      desc: '',
      args: [],
    );
  }

  /// `Import Account`
  String get Import_Account {
    return Intl.message(
      'Import Account',
      name: 'Import_Account',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get Email {
    return Intl.message(
      'Email',
      name: 'Email',
      desc: '',
      args: [],
    );
  }

  /// `unbound`
  String get Not_Associated {
    return Intl.message(
      'unbound',
      name: 'Not_Associated',
      desc: '',
      args: [],
    );
  }

  /// `Bound`
  String get Associated {
    return Intl.message(
      'Bound',
      name: 'Associated',
      desc: '',
      args: [],
    );
  }

  /// `Setting`
  String get Setting {
    return Intl.message(
      'Setting',
      name: 'Setting',
      desc: '',
      args: [],
    );
  }

  /// `General information`
  String get General_information {
    return Intl.message(
      'General information',
      name: 'General_information',
      desc: '',
      args: [],
    );
  }

  /// `Wallet information`
  String get Wallet_information {
    return Intl.message(
      'Wallet information',
      name: 'Wallet_information',
      desc: '',
      args: [],
    );
  }

  /// `Security and Privacy`
  String get Security_and_Privacy {
    return Intl.message(
      'Security and Privacy',
      name: 'Security_and_Privacy',
      desc: '',
      args: [],
    );
  }

  /// `Follow Us`
  String get Follow_Us {
    return Intl.message(
      'Follow Us',
      name: 'Follow_Us',
      desc: '',
      args: [],
    );
  }

  /// `Create Wallet`
  String get Create_Wallet {
    return Intl.message(
      'Create Wallet',
      name: 'Create_Wallet',
      desc: '',
      args: [],
    );
  }

  /// `Create Now`
  String get Create_Now {
    return Intl.message(
      'Create Now',
      name: 'Create_Now',
      desc: '',
      args: [],
    );
  }

  /// `Wallet`
  String get Wallet {
    return Intl.message(
      'Wallet',
      name: 'Wallet',
      desc: '',
      args: [],
    );
  }

  /// `Trade`
  String get Trade {
    return Intl.message(
      'Trade',
      name: 'Trade',
      desc: '',
      args: [],
    );
  }

  /// `GameFi`
  String get GameFi {
    return Intl.message(
      'GameFi',
      name: 'GameFi',
      desc: '',
      args: [],
    );
  }

  /// `DApp`
  String get DApp {
    return Intl.message(
      'DApp',
      name: 'DApp',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get Language {
    return Intl.message(
      'Language',
      name: 'Language',
      desc: '',
      args: [],
    );
  }

  /// `Modify wallet name`
  String get Modify_wallet_name {
    return Intl.message(
      'Modify wallet name',
      name: 'Modify_wallet_name',
      desc: '',
      args: [],
    );
  }

  /// `View private key`
  String get View_private_key {
    return Intl.message(
      'View private key',
      name: 'View_private_key',
      desc: '',
      args: [],
    );
  }

  /// `View mnemonics`
  String get View_mnemonics {
    return Intl.message(
      'View mnemonics',
      name: 'View_mnemonics',
      desc: '',
      args: [],
    );
  }

  /// `Node settings`
  String get Node_settings {
    return Intl.message(
      'Node settings',
      name: 'Node_settings',
      desc: '',
      args: [],
    );
  }

  /// `Delete Wallet`
  String get Delete_Wallet {
    return Intl.message(
      'Delete Wallet',
      name: 'Delete_Wallet',
      desc: '',
      args: [],
    );
  }

  /// `Node Name`
  String get Node_Name {
    return Intl.message(
      'Node Name',
      name: 'Node_Name',
      desc: '',
      args: [],
    );
  }

  /// `Check for updates`
  String get Check_for_updates {
    return Intl.message(
      'Check for updates',
      name: 'Check_for_updates',
      desc: '',
      args: [],
    );
  }

  /// `User Agreement`
  String get User_Agreement {
    return Intl.message(
      'User Agreement',
      name: 'User_Agreement',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Agreement`
  String get Privacy_Agreement {
    return Intl.message(
      'Privacy Agreement',
      name: 'Privacy_Agreement',
      desc: '',
      args: [],
    );
  }

  /// `Associated Mailbox`
  String get Associated_Mailbox {
    return Intl.message(
      'Associated Mailbox',
      name: 'Associated_Mailbox',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your email address`
  String get Email_Tip_1 {
    return Intl.message(
      'Please enter your email address',
      name: 'Email_Tip_1',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your email verification code`
  String get Email_Tip_2 {
    return Intl.message(
      'Please enter your email verification code',
      name: 'Email_Tip_2',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Association`
  String get Confirm_Association {
    return Intl.message(
      'Confirm Association',
      name: 'Confirm_Association',
      desc: '',
      args: [],
    );
  }

  /// `WebSite`
  String get WebSite {
    return Intl.message(
      'WebSite',
      name: 'WebSite',
      desc: '',
      args: [],
    );
  }

  /// `Create new wallet`
  String get Create_new_wallet {
    return Intl.message(
      'Create new wallet',
      name: 'Create_new_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Import existing wallet`
  String get Import_existing_wallet {
    return Intl.message(
      'Import existing wallet',
      name: 'Import_existing_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Backup mnemonics phrase`
  String get keep_your_mnemonic {
    return Intl.message(
      'Backup mnemonics phrase',
      name: 'keep_your_mnemonic',
      desc: '',
      args: [],
    );
  }

  /// `This password will be used to confirm transactions`
  String get password_tip_1 {
    return Intl.message(
      'This password will be used to confirm transactions',
      name: 'password_tip_1',
      desc: '',
      args: [],
    );
  }

  /// `Please enter more than 8 characters(Including uppercase, lowercase and number)`
  String get password_tip_2 {
    return Intl.message(
      'Please enter more than 8 characters(Including uppercase, lowercase and number)',
      name: 'password_tip_2',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get Confirm_Password {
    return Intl.message(
      'Confirm Password',
      name: 'Confirm_Password',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get Next {
    return Intl.message(
      'Next',
      name: 'Next',
      desc: '',
      args: [],
    );
  }

  /// `next step`
  String get next_step {
    return Intl.message(
      'next step',
      name: 'next_step',
      desc: '',
      args: [],
    );
  }

  /// `Please input password`
  String get Please_input_password {
    return Intl.message(
      'Please input password',
      name: 'Please_input_password',
      desc: '',
      args: [],
    );
  }

  /// `Wrong Password`
  String get Wrong_Password {
    return Intl.message(
      'Wrong Password',
      name: 'Wrong_Password',
      desc: '',
      args: [],
    );
  }

  /// `Please Wait`
  String get Please_Wait {
    return Intl.message(
      'Please Wait',
      name: 'Please_Wait',
      desc: '',
      args: [],
    );
  }

  /// `Swap record`
  String get Swap_Record {
    return Intl.message(
      'Swap record',
      name: 'Swap_Record',
      desc: '',
      args: [],
    );
  }

  /// `Swap successfully`
  String get Swap_Successfully {
    return Intl.message(
      'Swap successfully',
      name: 'Swap_Successfully',
      desc: '',
      args: [],
    );
  }

  /// `Swap failed`
  String get Swap_Failed {
    return Intl.message(
      'Swap failed',
      name: 'Swap_Failed',
      desc: '',
      args: [],
    );
  }

  /// `Swap Record Details`
  String get Swap_Record_Details {
    return Intl.message(
      'Swap Record Details',
      name: 'Swap_Record_Details',
      desc: '',
      args: [],
    );
  }

  /// `Sell`
  String get Sell_Away {
    return Intl.message(
      'Sell',
      name: 'Sell_Away',
      desc: '',
      args: [],
    );
  }

  /// `Buy`
  String get Buy_In {
    return Intl.message(
      'Buy',
      name: 'Buy_In',
      desc: '',
      args: [],
    );
  }

  /// `Hash`
  String get Hash {
    return Intl.message(
      'Hash',
      name: 'Hash',
      desc: '',
      args: [],
    );
  }

  /// `You have successfully created\n a Coinstart wallet`
  String get Create_Wallet_Successfully {
    return Intl.message(
      'You have successfully created\n a Coinstart wallet',
      name: 'Create_Wallet_Successfully',
      desc: '',
      args: [],
    );
  }

  /// `The password does not meet the requirements`
  String get The_password_not_meet_the_requirements {
    return Intl.message(
      'The password does not meet the requirements',
      name: 'The_password_not_meet_the_requirements',
      desc: '',
      args: [],
    );
  }

  /// `Login Password`
  String get Setup_Password {
    return Intl.message(
      'Login Password',
      name: 'Setup_Password',
      desc: '',
      args: [],
    );
  }

  /// `I have the mnemonic ready`
  String get Backed_Up_The_Memo {
    return Intl.message(
      'I have the mnemonic ready',
      name: 'Backed_Up_The_Memo',
      desc: '',
      args: [],
    );
  }

  /// `Verify mnemonic phrase`
  String get Verify_Mnemonic_Phrase {
    return Intl.message(
      'Verify mnemonic phrase',
      name: 'Verify_Mnemonic_Phrase',
      desc: '',
      args: [],
    );
  }

  /// `Please fill in the correct words in order to confirm your mnemonic phrases`
  String get Verify_Mnemonic_Phrase_Tip {
    return Intl.message(
      'Please fill in the correct words in order to confirm your mnemonic phrases',
      name: 'Verify_Mnemonic_Phrase_Tip',
      desc: '',
      args: [],
    );
  }

  /// `Select Network`
  String get Select_Network {
    return Intl.message(
      'Select Network',
      name: 'Select_Network',
      desc: '',
      args: [],
    );
  }

  /// `Recover password by email`
  String get Forgot_Password_Tip1 {
    return Intl.message(
      'Recover password by email',
      name: 'Forgot_Password_Tip1',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Recover password by email`
  String get Forgot_Password_Tip2 {
    return Intl.message(
      'Confirm Recover password by email',
      name: 'Forgot_Password_Tip2',
      desc: '',
      args: [],
    );
  }

  /// `Please input the email address`
  String get Forgot_Password_Tip3 {
    return Intl.message(
      'Please input the email address',
      name: 'Forgot_Password_Tip3',
      desc: '',
      args: [],
    );
  }

  /// `Password successfully sent to email`
  String get Forgot_Password_Tip4 {
    return Intl.message(
      'Password successfully sent to email',
      name: 'Forgot_Password_Tip4',
      desc: '',
      args: [],
    );
  }

  /// `Retrieve password`
  String get Retrieve_password {
    return Intl.message(
      'Retrieve password',
      name: 'Retrieve_password',
      desc: '',
      args: [],
    );
  }

  /// `Get password`
  String get Get_Password {
    return Intl.message(
      'Get password',
      name: 'Get_Password',
      desc: '',
      args: [],
    );
  }

  /// `Wallet Login`
  String get Wallet_Login {
    return Intl.message(
      'Wallet Login',
      name: 'Wallet_Login',
      desc: '',
      args: [],
    );
  }

  /// `AddTime`
  String get AddTime {
    return Intl.message(
      'AddTime',
      name: 'AddTime',
      desc: '',
      args: [],
    );
  }

  /// `Transfer`
  String get Transfer {
    return Intl.message(
      'Transfer',
      name: 'Transfer',
      desc: '',
      args: [],
    );
  }

  /// `Please input password and transfer address`
  String get Please_input_password_address {
    return Intl.message(
      'Please input password and transfer address',
      name: 'Please_input_password_address',
      desc: '',
      args: [],
    );
  }

  /// `Please input transfer address`
  String get Please_input_address {
    return Intl.message(
      'Please input transfer address',
      name: 'Please_input_address',
      desc: '',
      args: [],
    );
  }

  /// `You haven't added any NFTs.`
  String get Null_NFTs {
    return Intl.message(
      'You haven\'t added any NFTs.',
      name: 'Null_NFTs',
      desc: '',
      args: [],
    );
  }

  /// `Recelving address`
  String get Recelving_Address {
    return Intl.message(
      'Recelving address',
      name: 'Recelving_Address',
      desc: '',
      args: [],
    );
  }

  /// `Currently no content`
  String get Null_Dapp {
    return Intl.message(
      'Currently no content',
      name: 'Null_Dapp',
      desc: '',
      args: [],
    );
  }

  /// `Para birimi`
  String get Para_Birimi {
    return Intl.message(
      'Para birimi',
      name: 'Para_Birimi',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get About {
    return Intl.message(
      'About',
      name: 'About',
      desc: '',
      args: [],
    );
  }

  /// `Select Wallet`
  String get Select_Wallet {
    return Intl.message(
      'Select Wallet',
      name: 'Select_Wallet',
      desc: '',
      args: [],
    );
  }

  /// `Add Wallet`
  String get Add_Wallet {
    return Intl.message(
      'Add Wallet',
      name: 'Add_Wallet',
      desc: '',
      args: [],
    );
  }

  /// `Get code`
  String get Get_Code {
    return Intl.message(
      'Get code',
      name: 'Get_Code',
      desc: '',
      args: [],
    );
  }

  /// `email address`
  String get Email_Address {
    return Intl.message(
      'email address',
      name: 'Email_Address',
      desc: '',
      args: [],
    );
  }

  /// `verification code`
  String get Verification_Code {
    return Intl.message(
      'verification code',
      name: 'Verification_Code',
      desc: '',
      args: [],
    );
  }

  /// `login password`
  String get Login_Password {
    return Intl.message(
      'login password',
      name: 'Login_Password',
      desc: '',
      args: [],
    );
  }

  /// `The wallet details`
  String get The_Wallet_Details {
    return Intl.message(
      'The wallet details',
      name: 'The_Wallet_Details',
      desc: '',
      args: [],
    );
  }

  /// `Wrong Password,Different from the existing password`
  String get Wrong_Password_1 {
    return Intl.message(
      'Wrong Password,Different from the existing password',
      name: 'Wrong_Password_1',
      desc: '',
      args: [],
    );
  }

  /// `Select token to sell`
  String get Sell_Token_tip {
    return Intl.message(
      'Select token to sell',
      name: 'Sell_Token_tip',
      desc: '',
      args: [],
    );
  }

  /// `Select token to buy`
  String get Buy_Token_tip {
    return Intl.message(
      'Select token to buy',
      name: 'Buy_Token_tip',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get Search {
    return Intl.message(
      'Search',
      name: 'Search',
      desc: '',
      args: [],
    );
  }

  /// `Mint an example NFT`
  String get Mint_An_Example_NFT {
    return Intl.message(
      'Mint an example NFT',
      name: 'Mint_An_Example_NFT',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
