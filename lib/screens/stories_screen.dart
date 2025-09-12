import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:realm/main.dart';
import 'package:realm/model/user.dart';
import 'package:realm/screens/profile_screen.dart';
import 'package:realm/util.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  List<UserModel> allStories = [];
  int? currentIndex = 0;

  Future<void> getStories() async {
    List<UserModel> stories = [];
    try {
      await supabase
          .from('users')
          .select()
          .neq('story', '')
          .order('created_at', ascending: false)
          .then(
            (value) => stories = value.map((e) {
              return UserModel.fromJson(e);
            }).toList(),
          );
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
    setState(() {
      allStories = stories;
    });
  }

  void getData() async {
    await getStories();
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

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
              allStories.isEmpty
                  ? Container()
                  : AspectRatio(
                      aspectRatio: 9 / 16,
                      child: CardSwiper(
                        padding: const EdgeInsets.all(0),
                        backCardOffset: Offset(0, 0),
                        isLoop: false,
                        duration: Duration(milliseconds: 100),
                        cardsCount: allStories.length,
                        onSwipe: (previousIndex, currentIndex, direction) {
                          setState(() => this.currentIndex = currentIndex);
                          return true;
                        },
                        cardBuilder:
                            (
                              context,
                              index,
                              horizontalOffsetPercentage,
                              verticalOffsetPercentage,
                            ) => AspectRatio(
                              aspectRatio: 9 / 16,
                              child: Image.network(
                                formattedUrl(allStories[index].story!),
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) => loadingProgress == null
                                    ? child
                                    : Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
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
        child: allStories.isEmpty || currentIndex == null
            ? Container()
            : ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen(uid: allStories[currentIndex!].id),
                  ),
                ),
                leading: CircleAvatar(
                  backgroundImage: allStories[currentIndex!].image != null
                      ? NetworkImage(
                          formattedUrl(allStories[currentIndex!].image ?? ''),
                        )
                      : null,
                  child: allStories[currentIndex!].image == null
                      ? Text(
                          allStories[currentIndex!].name?[0].toUpperCase() ??
                              '',
                        )
                      : null,
                ),
                title: Text(allStories[currentIndex!].name ?? ''),
              ),
      ),
    );
  }
}
