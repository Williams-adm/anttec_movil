import 'package:flutter/material.dart';

class ProductImageGallery extends StatelessWidget {
  final List<String> images;
  final PageController pageController;
  final String Function(String?) fixUrl;

  const ProductImageGallery({
    super.key,
    required this.images,
    required this.pageController,
    required this.fixUrl,
  });

  @override
  Widget build(BuildContext context) {
    final list = images.isNotEmpty ? images : [''];
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: list.length,
            itemBuilder: (context, index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(fixUrl(list[index]), fit: BoxFit.contain),
              ),
            ),
          ),
          if (list.length > 1)
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _navBtn(Icons.arrow_back_ios_new, () {
                    pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }),
                  _navBtn(Icons.arrow_forward_ios, () {
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: CircleAvatar(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        child: Icon(icon, size: 18, color: Colors.black),
      ),
      onPressed: onTap,
    );
  }
}
