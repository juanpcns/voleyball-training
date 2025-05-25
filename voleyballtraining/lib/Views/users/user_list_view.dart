  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';

  import '../../models/user_model.dart';
  import '../../providers/user_provider.dart';
  import '../profile/user_detail_view.dart';
  import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';
  import 'package:voleyballtraining/Views/Styles/tipography/text_styles.dart';

  // Importa el fondo global
  import 'package:voleyballtraining/Views/Styles/templates/home_view_template.dart';

  class UserListView extends StatefulWidget {
    final UserModel userModel;

    const UserListView({Key? key, required this.userModel}) : super(key: key);

    @override
    State<UserListView> createState() => _UserListViewState();
  }

  class _UserListViewState extends State<UserListView> {
    late Future<List<UserModel>> _usersFuture;

    @override
    void initState() {
      super.initState();
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _usersFuture = userProvider.fetchPlayers();
    }

    @override
    Widget build(BuildContext context) {
      final textTheme = Theme.of(context).textTheme;

      return HomeViewTemplate(
        title: 'Gestionar Usuarios',
        body: FutureBuilder<List<UserModel>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error al cargar usuarios: ${snapshot.error}',
                  style: textTheme.bodyMedium,
                ),
              );
            }

            final users = snapshot.data ?? [];

            if (users.isEmpty) {
              return const Center(child: Text('No se encontraron usuarios.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  color: AppColors.surfaceDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?'),
                    ),
                    title: Text(user.fullName, style: CustomTextStyles.bodyWhite.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.role, style: CustomTextStyles.captionWhite),
                        Text(user.email, style: CustomTextStyles.captionWhite),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserDetailView(user: user),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Aquí puedes navegar a la vista para crear nuevos usuarios o planes
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    }
  }
