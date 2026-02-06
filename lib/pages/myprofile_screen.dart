import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/utils/keys.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/api_client.dart';
import '../utils/menu_button.dart';
import '../config.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  DateTime? selectedDate;
  String? selectedGender;
  bool isLoading = false;
  late ApiClient api;
  late Future<Map<String, String?>> user;
  String? avatarUrl;
  String? pickedAvatarPath;
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter email';
    String pattern = r'^[^@]+@[^@]+\.[^@]+';
    if (!RegExp(pattern).hasMatch(value.trim())) return 'Enter valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password cannot be empty';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[0-9]').hasMatch(value))
      return 'Password must contain a digit';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain a special character';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    api = ApiClient();
    nameController = TextEditingController();
    emailController = TextEditingController();
    loadUserData();
  }

  void loadUserData() {
    user = getCachedUser();
    user.then((data) {
      setState(() {
        selectedGender = data['gender'];
        avatarUrl = data['avatar'];
        if (data['birthDate'] != null) {
          selectedDate = DateTime.tryParse(data['birthDate']!)?.toLocal();
        }
        nameController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? '';
      });
    });
  }

  Future<void> pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> saveProfile() async {
    final emailError = validateEmail(emailController.text.trim());
    if (emailError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(emailError)));
      return;
    }

    // Если есть поле с паролем для смены прямо здесь, можно добавить:
    // final passwordError = validatePassword(passwordController.text.trim());
    // if (passwordError != null) { ... }

    if (selectedDate == null && selectedGender == null) return;

    setState(() => isLoading = true);

    try {
      if (pickedAvatarPath != null) {
        await updateProfileWithAvatar(avatarPath: pickedAvatarPath);
      }
      final res = await api.post(updateProfile, {
        'birthDate': selectedDate?.toIso8601String(),
        'gender': selectedGender,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
      });

      if (res.statusCode == 200) {
        await getInfoAndCache();
        loadUserData();
        setState(() {
          pickedAvatarPath = null;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(tr(Keys.profileUpdated))));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: ${res.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка при сохранении: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateProfileWithAvatar({String? avatarPath}) async {
    final request = await api.multipartRequest(updateProfile);

    if (avatarPath != null) {
      request.files.add(await MultipartFile.fromPath('avatar', avatarPath));
    }

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Avatar upload failed');
    }
  }

  Future<void> pickAvatar() async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(tr(Keys.chooseFromGallery)),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() {
                      pickedAvatarPath = image.path;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(tr(Keys.takePhoto)),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null) {
                    setState(() {
                      pickedAvatarPath = image.path;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: Text(tr(Keys.cancel)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> uploadAvatar(String path) async {
    try {
      await updateProfileWithAvatar(avatarPath: path);
      await getInfoAndCache();
      setState(() {
        avatarUrl = '/assets/photos/avatars/${path.split('/').last}';
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка загрузки аватара: $e')));
    }
  }

  late TextEditingController nameController;
  late TextEditingController emailController;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text('No user data')));
        }

        final userData = snapshot.data!;
        return Scaffold(
          drawer: const MenuDrawer(),
          body: Stack(
            children: [
              Container(color: Colors.white),
              Opacity(
                opacity: 0.15,
                child: Image.asset(
                  'assets/bg5.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        MenuButton(),
                        SizedBox(width: 12),
                        Text(
                          tr(Keys.myProfileTitle),
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(60, 57, 103, 1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // 🔹 Аватар
                    GestureDetector(
                      onTap: pickAvatar,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: pickedAvatarPath != null
                            ? FileImage(File(pickedAvatarPath!))
                            : avatarUrl != null
                            ? NetworkImage(
                                    '${url.replaceAll(RegExp(r"/$"), "")}$avatarUrl',
                                  )
                                  as ImageProvider
                            : const AssetImage('assets/avatar.png'),
                      ),
                    ),
                    const SizedBox(height: 20), Text(tr(Keys.birthDate)),
                    const SizedBox(height: 8),
                    userData['birthDate'] != null
                        ? Text(
                            DateTime.parse(
                              userData['birthDate']!,
                            ).toLocal().toString().split(' ')[0],
                          )
                        : GestureDetector(
                            onTap: pickBirthDate,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                selectedDate == null
                                    ? tr(Keys.selectDate)
                                    : '${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}',
                              ),
                            ),
                          ),
                    const SizedBox(height: 30),
                    Text(tr(Keys.gender)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ['male', 'female', 'other'].map((g) {
                        Color chipColor;
                        if (g == 'male') {
                          chipColor = selectedGender == 'male'
                              ? Colors.blue
                              : Colors.blue.shade100;
                        } else if (g == 'female') {
                          chipColor = selectedGender == 'female'
                              ? Colors.pink
                              : Colors.pink.shade100;
                        } else {
                          chipColor = selectedGender == 'other'
                              ? Colors.grey
                              : Colors.grey.shade300;
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(g),
                            selected: selectedGender == g,
                            selectedColor: chipColor,
                            backgroundColor: chipColor.withOpacity(0.3),
                            onSelected: (_) {
                              setState(() => selectedGender = g);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    // 🔹 UID с кнопкой копирования
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: userData['uid'] ?? '',
                            ),
                            decoration: InputDecoration(
                              labelText: tr(Keys.uid),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            if (userData['uid'] != null) {
                              Clipboard.setData(
                                ClipboardData(text: userData['uid']!),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(tr(Keys.uidCopied))),
                              );
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    // 🔹 Имя
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: tr(Keys.name),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 🔹 Email
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: tr(Keys.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    // 🔹 Кнопка смены пароля
                    ElevatedButton(
                      onPressed: showChangePasswordDialog,
                      child: Text(tr(Keys.changePassword)),
                    ),

                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: isLoading ? null : saveProfile,
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : Text(tr(Keys.save)),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔹 Функция для показа диалога смены пароля
  Future<void> showChangePasswordDialog() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    bool isLoadingPassword = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(tr(Keys.changePassword)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: tr(Keys.oldPassword),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: tr(Keys.newPassword),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoadingPassword
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: Text(tr(Keys.cancel)),
                ),
                ElevatedButton(
                  onPressed: isLoadingPassword
                      ? null
                      : () async {
                          final oldPassword = oldPasswordController.text.trim();
                          final newPassword = newPasswordController.text.trim();
                          final passwordError = validatePassword(newPassword);
                          if (passwordError != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(passwordError)),
                            );
                            return;
                          }

                          if (oldPassword.isEmpty || newPassword.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(tr(Keys.fillAllFields))),
                            );
                            return;
                          }

                          setState(() => isLoadingPassword = true);

                          try {
                            final res = await api.post(changePassword, {
                              'oldPassword': oldPassword,
                              'newPassword': newPassword,
                            });

                            if (res.statusCode == 200) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(tr(Keys.passwordChanged)),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${res.body}')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          } finally {
                            setState(() => isLoadingPassword = false);
                          }
                        },
                  child: isLoadingPassword
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(tr(Keys.changePassword)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
