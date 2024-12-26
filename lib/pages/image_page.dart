import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_test/pages/postPage.dart';
import 'package:image_test/pages/post_page.dart';
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

  // Upload image and save post
  Future<void> uploadImageAndSavePost(
      XFile imageFile, String title, String description) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Step 1: Upload the image to Supabase storage
      final bucket = Supabase.instance.client.storage.from('images');
      final imageName = DateTime.now().toIso8601String() + '.jpg';

      final uploadResponse =
          await bucket.upload(imageName, File(imageFile.path));

      if (uploadResponse == null || uploadResponse.isEmpty) {
        throw Exception('Image upload failed.');
      }

      // Get the public URL of the uploaded image
      final imageUrl = bucket.getPublicUrl(imageName);
      debugPrint('Image URL: $imageUrl');

      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception('Failed to generate public URL.');
      }

      // Step 2: Save the post to the database
      final saveResponse = await Supabase.instance.client.from('posts').insert({
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
      });
      debugPrint('Save response: $saveResponse');

      ///အဲ့အပိုင်းမှာကိုကြတော့ ငါလုပ်ထားတာကြတော့ စစ်ထားတာပေါ့၊ တာပေမဲ့ဖြုတ်ပြီးတော့ထည့်လိုက်မည်ဆိုရင်တော့ရပြီးတော့ ထည့်လိုက်မည်ဆိုရင် null ဖြစ်နေတာပေါ့ တာပေမဲ့ ြဖုတ်လိုက်ရင်တော့ အဆင်ပြေတယ် ဖြစ်နေတယ် အဲ့တာကြောင့်မလို့ အဲ့အပိုင်းမှာကိုကြတော့ နည်းနည်းစစ်ဖို့ကိုလိုအုန်းမည်
      // if (saveResponse == null || saveResponse.isEmpty) {
      //   throw Exception('Failed to save post.');
      // }

      _showSnackBar('Post created successfully!');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostsPage(),
        ),
      );
    } catch (e) {
      debugPrint('Error: $e');
      _showSnackBar('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Show snack bar message
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
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
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
            Center(
              child: ElevatedButton.icon(
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
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: isLoading
                    ? null // Disable the button while loading
                    : () async {
                        if (selectedImage == null) {
                          _showSnackBar('Please select an image');
                          return;
                        }

                        if (titleController.text.isEmpty ||
                            descriptionController.text.isEmpty) {
                          _showSnackBar('Please fill in all fields');
                          return;
                        }

                        await uploadImageAndSavePost(
                          selectedImage!,
                          titleController.text,
                          descriptionController.text,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Upload Image and Save Post',
                        style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
