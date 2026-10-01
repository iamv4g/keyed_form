part of 'login_form.dart';

class _LoginTextField extends StatelessWidget {
  const _LoginTextField({
    required this.field,
    required this.label,
    this.obscureText = false,
  });

  final FieldRef<LoginSchema, String> field;
  final String label;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return KeyedFormField.text<LoginSchema>(
      field: field,
      builder: (context, f, controller) => TextField(
        controller: controller,
        obscureText: obscureText,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
          labelText: label,
          errorText: f.errorText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
