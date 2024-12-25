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
  String? uploadedImageUrl;

  // Pick an image from the gallery
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

  // Upload image to Supabase storage
  Future<void> uploadImage(XFile imageFile) async {
    final bucket = Supabase.instance.client.storage.from('posts');
    final imageName = DateTime.now().toIso8601String() + '.jpg';

    try {
      debugPrint('Uploading image: $imageName');
      // Upload image to storage
      final response = await bucket.upload(imageName, File(imageFile.path));

      debugPrint('Upload response: $response');

      if (response.isEmpty) {
        throw Exception('Image upload failed: Response was empty.');
      }

      // Get public URL for the uploaded image
      final imageUrlResponse = await bucket.getPublicUrl(imageName);
      final imageUrl = imageUrlResponse;

      debugPrint('Generated public URL: $imageUrl');

      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception('Failed to generate public URL.');
      }

      setState(() {
        uploadedImageUrl = imageUrl;
      });

      _showSnackBar('Image uploaded successfully: $imageUrl');
    } catch (e) {
      debugPrint('Error: $e');
      _showSnackBar('Failed to upload image: $e');
    }
  }

  // Show snack bar message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Create a post (with title, description, and image URL)
  Future<void> createPost(String title, String description) async {
    if (uploadedImageUrl == null) {
      _showSnackBar('Please upload an image first');
      return;
    }

    try {
      // Simulate post creation (e.g., save to database)
      debugPrint('Creating post: $title');
      debugPrint('Description: $description');
      debugPrint('Image URL: $uploadedImageUrl');

      // Here you would insert the post into the database or backend.
      // For now, we'll just print it out.

      _showSnackBar('Post created successfully');
    } catch (e) {
      _showSnackBar('Failed to create post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create a New Post',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple),
            ),
            SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Enter post title',
                labelText: 'Title',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: 'Enter post description',
                labelText: 'Description',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (selectedImage != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(selectedImage!.path),
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: Icon(Icons.photo_library, color: Colors.white),
              label: Center(
                  child: Text('Select Image',
                      style: TextStyle(color: Colors.white))),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (selectedImage != null) {
                  setState(() {
                    isLoading = true;
                  });
                  await uploadImage(selectedImage!);
                  setState(() {
                    isLoading = false;
                  });
                } else {
                  _showSnackBar('Please select an image');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Center(
                  child: Text('Upload Image',
                      style: TextStyle(color: Colors.white))),
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () async {
                      await createPost(
                        titleController.text,
                        descriptionController.text,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Center(
                        child: Text('Create Post',
                            style: TextStyle(color: Colors.white))),
                  ),
          ],
        ),
      ),
    );
  }
}
