import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close),
              color: Colors.black,
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Spacer(),
          Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'No Stories left!',
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                  Text(
                    'Visit again later.',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
              AspectRatio(
                aspectRatio: 9 / 16,
                child: CardSwiper(
                  padding: const EdgeInsets.all(0),
                  backCardOffset: Offset(0, 0),
                  isLoop: false,
                  duration: Duration(milliseconds: 100),
                  cardBuilder:
                      (
                        context,
                        index,
                        horizontalOffsetPercentage,
                        verticalOffsetPercentage,
                      ) => AspectRatio(
                        aspectRatio: 9 / 16,
                        child: Image.network(
                          'https://picsum.photos/720?random=$index',
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) =>
                              loadingProgress == null
                              ? child
                              : Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                          errorBuilder: (context, error, stackTrace) =>
                              AspectRatio(
                                aspectRatio: 9 / 16,
                                child: Container(color: Colors.red),
                              ),
                        ),
                      ),
                  cardsCount: 5,
                ),
              ),
            ],
          ),
          Spacer(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () {},
              icon: Icon(Icons.thumb_up),
              label: Text('Like'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
            IconButton.filled(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              icon: Icon(Icons.undo),
            ),
          ],
        ),
      ),
    );
  }
}
