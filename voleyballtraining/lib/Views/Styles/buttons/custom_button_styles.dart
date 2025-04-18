// lib/Views/Styles/buttons/button_styles.dart
import 'package:flutter/material.dart';
// Asegúrate que las rutas de importación sean correctas
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';
import 'package:voleyballtraining/Views/Styles/tipography/text_styles.dart';

/// Define estilos reutilizables para los diferentes tipos de botones de Material.
///
/// Utiliza los colores de [AppColors] y los estilos de texto de [CustomTextStyles]
/// para mantener la consistencia con el tema general de la aplicación.
class CustomButtonStyles {

  /// Estilo base común para botones elevados y delineados.
  /// Define padding, forma y tamaño mínimo.
  static final ButtonStyle _baseElevatedOutlinedStyle = ButtonStyle(
    textStyle: MaterialStateProperty.all(CustomTextStyles.button), // Estilo de texto base para botones
    padding: MaterialStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
    ),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Bordes redondeados estándar
      ),
    ),
    minimumSize: MaterialStateProperty.all(const Size(88, 44)), // Tamaño mínimo W3C
    // Control de elevación y otros efectos se manejan por estado en cada estilo específico
    // para permitir diferencias (ej. botón primario vs. outlined).
    // Añade overlayColor para feedback visual al presionar/hover
    overlayColor: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.hovered)) {
          // Usa el color primario/secundario con baja opacidad para hover
          // Necesitamos saber el color base para hacer esto bien, se ajusta abajo
          return null; // Ajustado en estilos específicos
        }
        if (states.contains(MaterialState.pressed)) {
           // Usa el color primario/secundario con más opacidad para pressed
          return null; // Ajustado en estilos específicos
        }
        return null; // Sin overlay por defecto
      },
    ),
  );

  /// Estilo para el botón primario ([ElevatedButton] - acción principal).
  /// Fondo: [AppColors.primary], Texto: [AppColors.textLight]
  static ButtonStyle primary() {
    return _baseElevatedOutlinedStyle.copyWith(
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            // Usar color deshabilitado específico del tema oscuro/claro
            return AppColors.disabled; // Ajustado en AppColors para tema oscuro
          }
          return AppColors.primary; // Color primario normal (Naranja)
        },
      ),
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
         (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
             // Usar color de texto deshabilitado específico del tema oscuro/claro
            return AppColors.textDisabled; // Ajustado en AppColors para tema oscuro
          }
          // Texto sobre Naranja debe ser claro
          return AppColors.textLight;
        },
      ),
       elevation: MaterialStateProperty.resolveWith<double>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) return 0;
          if (states.contains(MaterialState.pressed)) return 6; // Más elevación al presionar
          if (states.contains(MaterialState.hovered)) return 4; // Elevación media en hover
          return 2; // Elevación normal
        },
      ),
       overlayColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          // Feedback visual sobre el color primario
          if (states.contains(MaterialState.hovered)) {
            return AppColors.textLight.withOpacity(0.08); // Blanco sutil
          }
          if (states.contains(MaterialState.pressed)) {
            return AppColors.textLight.withOpacity(0.12); // Blanco más notable
          }
          return null;
        },
      ),
    );
  }

  /// Estilo para el botón secundario ([ElevatedButton] - acción alternativa).
  /// Fondo: [AppColors.secondary], Texto: [AppColors.textLight]
  static ButtonStyle secondary() {
     return _baseElevatedOutlinedStyle.copyWith(
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return AppColors.disabled;
          }
          return AppColors.secondary; // Color secundario normal (Azul)
        },
      ),
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
         (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return AppColors.textDisabled;
          }
          // Texto sobre Azul también debería ser claro
          return AppColors.textLight;
        },
      ),
       elevation: MaterialStateProperty.resolveWith<double>(
        (Set<MaterialState> states) {
           if (states.contains(MaterialState.disabled)) return 0;
           if (states.contains(MaterialState.pressed)) return 6;
           if (states.contains(MaterialState.hovered)) return 4;
           return 2;
        },
      ),
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
           // Feedback visual sobre el color secundario
          if (states.contains(MaterialState.hovered)) {
            return AppColors.textLight.withOpacity(0.08); // Blanco sutil
          }
          if (states.contains(MaterialState.pressed)) {
            return AppColors.textLight.withOpacity(0.12); // Blanco más notable
          }
          return null;
        },
      ),
    );
  }

   /// Estilo para botones de texto ([TextButton] - acciones menos importantes).
   /// Texto: [AppColors.primary] (Naranja) por defecto para resaltar en tema oscuro.
   static ButtonStyle text() {
     // TextButton tiene su propio styleFrom, no hereda directamente de _baseElevatedOutlinedStyle
     return TextButton.styleFrom(
       foregroundColor: AppColors.primary, // Color del texto/icono Naranja
       textStyle: CustomTextStyles.button.copyWith(color: AppColors.primary), // Asegura color naranja
       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Padding adecuado para TextButton
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Bordes consistentes
       ),
     ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
           // Feedback visual usando el color primario con opacidad
          if (states.contains(MaterialState.hovered)) {
            return AppColors.primary.withOpacity(0.08);
          }
          if (states.contains(MaterialState.pressed)) {
            return AppColors.primary.withOpacity(0.12);
          }
          return null;
        },
      ),
     );
   }

   /// Estilo para botones Outlined ([OutlinedButton] - prioridad media).
   /// Borde y Texto: [AppColors.primary] (Naranja) por defecto.
   static ButtonStyle outlined() {
     return _baseElevatedOutlinedStyle.copyWith(
       // Sin color de fondo por defecto
       backgroundColor: MaterialStateProperty.all(Colors.transparent),
       // Color del texto y borde
       foregroundColor: MaterialStateProperty.resolveWith<Color>(
         (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return AppColors.textDisabled;
            }
            return AppColors.primary; // Naranja
         }
       ),
       // Definición del borde
       side: MaterialStateProperty.resolveWith<BorderSide>(
         (Set<MaterialState> states) {
            Color borderColor = AppColors.primary;
            if (states.contains(MaterialState.disabled)) {
              borderColor = AppColors.disabled;
            }
            return BorderSide(color: borderColor, width: 1.5);
         }
       ),
       // Quitar elevación por defecto para outlined
       elevation: MaterialStateProperty.all(0),
       // Ajustar overlay para que tenga fondo al presionar/hover
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
           // Feedback visual usando el color primario con opacidad como fondo
          if (states.contains(MaterialState.hovered)) {
            return AppColors.primary.withOpacity(0.08);
          }
          if (states.contains(MaterialState.pressed)) {
            return AppColors.primary.withOpacity(0.12);
          }
          return null;
        },
      ),
     );
   }

  // Asegúrate de que esta clase no pueda ser instanciada
  CustomButtonStyles._();
}