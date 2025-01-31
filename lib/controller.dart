import 'package:discountapp/models.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DiscountController extends GetxController {
  RxInt point = 0.obs;
  Rx<double> total = 0.0.obs;
  Rx<double> originalTotal = 0.0.obs;
  Rx<double> totalDiscount = 0.0.obs;
  RxInt currentIndex = 99.obs;
  RxInt currentOnTopIndex = 99.obs;
  RxInt currentCouponIndex = 99.obs;
  RxBool isUseSeasonal = false.obs;
  RxBool onTopActive = false.obs;

  RxString currentCampaign = ''.obs;
  RxList<AvailableItem> cart = <AvailableItem>[].obs;
  RxMap<String, int> itemCounts = <String, int>{}.obs;
  DiscountModel? discountModel;

  Rx<double> totalDiscountFromCoupon = 0.0.obs;
  Rx<double> totalDiscountFromOnTop = 0.0.obs;
  Rx<double> totalDiscountFromSeasonal = 0.0.obs;

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
    currentCouponIndex.value = 0;
    currentOnTopIndex.value = 0;
    isUseSeasonal.value = false;

    totalDiscountFromCoupon.value = 0;
    totalDiscountFromOnTop.value = 0;
    totalDiscountFromSeasonal.value = 0;
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

  calculateDiscount() {
    totalDiscount.value = totalDiscountFromCoupon.value +
        totalDiscountFromOnTop.value +
        totalDiscountFromSeasonal.value;

    total.value = total.value - totalDiscount.value;
  }

  useDiscountByCoupon(int couponIndex) {
    // totalDiscountFromOnTop.value = 0;
    // currentOnTopIndex.value = couponIndex;
    total.value = originalTotal.value;
    totalDiscount.value = 0.0;

    //INDEX 1 = FIXED
    //INDEX 2 = PERCENTAGE
    if (couponIndex == 1) {
      double useFixedCouponTotal = useFixedCouponDiscount(cart, 50);
      totalDiscountFromCoupon.value = useFixedCouponTotal;
      calculateDiscount();
    } else if (couponIndex == 2) {
      double usePercentDiscountedTotal = usePercentageDiscount(10);
      totalDiscountFromCoupon.value = usePercentDiscountedTotal;
      calculateDiscount();
    }
  }

  useDiscountByOnTop(int couponIndex) {
    total.value = originalTotal.value;
    totalDiscount.value = 0.0;
    //INDEX 1 = PERCENTAGE
    //INDEX 2 = PERCENTAGE BY CAT
    if (couponIndex == 1) {
      double useCategoryDiscountedTotal = useCategoryDiscount(
          cart, discountModel!.availableItems, "Clothing", 15);
      totalDiscountFromOnTop.value = useCategoryDiscountedTotal;
      calculateDiscount();
    } else if (couponIndex == 2) {
      double pointDiscountedTotal =
          usePoints(customerPoints: 68, discountCapPercent: 20);
      totalDiscountFromOnTop.value = pointDiscountedTotal;
      calculateDiscount();
    }
  }

  useDiscountBySeasonal() {
    if (!isUseSeasonal.value) {
      total.value = originalTotal.value;
      totalDiscountFromSeasonal.value = 0.0;
    }
    total.value = originalTotal.value;
    totalDiscountFromSeasonal.value = 0.0;
    double specialCampaignDiscountedTotal = useSpecialCampaign(cart, 300, 40);
    totalDiscountFromSeasonal.value = specialCampaignDiscountedTotal;
    calculateDiscount();
    if (!isUseSeasonal.value) {
      total.value = originalTotal.value;
      totalDiscountFromSeasonal.value = 0.0;
    }
  }

  double useFixedCouponDiscount(
      List<AvailableItem> cart, double discountValue) {
    totalDiscountFromCoupon.value = discountValue;
    return totalDiscountFromCoupon.value;
  }

  double usePercentageDiscount(double discountPercent) {
    double discountAmount = (total * discountPercent) / 100;
    totalDiscountFromCoupon.value = discountAmount;
    print(totalDiscountFromCoupon.value);
    return totalDiscountFromCoupon.value;
  }

  double useCategoryDiscount(List<AvailableItem> cart,
      List<AvailableItem> items, String category, double discountPercent) {
    for (var entry in cart) {
      String itemName = entry.name;
      double itemPrice = double.parse(entry.price);
      var item = items.firstWhere((element) => element.name == itemName);
      if (item.category == category) {
        double discountAmount = itemPrice * (discountPercent / 100);
        itemPrice -= discountAmount;
        totalDiscountFromOnTop.value += discountAmount;
      }
    }

    print(totalDiscountFromOnTop.value);

    return totalDiscountFromOnTop.value;
  }

  double usePoints({
    required int customerPoints,
    double discountCapPercent = 20,
  }) {
    double totalPrice = 0.0;
    for (var item in cart) {
      totalPrice += double.parse(item.price);
    }
    print('Total Price $totalPrice');
    double maxDiscount = totalPrice * (discountCapPercent / 100);
    double discountFromPoints = customerPoints.toDouble();

    totalDiscountFromOnTop.value =
        discountFromPoints > maxDiscount ? maxDiscount : discountFromPoints;
    return totalDiscountFromOnTop.value;
  }

  double useSpecialCampaign(
      List<AvailableItem> car, double threshold, double discountAmount) {
    double totalPrice = 0.0;
    for (var item in cart) {
      totalPrice += double.parse(item.price);
    }
    int discountMultiplier = (totalPrice / threshold).floor();
    double discount = discountMultiplier * discountAmount;

    totalDiscountFromSeasonal.value = discount;
    return totalDiscountFromSeasonal.value;
  }
}
