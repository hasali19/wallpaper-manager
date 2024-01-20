import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:wallpaper_manager/monitors.dart';
import 'package:wallpaper_manager/wallpaper.dart';

void main() {
  runApp(const WallpaperManagerApp());
}

class WallpaperManagerApp extends StatelessWidget {
  const WallpaperManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallpaper Manager',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const WallpaperManagerView(),
    );
  }
}

class WallpaperManagerView extends StatefulWidget {
  const WallpaperManagerView({super.key});

  @override
  State<WallpaperManagerView> createState() => _WallpaperManagerViewState();
}

class _WallpaperManagerViewState extends State<WallpaperManagerView> {
  String? _selectedMonitorId;
  String? _wallpaperPath;
  List<MonitorInfo> _monitors = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final monitors = await Monitors.get();
      setState(() {
        _monitors = monitors;
        _setSelectedMonitor(monitors.first.id);
      });
    });
  }

  void _setSelectedMonitor(String id) {
    final wallpaper = Wallpaper.get(monitorId: id);
    setState(() {
      _selectedMonitorId = id;
      _wallpaperPath = wallpaper;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: switch (_wallpaperPath) {
        null => const Center(child: CircularProgressIndicator()),
        final path => AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            // transitionBuilder must be specified as a workaround for https://github.com/flutter/flutter/issues/121336
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Stack(
              key: ValueKey(path),
              children: [
                Positioned.fill(
                  child: Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text('Failed to load image at \'$path\''),
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(200),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          _wallpaperPath!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      },
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            TextButton.icon(
              label: const Text('Choose image'),
              icon: const Icon(Icons.image),
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles();
                if (result != null) {
                  setState(() {
                    _wallpaperPath = result.files[0].path;
                  });
                }
              },
            ),
            // if (_wallpaperPath != null)
            //   Flexible(
            //     fit: FlexFit.tight,
            //     child: Text(
            //       _wallpaperPath!,
            //       maxLines: 1,
            //       overflow: TextOverflow.ellipsis,
            //       style: Theme.of(context).textTheme.labelMedium,
            //     ),
            //   ),
            const Spacer(),
            MenuAnchor(
              menuChildren: _monitors
                  .map((e) => MenuItemButton(
                        child: Text(e.name),
                        onPressed: () => _setSelectedMonitor(e.id),
                      ))
                  .toList(),
              builder: (context, controller, child) {
                final selectedMonitor = _monitors
                    .where((monitor) => monitor.id == _selectedMonitorId)
                    .firstOrNull;
                return TextButton(
                  child: Row(
                    children: [
                      Text(selectedMonitor?.name ?? ''),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                );
              },
            ),
            const Gap(16),
            if (_selectedMonitorId != null && _wallpaperPath != null)
              ElevatedButton.icon(
                label: const Text('Set wallpaper'),
                icon: const Icon(Icons.wallpaper),
                onPressed: () => Wallpaper.set(
                  File(_wallpaperPath!),
                  monitorId: _selectedMonitorId,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
