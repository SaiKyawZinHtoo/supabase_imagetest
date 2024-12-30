import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.title;
    _descriptionController.text = widget.description;
    _imageUrlController.text = widget.imageUrl;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    final supabaseClient = Supabase.instance.client;

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath =
          await supabaseClient.storage.from('images').upload(fileName, image);

      if (filePath.isNotEmpty) {
        final publicUrl =
            supabaseClient.storage.from('images').getPublicUrl(filePath);
        return publicUrl;
      } else {
        throw Exception('File upload failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      return null;
    }
  }

  Future<void> _updatePost(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final supabaseClient = Supabase.instance.client;
    String? imageUrl = widget.imageUrl;

    if (_selectedImage != null) {
      final uploadedUrl = await _uploadImage(_selectedImage!);
      if (uploadedUrl != null) {
        imageUrl = uploadedUrl;
      }
    }

    try {
      final response = await supabaseClient
          .from('posts')
          .update({
            'title': _titleController.text,
            'description': _descriptionController.text,
            'imageUrl': imageUrl,
          })
          .eq('id', widget.postId)
          .select();

      if (response.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post not found or update failed.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update post: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
      ),
      body: Stack(
        children: [
          Padding(
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
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickImage,
                  child: _selectedImage == null
                      ? Image.network(
                          widget.imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          _selectedImage!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _updatePost(context),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
