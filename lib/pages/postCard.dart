import 'package:flutter/material.dart';
import 'package:image_test/pages/edit_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostCard extends StatefulWidget {
  final int postId;
  final String title;
  final String description;
  final DateTime postTime;
  final String imageUrl;

  const PostCard({
    Key? key,
    required this.postId,
    required this.title,
    required this.description,
    required this.postTime,
    required this.imageUrl,
  }) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isDeleted = false;
  int _likeCount = 0;
  bool _isCommentSectionVisible = false;
  final TextEditingController _commentController = TextEditingController();

  Future<void> _deletePost(BuildContext context, String postId) async {
    final supabaseClient = Supabase.instance.client;

    try {
      final response =
          await supabaseClient.from('posts').delete().eq('id', postId).select();

      if (response.isEmpty) {
        _showSnackBar(context, 'Post not found or already deleted.');
      } else {
        _showSnackBar(context, 'Post deleted successfully!');
        setState(() {
          _isDeleted = true;
        });
      }
    } catch (e) {
      _showSnackBar(context, 'An unexpected error occurred: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDeleted) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(widget.postTime),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onSelected: (value) async {
                    if (value == 'Delete') {
                      _deletePost(context, widget.postId.toString());
                    } else if (value == 'Edit') {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPostPage(
                            postId: widget.postId,
                            title: widget.title,
                            description: widget.description,
                            imageUrl: widget.imageUrl,
                          ),
                        ),
                      );
                      if (result == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Post updated!')),
                        );
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'Edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Edit',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'Delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              widget.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: widget.imageUrl.isNotEmpty
                  ? Image.network(
                      widget.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors.grey,
                      ),
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey,
                    ),
            ),
            const SizedBox(height: 16),

            // Like, Comment, Share Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.thumb_up_alt_outlined,
                  label: 'Like ($_likeCount)',
                  context: context,
                  onTap: () {
                    setState(() {
                      _likeCount++;
                    });
                  },
                ),
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: 'Comment',
                  context: context,
                  onTap: () {
                    setState(() {
                      _isCommentSectionVisible = !_isCommentSectionVisible;
                    });
                  },
                ),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  context: context,
                  onTap: () {
                    // Share functionality here
                  },
                ),
              ],
            ),

            // Comment Section
            if (_isCommentSectionVisible) ...[
              const Divider(),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // Handle comment submission
                  _commentController.clear();
                  setState(() {
                    _isCommentSectionVisible = false;
                  });
                  _showSnackBar(context, 'Comment added!');
                },
                child: const Text('Post Comment'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} minutes ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hours ago";
    } else {
      return "${time.day}/${time.month}/${time.year} ${time.hour}:${time.minute}";
    }
  }
}
