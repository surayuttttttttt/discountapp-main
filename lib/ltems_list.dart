import 'package:discountapp/controller.dart';
import 'package:discountapp/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  DiscountController controller = Get.put(DiscountController());

  @override
  void initState() {
    super.initState();
    controller.getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 206, 206, 206),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Items',
                    style: CustomTextStyle().textStyle.copyWith(fontSize: 20)),
              ),
              TextButton(
                  onPressed: () {
                    controller.clearCart();
                  },
                  child: Text('clear all',
                      style: CustomTextStyle()
                          .textStyle
                          .copyWith(fontSize: 16, color: Colors.red)))
            ],
          ),
          FutureBuilder(
            future: controller.getData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (controller.discountModel?.availableItems == null ||
                  controller.discountModel!.availableItems.isEmpty) {
                return const Center(child: Text('No items available.'));
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [buildItemListTile(), Divider(), buildCoupon()],
                ),
              );
            },
          ),
          Divider(),
          buildTextInfo(),
          Divider(),
        ],
      ),
    );
  }

  Widget buildItemListTile() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: controller.discountModel!.availableItems.length,
        itemBuilder: (context, index) {
          final item = controller.discountModel!.availableItems[index];
          return Column(
            children: [
              Card(
                elevation: 8,
                child: ListTile(
                  dense: true,
                  title: Text(
                    item.name,
                    style: CustomTextStyle().textStyle.copyWith(fontSize: 16),
                  ),
                  subtitle: Text(item.price),
                  leading: Icon(
                    Icons.image,
                    size: 40,
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Obx(() => controller.itemCounts[item.name] != null &&
                                controller.itemCounts[item.name]! > 0
                            ? Container(
                                width: 30,
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 19, 21, 114),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Text(
                                  controller.itemCounts[item.name]!.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              )
                            : Container()),
                        GestureDetector(
                            onTap: () {
                              controller.addToCart(item);
                            },
                            child: Icon(Icons.add)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildCoupon() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Available Coupon',
              style: CustomTextStyle().textStyle.copyWith(fontSize: 20)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(
              5,
              (index) {
                return GestureDetector(
                  onTap: () {
                    if (controller.cart.isNotEmpty &&
                        (controller.currentIndex.value != index)) {
                      controller.currentIndex.value = index;
                      controller.useDiscount(index);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: 80,
                        child: Obx(
                          () => Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: index == controller.currentIndex.value
                                      ? Colors.green
                                      : Color.fromARGB(255, 206, 206, 206),
                                  width: 5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              child: Image.asset(
                                'images/${index + 1}.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget buildTextInfo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Discount',
                    style: CustomTextStyle().textStyle.copyWith(fontSize: 20),
                  ),
                  Text(
                    ' ${controller.totalDiscount.value}',
                    style: CustomTextStyle().textStyle.copyWith(fontSize: 30),
                  )
                ],
              )),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total price',
                    style: CustomTextStyle().textStyle.copyWith(fontSize: 20),
                  ),
                  Text(
                    ' ${controller.total.value}',
                    style: CustomTextStyle().textStyle.copyWith(fontSize: 30),
                  )
                ],
              )),
        ],
      ),
    );
  }
}
