import 'package:flutter/material.dart';
import 'package:hashtagable_v3/widgets/hashtag_text_field.dart';
import 'package:realm/components/thought_card.dart';
import 'package:realm/main.dart';
import 'package:realm/model/thought.dart';

class ThoughtDetails extends StatefulWidget {
  final ThoughtModel thought;
  const ThoughtDetails({super.key, required this.thought});

  @override
  State<ThoughtDetails> createState() => _ThoughtDetailsState();
}

class _ThoughtDetailsState extends State<ThoughtDetails> {
  List<ThoughtModel> allReplies = [];
  TextEditingController textController = TextEditingController();
  bool isLoading = false;

  Future<void> getAllReplies() async {
    List<ThoughtModel> replies = [];
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
          .eq('head', widget.thought.id!)
          .order('created_at', ascending: false)
          .then(
            (value) => replies = value.map((e) {
              return ThoughtModel.fromJson(e);
            }).toList(),
          );
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
    setState(() {
      allReplies = replies;
    });
  }

  void getData() async {
    await getAllReplies();
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ThoughtCard(thought: widget.thought, clickDisabled: true),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Replies',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: allReplies.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => Container(
                      padding: EdgeInsets.only(left: 10),
                      margin: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            width: 1,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      ),
                      child: ThoughtCard(thought: allReplies[index]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          BottomAppBar(
            child: Row(
              children: [
                Expanded(
                  child: HashTagTextField(
                    controller: textController,
                    decoratedStyle: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      hintText: 'Reply to ${widget.thought.user?.name}',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);

                          try {
                            await supabase.from('thoughts').insert({
                              "body": textController.text,
                              "userId": supabase.auth.currentUser?.id,
                              "head": widget.thought.id,
                            });
                            textController.clear();
                            await getAllReplies();
                          } on Exception catch (e) {
                            debugPrint(e.toString());
                          }
                          setState(() => isLoading = false);
                        },
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
