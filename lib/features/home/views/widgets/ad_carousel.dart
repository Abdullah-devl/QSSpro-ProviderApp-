// مسار الملف: lib/features/home/views/widgets/ad_carousel.dart
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../../models/advertisement_model.dart';
import '../../viewmodels/main_viewmodel.dart';
import 'package:provider/provider.dart';

class AdCarousel extends StatelessWidget {
  final List<AdvertisementModel> ads;
  final double height;

  const AdCarousel({super.key, required this.ads, this.height = 160});

  @override
  Widget build(BuildContext context) {
    if (ads.isEmpty) return const SizedBox.shrink();

    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: CarouselSlider(
        options: CarouselOptions(
          height: height,
          viewportFraction: 0.92,
          enlargeCenterPage: true,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 5),
          onPageChanged: (index, reason) {
            homeViewModel.trackAdView(ads[index].id);
          },
        ),
        items: ads.map((ad) {
          return Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                onTap: () => homeViewModel.handleAdClick(context, ad),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(ad.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
