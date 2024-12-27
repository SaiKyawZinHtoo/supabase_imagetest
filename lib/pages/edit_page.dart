import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditPostPage extends StatefulWidget {
  final int postId;
  final String title;
  final String description;
  final String imageUrl;

  const EditPostPage({
    Key? key,
    required this.postId,
    required this.title,
    required this.description,
    required this.imageUrl,
  }) : super(key: key);

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.title;
    _descriptionController.text = widget.description;
    _imageUrlController.text = widget.imageUrl;
  }

  Future<void> _updatePost(BuildContext context) async {
    final supabaseClient = Supabase.instance.client;

    try {
      final response = await supabaseClient
          .from('posts')
          .update({
            'title': _titleController.text,
            'description': _descriptionController.text,
            'imageUrl': _imageUrlController.text,
          })
          .eq('id', widget.postId)
          .select();

      if (response.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully!')),
        );
        Navigator.pop(context, true); // Pass true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post not found or update failed.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 4,
            ),
            // const SizedBox(height: 16),
            // TextField(
            //   controller: _imageUrlController,
            //   decoration: const InputDecoration(labelText: 'Image URL'),
            // ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _updatePost(context),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
