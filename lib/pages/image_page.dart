import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  XFile? selectedImage;
  bool isLoading = false;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = image;
      });
      debugPrint('Selected image: ${image.path}');
    }
  }

  Future<void> uploadPost(
      String title, String description, XFile imageFile) async {
    final bucket = Supabase.instance.client.storage.from('posts');
    final imageName = DateTime.now().toIso8601String() + '.jpg';

    try {
      debugPrint('Uploading image: $imageName');
      // Upload image to storage
      final response = await bucket.upload(imageName, File(imageFile.path));

      debugPrint('Upload response: $response');

      if (response.isEmpty) {
        throw Exception('Image upload failed: Response is empty.');
      }

      // Get public URL for the uploaded image
      final imageUrl = bucket.getPublicUrl(imageName);
      debugPrint('Generated public URL: $imageUrl');

      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception('Failed to generate public URL.');
      }

      // Insert post data into the database
      debugPrint('Inserting post data: $title, $description');
      final insertResponse =
          await Supabase.instance.client.from('posts').insert({
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('Insert response: ${insertResponse.data}');

      if (insertResponse.error != null) {
        throw Exception('Failed to save post: ${insertResponse.error.message}');
      }
    } catch (e) {
      debugPrint('Error: $e');
      throw Exception('Upload failed: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            if (selectedImage != null)
              Image.file(
                File(selectedImage!.path),
                height: 200,
                width: 200,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text('Select Image'),
            ),
            const SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      if (selectedImage != null) {
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          debugPrint('Uploading post...');
                          await uploadPost(
                            titleController.text,
                            descriptionController.text,
                            selectedImage!,
                          );
                          _showSnackBar('Post uploaded successfully');
                        } catch (e) {
                          _showSnackBar('Failed to upload post: $e');
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      } else {
                        _showSnackBar('Please select an image');
                      }
                    },
                    child: const Text('Upload Post'),
                  ),
          ],
        ),
      ),
    );
  }
}
