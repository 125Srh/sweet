import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_appbar.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/admin_header.dart';
import '../widgets/admin_search.dart';
import '../widgets/admin_list.dart';
import '../widgets/admin_footer.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<AdminsProvider>().cargarCategoriasYMarcas(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminsProvider>();

    return Scaffold(
      appBar: const AdminAppBar(),
      drawer: const AdminDrawer(),

      body: Column(
        children: [
          const AdminHeader(),
          AdminSearch(),

          Expanded(child: AdminList(provider: provider)),

          AdminFooter(provider: provider),
        ],
      ),
    );
  }
}
