import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfoPage extends StatefulWidget {
  const AppInfoPage({super.key});

  @override
  State<AppInfoPage> createState() => _AppInfoPageState();
}

class _AppInfoPageState extends State<AppInfoPage> {
  PackageInfo? packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          packageInfo = info;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Info'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.blueGrey[900]!.withOpacity(0.95),
                      Colors.blueGrey[800]!.withOpacity(0.95),
                    ]
                  : [
                      Colors.white.withOpacity(0.95),
                      Colors.grey[50]!.withOpacity(0.95),
                    ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo and Title Section
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [Colors.blueGrey[800]!, Colors.blueGrey[900]!]
                      : [Colors.blue[50]!, Colors.blue[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // App Logo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'images/logo-YTS.png',
                      height: 64,
                      width: 64,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // App Name
                  Text(
                    packageInfo?.appName ?? 'YTS Movies',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Version Info
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Version ${packageInfo?.version ?? '2.1.0'} (${packageInfo?.buildNumber ?? '3'})',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // App Description
            _buildInfoCard(
              context,
              icon: Icons.info_outline,
              title: 'About',
              content:
                  'YTS Movies is a beautiful and intuitive movie browsing app that allows you to discover, search, and explore movies from the YTS database. Browse the latest releases, search by genre, and find your next favorite film.',
            ),

            const SizedBox(height: 16),

            // Developer Information
            _buildInfoCard(
              context,
              icon: Icons.code,
              title: 'Developer',
              content: 'Developed with ❤️ using Flutter',
              trailing: const Icon(Icons.flutter_dash, color: Colors.blue),
            ),

            const SizedBox(height: 16),

            // Features Section
            _buildInfoCard(
              context,
              icon: Icons.star,
              title: 'Features',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureItem('🎬', 'Browse latest movies'),
                  _buildFeatureItem('🔍', 'Advanced search and filtering'),
                  _buildFeatureItem('❤️', 'Save favorites'),
                  _buildFeatureItem('🎨', 'Beautiful modern UI'),
                  _buildFeatureItem('🌙', 'Dark and Light themes'),
                  _buildFeatureItem('📱', 'Responsive design'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Technical Information
            _buildInfoCard(
              context,
              icon: Icons.build,
              title: 'Technical Info',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTechItem('Package Name',
                      packageInfo?.packageName ?? 'com.example.ytsmovies'),
                  _buildTechItem(
                      'Build Number', packageInfo?.buildNumber ?? '3'),
                  _buildTechItem('Framework', 'Flutter'),
                  _buildTechItem('Platform', Theme.of(context).platform.name),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Legal Information
            _buildInfoCard(
              context,
              icon: Icons.gavel,
              title: 'Legal',
              content:
                  'This app is for educational and personal use only. All movie data is provided by YTS API. We do not host or distribute any copyrighted content.',
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.star,
                    label: 'Rate App',
                    onTap: () => _rateApp(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.share,
                    label: 'Share App',
                    onTap: () => _shareApp(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Copyright
            Text(
              '© ${DateTime.now().year} YTS Movies App',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Made with Flutter 💙',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? content,
    Widget? child,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: theme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          if (content != null || child != null) ...[
            const SizedBox(height: 12),
            if (content != null)
              Text(
                content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            if (child != null) child,
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.primaryColor,
                theme.primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _rateApp(BuildContext context) {
    HapticFeedback.lightImpact();
    // In a real app, this would open the app store
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for your interest in rating our app!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareApp(BuildContext context) {
    HapticFeedback.lightImpact();
    // In a real app, this would use the share plugin
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing functionality would be implemented here'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
