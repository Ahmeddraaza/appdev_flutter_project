import 'package:flutter/material.dart';

class BestSellingProducts extends StatelessWidget {
  final List<Map<String, dynamic>> bestSellingProducts;

  const BestSellingProducts({
    Key? key,
    required this.bestSellingProducts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 357,
        padding: const EdgeInsets.symmetric(horizontal: 13.09, vertical: 19.63),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 0.61,
              color: Colors.black.withOpacity(0.125),
            ),
            borderRadius: BorderRadius.circular(8.59),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title Section
            SizedBox(
              width: double.infinity,
              child: Text(
                'Best Selling Products',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF212529),
                  fontSize: 13.09,
                  fontFamily: 'Barlow',
                  fontWeight: FontWeight.w600,
                  height: 1.50,
                ),
              ),
            ),
            const SizedBox(height: 9.82),

            // Product List
            SizedBox(
              height: 200, // Define a fixed height
              child: ListView.builder(
                itemCount: bestSellingProducts.length,
                itemBuilder: (context, index) {
                  final product = bestSellingProducts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.91),
                    child: Container(
                      padding: const EdgeInsets.all(6.54),
                      decoration: ShapeDecoration(
                        color: Color(0xFFF8F9FA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.09),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Product Name
                          Expanded(
                            flex: 3,
                            child: Text(
                              product['productName'],
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color(0xFF47178E),
                                fontSize: 12,
                                fontFamily: 'Albert Sans',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6.54),

                          // Product Quantity
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${product['quantity']}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Color(0xFF47168E),
                                fontSize: 12,
                                fontFamily: 'Albert Sans',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
