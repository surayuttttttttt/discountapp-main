// To parse this JSON data, do
//
//     final discountModel = discountModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

DiscountModel discountModelFromJson(String str) =>
    DiscountModel.fromJson(json.decode(str));

String discountModelToJson(DiscountModel data) => json.encode(data.toJson());

class DiscountModel {
  int points;
  AvailableCoupon availableCoupon;
  List<AvailableItem> availableItems;

  DiscountModel({
    required this.points,
    required this.availableCoupon,
    required this.availableItems,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) => DiscountModel(
        points: json["points"],
        availableCoupon: AvailableCoupon.fromJson(json["availableCoupon"]),
        availableItems: List<AvailableItem>.from(
            json["availableItems"].map((x) => AvailableItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "points": points,
        "availableCoupon": availableCoupon.toJson(),
        "availableItems":
            List<dynamic>.from(availableItems.map((x) => x.toJson())),
      };
}

class AvailableCoupon {
  CouponType couponType;

  AvailableCoupon({
    required this.couponType,
  });

  factory AvailableCoupon.fromJson(Map<String, dynamic> json) =>
      AvailableCoupon(
        couponType: CouponType.fromJson(json["CouponType"]),
      );

  Map<String, dynamic> toJson() => {
        "CouponType": couponType.toJson(),
      };
}

class CouponType {
  Coupon coupon;
  OnTop onTop;
  Seasonal seasonal;

  CouponType({
    required this.coupon,
    required this.onTop,
    required this.seasonal,
  });

  factory CouponType.fromJson(Map<String, dynamic> json) => CouponType(
        coupon: Coupon.fromJson(json["Coupon"]),
        onTop: OnTop.fromJson(json["OnTop"]),
        seasonal: Seasonal.fromJson(json["Seasonal"]),
      );

  Map<String, dynamic> toJson() => {
        "Coupon": coupon.toJson(),
        "OnTop": onTop.toJson(),
        "Seasonal": seasonal.toJson(),
      };
}

class Coupon {
  int fixedAmount;
  int percentDiscount;

  Coupon({
    required this.fixedAmount,
    required this.percentDiscount,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
        fixedAmount: json["fixedAmount"],
        percentDiscount: json["PercentDiscount"],
      );

  Map<String, dynamic> toJson() => {
        "fixedAmount": fixedAmount,
        "PercentDiscount": percentDiscount,
      };
}

class OnTop {
  int percentageitemcategory;
  int point;

  OnTop({
    required this.percentageitemcategory,
    required this.point,
  });

  factory OnTop.fromJson(Map<String, dynamic> json) => OnTop(
        percentageitemcategory: json["Percentageitemcategory"],
        point: json["Point"],
      );

  Map<String, dynamic> toJson() => {
        "Percentageitemcategory": percentageitemcategory,
        "Point": point,
      };
}

class Seasonal {
  String specialCampaign;

  Seasonal({
    required this.specialCampaign,
  });

  factory Seasonal.fromJson(Map<String, dynamic> json) => Seasonal(
        specialCampaign: json["SpecialCampaign"],
      );

  Map<String, dynamic> toJson() => {
        "SpecialCampaign": specialCampaign,
      };
}

class AvailableItem {
  String name;
  String price;
  String category;

  AvailableItem({
    required this.name,
    required this.price,
    required this.category,
  });

  factory AvailableItem.fromJson(Map<String, dynamic> json) => AvailableItem(
        name: json["name"],
        price: json["price"],
        category: json["category"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "price": price,
        "category": category,
      };
}
