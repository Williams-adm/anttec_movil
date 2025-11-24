import 'package:anttec_movil/app/ui/layout/view_models/layout_home_viewmodel.dart';
import 'package:anttec_movil/app/ui/layout/widgets/home/category_filter_w.dart';
import 'package:anttec_movil/app/ui/layout/widgets/home/header_home_w.dart';
import 'package:anttec_movil/app/ui/layout/widgets/home/search_w.dart';
import 'package:anttec_movil/app/ui/layout/widgets/home/section_title_w.dart';
import 'package:anttec_movil/app/ui/shared/widgets/error_dialog_w.dart';
import 'package:anttec_movil/app/ui/shared/widgets/loader_w.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LayoutHomeScreen extends StatefulWidget {
  final Widget content;
  final LayoutHomeViewmodel viewmodel;

  const LayoutHomeScreen({
    super.key,
    required this.content,
    required this.viewmodel,
  });

  @override
  State<LayoutHomeScreen> createState() => _LayoutHomeScreenState();
}

class _LayoutHomeScreenState extends State<LayoutHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewmodel,
      builder: (context, _) {
        return Scaffold(
          body: LoaderW(
            isLoading: widget.viewmodel.isloading,
            child: Column(
              children: [
                HeaderHomeW(
                  profileName: widget.viewmodel.profileName ?? '',
                  logout: _handleLogout,
                ),
                Form(
                  key: _formKey,
                  child: SearchW(controller: _searchController),
                ),
                CategoryFilterW(categories: widget.viewmodel.categories),
                SectionTitleW(),
                Expanded(child: widget.content),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    widget.viewmodel.removeListener(_viewModelListener);
    widget.viewmodel.loadProfile();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.viewmodel.loadProfile();
    widget.viewmodel.loadCategories();
    widget.viewmodel.addListener(_viewModelListener);
  }

  void _handleLogout() async {
    final success = await widget.viewmodel.logout();

    if (success && mounted) {
      context.goNamed('login');
    }
  }

  void _viewModelListener() {
    final errorMessage = widget.viewmodel.errorMessage;
    if (errorMessage != null) {
      ErrorDialogW.show(context, errorMessage);
    }
  }
}
