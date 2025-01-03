import 'package:flutter/material.dart'; // Ensure this import points to your PostCard widget
import 'package:image_test/pages/postCard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostsPage extends StatefulWidget {
  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      final List<dynamic> response = await Supabase.instance.client
          .from('posts')
          .select('*')
          .order('created_at', ascending: false);

      setState(() {
        posts = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshPosts() async {
    setState(() {
      isLoading = true;
    });
    await fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Posts"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurple,
      ),
      endDrawer: EndDrawerButton(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshPosts,
              child: posts.isEmpty
                  ? const Center(child: Text("No posts available"))
                  : ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return PostCard(
                          postId: post['id'],
                          title: post['title'],
                          description: post['description'],
                          postTime: DateTime.parse(post['created_at']),
                          imageUrl: post['imageUrl'],
                        );
                      },
                    ),
            ),
    );
  }
}
