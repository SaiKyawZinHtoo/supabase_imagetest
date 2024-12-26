import 'package:flutter/material.dart';
import 'package:image_test/pages/post_page.dart';

class PostsPage extends StatelessWidget {
  final List<Map<String, dynamic>> posts = [
    {
      "title": "Flutter Basics",
      "description": "Learn how to build beautiful UIs with Flutter.",
      "postTime": DateTime.now().subtract(const Duration(hours: 2)),
      "imageUrl": "https://via.placeholder.com/400",
    },
    {
      "title": "State Management",
      "description": "Understanding state management techniques in Flutter.",
      "postTime": DateTime.now().subtract(const Duration(days: 1)),
      "imageUrl": "https://via.placeholder.com/400",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Posts"),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostCard(
            title: post['title'],
            description: post['description'],
            postTime: post['postTime'],
            //imageUrl: post['imageUrl'],
          );
        },
      ),
    );
  }
}
