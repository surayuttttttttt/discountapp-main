import 'package:discountapp/models.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DiscountController extends GetxController {
  RxInt point = 0.obs;
  Rx<double> total = 0.0.obs;
  Rx<double> originalTotal = 0.0.obs;
  Rx<double> totalDiscount = 0.0.obs;
  RxInt currentIndex = 99.obs;
  RxString currentCampaign = ''.obs;
  RxList<AvailableItem> cart = <AvailableItem>[].obs;
  RxMap<String, int> itemCounts = <String, int>{}.obs;
  DiscountModel? discountModel;

  getData() async {
    final mockJson = await rootBundle.loadString('/mock.json');
    DiscountModel response = discountModelFromJson(mockJson);
    discountModel = response;
    point.value = discountModel?.points ?? 0;
  }

  clearCart() {
    cart.clear();
    total.value = 0;
    totalDiscount.value = 0.0;
    itemCounts.clear();
    originalTotal.value = 0;
  }

  addToCart(AvailableItem items) {
    cart.add(items);
    if (itemCounts.containsKey(items.name)) {
      itemCounts[items.name] = itemCounts[items.name]! + 1;
    } else {
      itemCounts[items.name] = 1;
    }
    originalTotal += double.parse(items.price);
    total.value = total.value + int.parse(items.price);
  }

  double useFixedCouponDiscount(
      List<AvailableItem> cart, double discountValue) {
    totalDiscount.value = discountValue;
    total.value -= discountValue;

    return total.value;
  }

  double usePercentageDiscount(double discountPercent) {
    double discountAmount = (total * discountPercent) / 100;
    totalDiscount.value = discountAmount;
    total.value = total.value - discountAmount;
    return total.value;
  }

  double useCategoryDiscount(List<AvailableItem> cart,
      List<AvailableItem> items, String category, double discountPercent) {
    double totalPrice = 0.0;

    for (var entry in cart) {
      String itemName = entry.name;
      double itemPrice = double.parse(entry.price);
      var item = items.firstWhere((element) => element.name == itemName);
      if (item.category == category) {
        double discountAmount = itemPrice * (discountPercent / 100);
        itemPrice -= discountAmount;
        totalDiscount += discountAmount;
      }

      totalPrice += itemPrice;
    }

    return totalPrice;
  }

  double useSpecialCampaign(
      List<AvailableItem> car, double threshold, double discountAmount) {
    double totalPrice = 0.0;
    for (var item in cart) {
      totalPrice += double.parse(item.price);
    }
    int discountMultiplier = (totalPrice / threshold).floor();
    double discount = discountMultiplier * discountAmount;
    totalDiscount.value = discount;

    return totalPrice - discount;
  }

  double usePoints({
    required int customerPoints,
    double discountCapPercent = 20,
  }) {
    double totalPrice = 0.0;
    for (var item in cart) {
      totalPrice += double.parse(item.price);
    }
    double maxDiscount = totalPrice * (discountCapPercent / 100);
    double discountFromPoints = customerPoints.toDouble();
    totalDiscount.value =
        discountFromPoints > maxDiscount ? maxDiscount : discountFromPoints;

    return discountFromPoints > maxDiscount ? maxDiscount : discountFromPoints;
  }

  useDiscount(int couponIndex) {
    total.value = originalTotal.value;
    totalDiscount.value = 0.0;
    switch (couponIndex) {
      case 0:
        {
          double useFixedCouponTotal = useFixedCouponDiscount(cart, 50);
          total.value = useFixedCouponTotal;
        }
        break;
      case 1:
        {
          double usePercentDiscountedTotal = usePercentageDiscount(10);
          total.value = usePercentDiscountedTotal;
        }
        break;
      case 2:
        {
          double usecategoryDiscountedTotal = useCategoryDiscount(
              cart, discountModel!.availableItems, "Clothing", 15);
          total.value = usecategoryDiscountedTotal;
        }
        break;
      case 3:
        {
          double pointDiscountedTotal =
              usePoints(customerPoints: 68, discountCapPercent: 20);
          double totalPrice = 0.0;
          for (var item in cart) {
            totalPrice += double.parse(item.price);
          }
          total.value = totalPrice - pointDiscountedTotal;
        }
        break;

      case 4:
        {
          double specialCampaignDiscountedTotal =
              useSpecialCampaign(cart, 300, 40);
          total.value = specialCampaignDiscountedTotal;
        }
      default:
    }
  }
}
