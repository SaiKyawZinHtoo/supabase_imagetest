import 'package:image_test/models/post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostDatabase {
  final database = Supabase.instance.client.from('posts');

  // Create a new post
  Future createPost(Post newPost) async {
    await database.insert(newPost.toMap());
  }

  // Stream all posts
  final stream = Supabase.instance.client.from('posts').stream(
    primaryKey: ['id'],
  ).map((data) => data.map((postMap) => Post.fromJson(postMap)).toList());

  // Update a post
  Future updatePost(Post oldPost, String newDescription) async {
    await database
        .update({'description': newDescription}).eq('id', oldPost.id!);
  }

  // Delete a post
  Future deletePost(Post post) async {
    await database.delete().eq('id', post.id!);
  }
}
