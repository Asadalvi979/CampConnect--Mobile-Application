import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_profile.dart';
import '../data/community_mock_data.dart';
import '../services/community_store.dart';
import '../widgets/community_widgets.dart';

class EditPostScreen extends StatefulWidget {
  const EditPostScreen({required this.postId, super.key});

  final String postId;

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: CommunityStore.instance.post(widget.postId)?.content ?? '',
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final store = CommunityStore.instance;
    final post = store.post(widget.postId);
    if (post == null || post.authorId != CommunityMockData.currentUserId) {
      showCommunityMessage(context, 'Only your own posts can be edited.');
      return;
    }
    store.editPost(post.id, _contentController.text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final store = CommunityStore.instance;
    final post = store.post(widget.postId);
    final community = post == null ? null : store.community(post.communityId);
    final profile = UserProfileStore.instance.profile.value;
    final canEdit =
        post != null && post.authorId == CommunityMockData.currentUserId;
    return CommunityScaffold(
      title: 'Edit Post',
      body: !canEdit
          ? const Center(child: Text('Only the post owner can edit this post.'))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                children: [
                  CommunityCardSurface(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.groups_outlined,
                          color: AppColors.deepPrimary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            community?.name ?? 'Community',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Icon(Icons.lock_outline, size: 17),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  CommunityCardSurface(
                    child: Row(
                      children: [
                        CommunityAvatar(profile.name, radius: 21),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            '${profile.name} (You)\n${profile.roleLabel}',
                            style: const TextStyle(fontSize: 12, height: 1.5),
                          ),
                        ),
                        const Text(
                          'Unsaved edits',
                          style: TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  CommunityCardSurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Post Content',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _contentController,
                          maxLength: 2000,
                          minLines: 6,
                          maxLines: 12,
                          decoration: const InputDecoration(
                            hintText: 'What updates would you like to share?',
                            filled: true,
                            fillColor: AppColors.paleBlue,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            counterText: '',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Posts cannot be saved empty.';
                            }
                            return null;
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _contentController,
                            builder: (context, value, _) => Text(
                              '${value.text.length} / 2000',
                              style: const TextStyle(
                                color: AppColors.mutedText,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  CommunityCardSurface(
                    color: AppColors.paleBlue,
                    child: const Text(
                      'Posts cannot be saved empty. Changes update this preview in memory only.',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Save Changes'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
    );
  }
}
