import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_profile.dart';
import '../services/community_store.dart';
import '../widgets/community_widgets.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({required this.communityId, super.key});

  final String communityId;

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _publish() {
    if (!_formKey.currentState!.validate()) return;
    CommunityStore.instance.addPost(
      widget.communityId,
      _contentController.text,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final community = CommunityStore.instance.community(widget.communityId);
    final profile = UserProfileStore.instance.profile.value;
    return CommunityScaffold(
      title: 'Create Post',
      actions: [TextButton(onPressed: _publish, child: const Text('Publish'))],
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            CommunityCardSurface(
              color: AppColors.lightBlue,
              child: Row(
                children: [
                  const Icon(
                    Icons.groups_outlined,
                    color: AppColors.deepPrimary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Posting in ${community?.name ?? 'Community'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            CommunityCardSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CommunityAvatar(profile.name, radius: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${profile.roleLabel} • ${profile.semester}',
                              style: const TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 11,
                              ),
                            ),
                            const CommunityPill('Public to Community'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _contentController,
                    maxLength: 2000,
                    minLines: 7,
                    maxLines: 12,
                    decoration: const InputDecoration(
                      hintText: "What's on your mind? Share campus projects, research questions, or ideas...",
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Write something before publishing.';
                      }
                      if (value.trim().length > 2000) {
                        return 'Posts must be 2000 characters or fewer.';
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add to your post',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final item in [
                        (title: 'Photo', icon: Icons.image_outlined),
                        (title: 'Document', icon: Icons.description_outlined),
                        (title: 'Code', icon: Icons.code),
                        (title: 'Poll', icon: Icons.poll_outlined),
                      ])
                        OutlinedButton.icon(
                          onPressed: () => showCommunityMessage(
                            context,
                            '${item.title} attachments are not available in this local preview.',
                          ),
                          icon: Icon(item.icon, size: 17),
                          label: Text(item.title),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your post will be visible to community members. Changes are held only in this running preview.',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _publish,
                icon: const Icon(Icons.send),
                label: const Text('Publish'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
