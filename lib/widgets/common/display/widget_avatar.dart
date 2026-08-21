import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';

class WidgetAvatar extends StatelessWidget {


  // CONSTRUCTOR
  const WidgetAvatar({
    super.key,
    this.imageUrl,
    this.onTap,
    this.radius = 50,
  });


  // PROPERTIES
  /// URL da imagem do usuário.
  ///
  /// Futuramente será utilizada para carregar a foto
  /// armazenada no Firebase Storage.
  final String? imageUrl;

  /// Ação executada ao tocar no avatar.
  final VoidCallback? onTap;

  /// Tamanho do avatar.
  final double radius;


  // UI
  @override
  Widget build(BuildContext context) {

    final avatar = CircleAvatar(

      radius: radius,

      backgroundColor: ThemeColors.primary,

      backgroundImage:
          imageUrl != null && imageUrl!.isNotEmpty
              ? NetworkImage(imageUrl!)
              : null,

      child:
          imageUrl == null || imageUrl!.isEmpty
              ? Icon(
                  Icons.person,
                  color: ThemeColors.white,
                  size: radius * 0.9,
                )
              : null,

    );


    // AVATAR COM AÇÃO
    if (onTap == null) {
      return avatar;
    }

    return GestureDetector(

      onTap: onTap,

      child: avatar,

    );

  }

}