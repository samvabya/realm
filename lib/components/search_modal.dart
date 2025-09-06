import 'package:flutter/material.dart';
import 'package:realm/main.dart';
import 'package:realm/model/user.dart';
import 'package:realm/screens/profile_screen.dart';
import 'package:realm/util.dart';

class SearchModal extends StatefulWidget {
  const SearchModal({super.key});

  @override
  State<SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<SearchModal> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Column(
          children: [
            Autocomplete<UserModel>(
              displayStringForOption: (option) => option.name ?? 'Realm User',
              onSelected: (option) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(uid: option.id),
                ),
              ),
              fieldViewBuilder:
                  (
                    context,
                    textEditingController,
                    focusNode,
                    onFieldSubmitted,
                  ) => TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      hintText: 'Search Users',
                      suffixIcon: isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            )
                          : null,
                    ),
                  ),
              optionsViewBuilder: (context, onSelected, options) =>
                  ListView.builder(
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(index == 0 ? 20 : 0),
                            bottom: Radius.circular(
                              index == options.length - 1 ? 20 : 0,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              onTap: () => onSelected(option),
                              title: Text(option.name ?? 'Realm User'),
                              subtitle: Text(
                                '@${getUsernameByEmail(option.email)}',
                              ),
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundImage: option.image != null
                                    ? NetworkImage(formattedUrl(option.image!))
                                    : null,
                                child: option.image == null
                                    ? const Icon(Icons.person, size: 30)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text.isNotEmpty) {
                  setState(() => isLoading = true);

                  final res = await supabase
                      .from('users')
                      .select()
                      .ilike('name', '%${textEditingValue.text}%')
                      .or('email.ilike.%${textEditingValue.text}%')
                      .limit(5);

                  setState(() => isLoading = false);
                  if (res.isEmpty) return [];
                  return res.map((e) => UserModel.fromJson(e)).toList();
                }
                return [];
              },
            ),
          ],
        ),
      ),
    );
  }
}
