import 'package:flutter/material.dart';

import '../authentication/models/otp_screen_arguments.dart';
import '../authentication/screens/email_otp_screen.dart';
import '../authentication/screens/forgot_password_screen.dart';
import '../authentication/screens/admin_login_preview_screen.dart';
import '../authentication/screens/login_screen.dart';
import '../authentication/screens/splash_screen.dart';
import '../authentication/screens/student_registration_screen.dart';
import '../admin_panel/models/admin_route_arguments.dart';
import '../admin_panel/screens/admin_dashboard_screen.dart';
import '../admin_panel/screens/admin_user_details_screen.dart';
import '../admin_panel/screens/admin_users_screen.dart';
import '../community/models/community_route_arguments.dart';
import '../community/screens/comments_screen.dart';
import '../community/screens/community_details_screen.dart';
import '../community/screens/community_list_screen.dart';
import '../community/screens/community_members_screen.dart';
import '../community/screens/create_post_screen.dart';
import '../community/screens/edit_post_screen.dart';
import '../community/screens/post_details_screen.dart';
import '../home_dashboard/models/dashboard_role.dart';
import '../home_dashboard/screens/alumni_dashboard_screen.dart';
import '../home_dashboard/screens/senior_dashboard_screen.dart';
import '../home_dashboard/screens/student_dashboard_screen.dart';
import '../mentorship/models/mentorship_route_arguments.dart';
import '../mentorship/screens/active_mentorships_screen.dart';
import '../mentorship/screens/alumni_directory_screen.dart';
import '../mentorship/screens/alumni_profile_screen.dart';
import '../mentorship/screens/mentorship_request_details_screen.dart';
import '../mentorship/screens/mentorship_requests_screen.dart';
import '../mentorship/screens/request_mentorship_screen.dart';
import '../messaging/models/messaging_route_arguments.dart';
import '../messaging/screens/attachment_preview_screen.dart';
import '../messaging/screens/chat_screen.dart';
import '../messaging/screens/conversations_list_screen.dart';
import '../messaging/screens/friend_requests_screen.dart';
import '../messaging/screens/friends_list_screen.dart';
import '../notifications_announcements/models/announcement_route_arguments.dart';
import '../notifications_announcements/screens/announcement_create_screen.dart';
import '../notifications_announcements/screens/announcement_details_screen.dart';
import '../notifications_announcements/screens/announcement_list_screen.dart';
import '../notifications_announcements/screens/notification_list_screen.dart';
import '../profile/models/user_profile.dart';
import '../profile/screens/edit_profile_screen.dart';
import '../profile/screens/my_profile_screen.dart';
import '../profile/screens/other_user_public_profile_screen.dart';
import '../profile/screens/profile_settings_screen.dart';
import '../project_collaboration/models/project_route_arguments.dart';
import '../project_collaboration/screens/express_interest_screen.dart';
import '../project_collaboration/screens/my_projects_screen.dart';
import '../project_collaboration/screens/project_details_screen.dart';
import '../project_collaboration/screens/project_form_screens.dart';
import '../project_collaboration/screens/project_interest_details_screen.dart';
import '../project_collaboration/screens/project_interests_screen.dart';
import '../project_collaboration/screens/project_list_screen.dart';
import '../resources/models/resource_route_arguments.dart';
import '../resources/screens/my_resources_screen.dart';
import '../resources/screens/resource_details_screen.dart';
import '../resources/screens/resource_library_screen.dart';
import '../resources/screens/resource_moderation_details_screen.dart';
import '../resources/screens/resource_moderation_screen.dart';
import '../resources/screens/resource_report_screen.dart';
import '../resources/screens/resource_status_screen.dart';
import '../resources/screens/resource_upload_screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const adminLogin = '/login/admin-preview';
  static const register = '/register';
  static const verifyEmail = '/verify-email';
  static const forgotPassword = '/forgot-password';
  static const studentDashboard = '/dashboard/student';
  static const seniorDashboard = '/dashboard/senior';
  static const alumniDashboard = '/dashboard/alumni';
  static const editProfile = '/profile/edit';
  static const profileSettings = '/profile/settings';
  static const publicProfile = '/profile/public';

  static const communities = '/community';
  static const communityDetails = '/community/details';
  static const communityMembers = '/community/members';
  static const communityCreatePost = '/community/post/create';
  static const communityPostDetails = '/community/post';
  static const communityComments = '/community/comments';
  static const communityEditPost = '/community/post/edit';
  static const alumniProfile = '/mentorship/alumni-profile';
  static const mentorshipRequest = '/mentorship/request';
  static const mentorshipRequests = '/mentorship/requests';
  static const mentorshipRequestDetails = '/mentorship/requests/details';
  static const activeMentorships = '/mentorship/active';
  static const projects = '/projects';
  static const projectDetails = '/projects/details';
  static const projectCreate = '/projects/create';
  static const projectEdit = '/projects/edit';
  static const projectExpressInterest = '/projects/interest/create';
  static const projectInterests = '/projects/interests';
  static const projectInterestDetails = '/projects/interests/details';
  static const myProjects = '/projects/mine';
  static const messages = '/messages';
  static const messageChat = '/messages/chat';
  static const messageFriends = '/messages/friends';
  static const messageFriendRequests = '/messages/friend-requests';
  static const messageImagePreview = '/messages/attachment/image';
  static const messageFilePreview = '/messages/attachment/file';
  static const resources = '/resources';
  static const resourceDetails = '/resources/details';
  static const resourceUpload = '/resources/upload';
  static const myResources = '/resources/mine';
  static const resourceStatus = '/resources/status';
  static const resourceReport = '/resources/report';
  static const resourceModeration = '/resources/moderation';
  static const resourceModerationDetails = '/resources/moderation/details';
  static const mentorship = '/mentorship';
  static const announcements = '/announcements';
  static const announcementDetails = '/announcements/details';
  static const announcementCreate = '/announcements/create';
  static const profile = '/profile';
  static const notifications = '/notifications';
  static const adminDashboard = '/admin';
  static const adminUsers = '/admin/users';
  static const adminUserDetails = '/admin/users/details';

  static String dashboardRouteFor(DashboardRole role) => switch (role) {
    DashboardRole.student => studentDashboard,
    DashboardRole.senior => seniorDashboard,
    DashboardRole.alumni => alumniDashboard,
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _route(const SplashScreen(), settings);
      case login:
        return _route(const LoginScreen(), settings);
      case adminLogin:
        return _route(const AdminLoginPreviewScreen(), settings);
      case register:
        return _route(const StudentRegistrationScreen(), settings);
      case verifyEmail:
        final arguments = settings.arguments;
        if (arguments is! OtpScreenArguments) {
          return _route(const LoginScreen(), const RouteSettings(name: login));
        }
        return _route(EmailOtpScreen(arguments: arguments), settings);
      case forgotPassword:
        return _route(const ForgotPasswordScreen(), settings);
      case studentDashboard:
        return _route(const StudentDashboardScreen(), settings);
      case seniorDashboard:
        return _route(const SeniorDashboardScreen(), settings);
      case alumniDashboard:
        return _route(const AlumniDashboardScreen(), settings);
      case adminDashboard:
        return _route(const AdminDashboardScreen(), settings);
      case adminUsers:
        return _route(const AdminUsersScreen(), settings);
      case adminUserDetails:
        final arguments = settings.arguments;
        if (arguments is! AdminRouteArguments || arguments.userId == null) {
          return _route(
            const AdminUsersScreen(),
            const RouteSettings(name: adminUsers),
          );
        }
        return _route(AdminUserDetailsScreen(arguments: arguments), settings);
      case profile:
        final role = settings.arguments;
        if (role is DashboardRole) {
          UserProfileStore.instance.initializeRoleFromDashboard(switch (role) {
            DashboardRole.student => UserProfileRole.student,
            DashboardRole.senior => UserProfileRole.senior,
            DashboardRole.alumni => UserProfileRole.alumni,
          });
        }
        return _route(const MyProfileScreen(), settings);
      case editProfile:
        return _route(const EditProfileScreen(), settings);
      case profileSettings:
        return _route(const ProfileSettingsScreen(), settings);
      case publicProfile:
        final arguments = settings.arguments;
        if (arguments is! PublicProfileArguments) {
          return _route(
            const MyProfileScreen(),
            const RouteSettings(name: profile),
          );
        }
        return _route(
          OtherUserPublicProfileScreen(userId: arguments.userId),
          settings,
        );
      case communities:
        return _route(const CommunityListScreen(), settings);
      case communityDetails:
        final arguments = settings.arguments;
        if (arguments is! CommunityRouteArguments) {
          return _route(
            const CommunityListScreen(),
            const RouteSettings(name: communities),
          );
        }
        return _route(
          CommunityDetailsScreen(communityId: arguments.communityId),
          settings,
        );
      case communityMembers:
        final arguments = settings.arguments;
        if (arguments is! CommunityRouteArguments) {
          return _route(
            const CommunityListScreen(),
            const RouteSettings(name: communities),
          );
        }
        return _route(
          CommunityMembersScreen(communityId: arguments.communityId),
          settings,
        );
      case communityCreatePost:
        final arguments = settings.arguments;
        if (arguments is! CommunityRouteArguments) {
          return _route(
            const CommunityListScreen(),
            const RouteSettings(name: communities),
          );
        }
        return _route(
          CreatePostScreen(communityId: arguments.communityId),
          settings,
        );
      case communityPostDetails:
        final arguments = settings.arguments;
        if (arguments is! CommunityRouteArguments || arguments.postId == null) {
          return _route(
            const CommunityListScreen(),
            const RouteSettings(name: communities),
          );
        }
        return _route(PostDetailsScreen(postId: arguments.postId!), settings);
      case communityComments:
        final arguments = settings.arguments;
        if (arguments is! CommunityRouteArguments || arguments.postId == null) {
          return _route(
            const CommunityListScreen(),
            const RouteSettings(name: communities),
          );
        }
        return _route(CommentsScreen(postId: arguments.postId!), settings);
      case communityEditPost:
        final arguments = settings.arguments;
        if (arguments is! CommunityRouteArguments || arguments.postId == null) {
          return _route(
            const CommunityListScreen(),
            const RouteSettings(name: communities),
          );
        }
        return _route(EditPostScreen(postId: arguments.postId!), settings);
      case mentorship:
        final arguments = settings.arguments;
        final role = arguments is MentorshipRouteArguments
            ? arguments.viewerRole
            : UserProfileStore.instance.profile.value.role;
        return _route(AlumniDirectoryScreen(viewerRole: role), settings);
      case alumniProfile:
        final arguments = settings.arguments;
        if (arguments is! MentorshipRouteArguments ||
            arguments.alumniId == null) {
          return _route(
            AlumniDirectoryScreen(
              viewerRole: UserProfileStore.instance.profile.value.role,
            ),
            const RouteSettings(name: mentorship),
          );
        }
        return _route(
          AlumniProfileScreen(
            alumniId: arguments.alumniId!,
            viewerRole: arguments.viewerRole,
          ),
          settings,
        );
      case mentorshipRequest:
        final arguments = settings.arguments;
        if (arguments is! MentorshipRouteArguments ||
            arguments.alumniId == null) {
          return _route(
            AlumniDirectoryScreen(
              viewerRole: UserProfileStore.instance.profile.value.role,
            ),
            const RouteSettings(name: mentorship),
          );
        }
        return _route(
          RequestMentorshipScreen(
            alumniId: arguments.alumniId!,
            viewerRole: arguments.viewerRole,
          ),
          settings,
        );
      case mentorshipRequests:
        final arguments = settings.arguments;
        final role = arguments is MentorshipRouteArguments
            ? arguments.viewerRole
            : UserProfileStore.instance.profile.value.role;
        return _route(
          MentorshipRequestsScreen(
            viewerRole: role,
            initialTab:
                arguments is MentorshipRouteArguments &&
                    arguments.initialTab != null
                ? arguments.initialTab!
                : role == UserProfileRole.alumni
                ? 1
                : 0,
          ),
          settings,
        );
      case mentorshipRequestDetails:
        final arguments = settings.arguments;
        if (arguments is! MentorshipRouteArguments ||
            arguments.requestId == null) {
          return _route(
            MentorshipRequestsScreen(
              viewerRole: UserProfileStore.instance.profile.value.role,
              initialTab: 0,
            ),
            const RouteSettings(name: mentorshipRequests),
          );
        }
        return _route(
          MentorshipRequestDetailsScreen(
            requestId: arguments.requestId!,
            viewerRole: arguments.viewerRole,
          ),
          settings,
        );
      case activeMentorships:
        final arguments = settings.arguments;
        final role = arguments is MentorshipRouteArguments
            ? arguments.viewerRole
            : UserProfileStore.instance.profile.value.role;
        return _route(ActiveMentorshipsScreen(viewerRole: role), settings);
      case projects:
        final arguments = settings.arguments;
        final role = arguments is ProjectRouteArguments
            ? arguments.viewerRole
            : UserProfileStore.instance.profile.value.role;
        return _route(ProjectListScreen(viewerRole: role), settings);
      case projectDetails:
        final arguments = settings.arguments;
        if (arguments is! ProjectRouteArguments ||
            arguments.projectId == null) {
          return _route(
            ProjectListScreen(
              viewerRole: UserProfileStore.instance.profile.value.role,
            ),
            const RouteSettings(name: projects),
          );
        }
        return _route(
          ProjectDetailsScreen(
            projectId: arguments.projectId!,
            viewerRole: arguments.viewerRole,
          ),
          settings,
        );
      case projectCreate:
        final arguments = settings.arguments;
        final role = arguments is ProjectRouteArguments
            ? arguments.viewerRole
            : UserProfileStore.instance.profile.value.role;
        return _route(CreateProjectScreen(viewerRole: role), settings);
      case projectEdit:
        final arguments = settings.arguments;
        if (arguments is! ProjectRouteArguments ||
            arguments.projectId == null) {
          return _route(
            ProjectListScreen(
              viewerRole: UserProfileStore.instance.profile.value.role,
            ),
            const RouteSettings(name: projects),
          );
        }
        return _route(
          EditProjectScreen(
            viewerRole: arguments.viewerRole,
            projectId: arguments.projectId!,
          ),
          settings,
        );
      case projectExpressInterest:
        final arguments = settings.arguments;
        if (arguments is! ProjectRouteArguments ||
            arguments.projectId == null) {
          return _route(
            ProjectListScreen(
              viewerRole: UserProfileStore.instance.profile.value.role,
            ),
            const RouteSettings(name: projects),
          );
        }
        return _route(
          ExpressInterestScreen(
            viewerRole: arguments.viewerRole,
            projectId: arguments.projectId!,
          ),
          settings,
        );
      case projectInterests:
        final arguments = settings.arguments;
        if (arguments is! ProjectRouteArguments ||
            arguments.projectId == null) {
          return _route(
            ProjectListScreen(
              viewerRole: UserProfileStore.instance.profile.value.role,
            ),
            const RouteSettings(name: projects),
          );
        }
        return _route(
          ProjectInterestsScreen(
            viewerRole: arguments.viewerRole,
            projectId: arguments.projectId!,
          ),
          settings,
        );
      case projectInterestDetails:
        final arguments = settings.arguments;
        if (arguments is! ProjectRouteArguments ||
            arguments.projectId == null ||
            arguments.applicantId == null) {
          return _route(
            ProjectListScreen(
              viewerRole: UserProfileStore.instance.profile.value.role,
            ),
            const RouteSettings(name: projects),
          );
        }
        return _route(
          ProjectInterestDetailsScreen(
            viewerRole: arguments.viewerRole,
            projectId: arguments.projectId!,
            applicantId: arguments.applicantId!,
          ),
          settings,
        );
      case myProjects:
        final arguments = settings.arguments;
        final role = arguments is ProjectRouteArguments
            ? arguments.viewerRole
            : UserProfileStore.instance.profile.value.role;
        return _route(MyProjectsScreen(viewerRole: role), settings);
      case messages:
        final arguments = settings.arguments;
        final role = arguments is MessagingRouteArguments
            ? arguments.viewerRole
            : UserProfileStore.instance.profile.value.role;
        return _route(ConversationsListScreen(viewerRole: role), settings);
      case messageChat:
        final arguments = settings.arguments;
        if (arguments is! MessagingRouteArguments ||
            arguments.conversationId == null) {
          return _route(
            ConversationsListScreen(
              viewerRole: UserProfileStore.instance.profile.value.role,
            ),
            const RouteSettings(name: messages),
          );
        }
        return _route(
          ChatScreen(
            viewerRole: arguments.viewerRole,
            conversationId: arguments.conversationId!,
          ),
          settings,
        );
      case messageFriends:
        final arguments = settings.arguments;
        final role = arguments is MessagingRouteArguments
            ? arguments.viewerRole
            : UserProfileStore.instance.profile.value.role;
        return _route(FriendsListScreen(viewerRole: role), settings);
      case messageFriendRequests:
        final arguments = settings.arguments;
        final role = arguments is MessagingRouteArguments
            ? arguments.viewerRole
            : UserProfileStore.instance.profile.value.role;
        return _route(FriendRequestsScreen(viewerRole: role), settings);
      case messageImagePreview:
      case messageFilePreview:
        final arguments = settings.arguments;
        if (arguments is! MessagingRouteArguments ||
            arguments.attachmentId == null) {
          return _route(
            ConversationsListScreen(
              viewerRole: UserProfileStore.instance.profile.value.role,
            ),
            const RouteSettings(name: messages),
          );
        }
        return _route(
          AttachmentPreviewScreen(
            viewerRole: arguments.viewerRole,
            attachmentId: arguments.attachmentId!,
            isImage: settings.name == messageImagePreview,
          ),
          settings,
        );
      case resources:
        final arguments = settings.arguments;
        final role = arguments is ResourceRouteArguments
            ? arguments.viewerRole
            : UserProfileStore.instance.profile.value.role;
        return _route(ResourceLibraryScreen(viewerRole: role), settings);
      case resourceDetails:
        final arguments = settings.arguments;
        if (arguments is! ResourceRouteArguments ||
            arguments.resourceId == null) {
          return _route(
            ResourceLibraryScreen(
              viewerRole: UserProfileStore.instance.profile.value.role,
            ),
            const RouteSettings(name: resources),
          );
        }
        return _route(
          ResourceDetailsScreen(
            viewerRole: arguments.viewerRole,
            resourceId: arguments.resourceId!,
          ),
          settings,
        );
      case resourceUpload:
        final arguments = settings.arguments;
        final role = arguments is ResourceRouteArguments
            ? arguments.viewerRole
            : UserProfileStore.instance.profile.value.role;
        return _route(ResourceUploadScreen(viewerRole: role), settings);
      case myResources:
        final arguments = settings.arguments;
        final role = arguments is ResourceRouteArguments
            ? arguments.viewerRole
            : UserProfileStore.instance.profile.value.role;
        return _route(MyResourcesScreen(viewerRole: role), settings);
      case resourceStatus:
        final arguments = settings.arguments;
        if (arguments is! ResourceRouteArguments ||
            arguments.resourceId == null) {
          return _route(
            MyResourcesScreen(
              viewerRole: UserProfileStore.instance.profile.value.role,
            ),
            const RouteSettings(name: myResources),
          );
        }
        return _route(
          ResourceStatusScreen(
            viewerRole: arguments.viewerRole,
            resourceId: arguments.resourceId!,
          ),
          settings,
        );
      case resourceReport:
        final arguments = settings.arguments;
        if (arguments is! ResourceRouteArguments ||
            arguments.resourceId == null) {
          return _route(
            ResourceLibraryScreen(
              viewerRole: UserProfileStore.instance.profile.value.role,
            ),
            const RouteSettings(name: resources),
          );
        }
        return _route(
          ResourceReportScreen(
            viewerRole: arguments.viewerRole,
            resourceId: arguments.resourceId!,
          ),
          settings,
        );
      case resourceModeration:
        final role = UserProfileStore.instance.profile.value.role;
        return _route(ResourceModerationScreen(viewerRole: role), settings);
      case resourceModerationDetails:
        final arguments = settings.arguments;
        if (arguments is! ResourceRouteArguments ||
            arguments.reportId == null) {
          return _route(
            ResourceModerationScreen(
              viewerRole: UserProfileStore.instance.profile.value.role,
            ),
            const RouteSettings(name: resourceModeration),
          );
        }
        return _route(
          ResourceModerationDetailsScreen(
            viewerRole: UserProfileStore.instance.profile.value.role,
            reportId: arguments.reportId!,
          ),
          settings,
        );
      case notifications:
        return _route(
          NotificationListScreen(
            viewerRole: UserProfileStore.instance.profile.value.role,
          ),
          settings,
        );
      case announcements:
        return _route(
          AnnouncementListScreen(
            viewerRole: UserProfileStore.instance.profile.value.role,
          ),
          settings,
        );
      case announcementDetails:
        final arguments = settings.arguments;
        if (arguments is! AnnouncementRouteArguments ||
            arguments.announcementId == null) {
          return _route(
            AnnouncementListScreen(
              viewerRole: UserProfileStore.instance.profile.value.role,
            ),
            const RouteSettings(name: announcements),
          );
        }
        return _route(
          AnnouncementDetailsScreen(announcementId: arguments.announcementId!),
          settings,
        );
      case announcementCreate:
        return _route(const AnnouncementCreateScreen(), settings);
      default:
        return _route(const LoginScreen(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _route(
    Widget screen,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => screen,
      settings: settings,
    );
  }
}
