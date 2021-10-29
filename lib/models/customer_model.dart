class CustomerModel {
  late String custId;
  late String custName;
  late double custBalance;
  late String adminId;
  late String custAddress;
  late String custPassword;
  late String custEmail;
  late bool isBlock;
  String? custMobile;

  CustomerModel(
      this.custId,
      this.custName,
      this.custMobile,
      this.custBalance,
      this.adminId,
      this.custAddress,
      this.custPassword,
      this.custEmail,
      this.isBlock);

  CustomerModel.fromJson(Map<String, dynamic> json) {
    custId = json['cust_id'];
    custName = json['cust_name'];
    custBalance = json['cust_balance'];
    adminId = json['admin_id'];
    custAddress = json['cust_address'];
    custPassword = json['cust_password'];
    custEmail = json['cust_email'];
    custMobile = json["mobile_number"];
    isBlock = json['isBlock'] == null ? false : json['isBlock'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['cust_id'] = this.custId;
    data['cust_name'] = this.custName;
    data["mobile_number"] = this.custMobile;
    data['cust_balance'] = this.custBalance;
    data['admin_id'] = this.adminId;
    data['cust_address'] = this.custAddress;
    data['cust_password'] = this.custPassword;
    data['cust_email'] = this.custEmail;
    data['isBlock'] = this.isBlock;
    return data;
  }
}
