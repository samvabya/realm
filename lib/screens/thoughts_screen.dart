import 'dart:async';

import 'package:flutter/material.dart';
import 'package:realm/components/thought_card.dart';
import 'package:realm/components/thought_modal.dart';
import 'package:realm/main.dart';
import 'package:realm/model/thought.dart';

class ThoughtsScreens extends StatefulWidget {
  const ThoughtsScreens({super.key});

  @override
  State<ThoughtsScreens> createState() => _ThoughtsScreensState();
}

class _ThoughtsScreensState extends State<ThoughtsScreens> {
  bool isFabExtended = true;
  bool isLoading = false;
  ScrollController scrollController = ScrollController();
  List<ThoughtModel> allThoughts = [];

  Future<void> getAllThoughts() async {
    List<ThoughtModel> thoughts = [];
    try {
      await supabase
          .from('thoughts')
          .select('''
              id,
              userId,
              file,
              body,
              created_at,
              users(id, name, image)
            ''')
          .isFilter('head', null)
          .order('created_at', ascending: false)
          .then(
            (value) => thoughts = value.map((e) {
              return ThoughtModel.fromJson(e);
            }).toList(),
          );
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
    setState(() {
      allThoughts = thoughts;
    });
  }

  void getData() async {
    await getAllThoughts();
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            if (notification.scrollDelta! > 0) {
              // Scrolling down
              setState(() {
                isFabExtended = false;
              });
            } else {
              // Scrolling up
              setState(() {
                isFabExtended = true;
              });
            }
          }
          return true;
        },
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverAppBar(
              floating: true,
              title: TextButton.icon(
                onPressed: () async {
                  setState(() => isLoading = true);
                  await getAllThoughts();
                  Timer(
                    Duration(seconds: 2),
                    () => setState(() => isLoading = false),
                  );
                },
                icon: Icon(Icons.tag, size: 30),
                label: AnimatedSize(
                  curve: Curves.fastOutSlowIn,
                  reverseDuration: const Duration(milliseconds: 500),
                  duration: const Duration(milliseconds: 500),
                  child: isLoading
                      ? const Text("Refreshing thoughts")
                      : const SizedBox(),
                ),
              ),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(88),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  child: TextField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      hintText: 'Search Thoughts',
                    ),
                  ),
                ),
              ),
            ),
            if (isLoading) ...[
              SliverToBoxAdapter(child: LinearProgressIndicator()),
            ],
            SliverList.builder(
              itemCount: allThoughts.length,
              itemBuilder: (context, index) =>
                  ThoughtCard(thought: allThoughts[index]),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        extendedIconLabelSpacing: isFabExtended ? 10 : 0,
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (context) => ThoughtModal(),
        ),
        label: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: isFabExtended ? const Text("Compose") : const SizedBox(),
        ),
        icon: const Icon(Icons.tag),
      ),
    );
  }
}
