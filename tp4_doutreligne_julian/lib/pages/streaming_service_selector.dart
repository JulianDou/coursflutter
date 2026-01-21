import 'package:flutter/material.dart';
import '../models/streaming_service.dart';
import '../services/movie_service.dart';

class StreamingServiceSelector extends StatefulWidget {
  final MovieService movieService;
  final Set<int> selectedServiceIds;
  final Function(Set<int>) onServicesSelected;

  const StreamingServiceSelector({
    super.key,
    required this.movieService,
    required this.selectedServiceIds,
    required this.onServicesSelected,
  });

  @override
  State<StreamingServiceSelector> createState() =>
      _StreamingServiceSelectorState();
}

class _StreamingServiceSelectorState extends State<StreamingServiceSelector> {
  List<StreamingService> services = [];
  List<StreamingService> filteredServices = [];
  bool isLoading = true;
  String? errorMessage;
  late Set<int> selectedIds;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedIds = Set<int>.from(widget.selectedServiceIds);
    _searchController.addListener(_filterServices);
    _loadServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loadedServices =
          await widget.movieService.getStreamingServices();
      setState(() {
        services = loadedServices;
        filteredServices = loadedServices;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }


  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredServices = services;
      } else {
        filteredServices = services
            .where((s) => s.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }
  void _toggleService(int serviceId) {
    setState(() {
      if (selectedIds.contains(serviceId)) {
        selectedIds.remove(serviceId);
      } else {
        selectedIds.add(serviceId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎬 Select Your Streaming Services'),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadServices,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search services...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _filterServices();
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                          child: filteredServices.isEmpty
                              ? const Center(
                                  child: Text('No services match your search'),
                                )
                              : GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1.0,
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8,
                                  ),
                                  itemCount: filteredServices.length,
                                  itemBuilder: (context, index) {
                                    final service = filteredServices[index];
                                    final isSelected = selectedIds.contains(service.id);

                                    return GestureDetector(
                                      onTap: () => _toggleService(service.id),
                                      child: Card(
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.2)
                                            : Theme.of(context)
                                                .colorScheme
                                                .surface,
                                        elevation: isSelected ? 4 : 1,
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  if (service.logoUrl != null)
                                                    Flexible(
                                                      child: Image.network(
                                                        service.logoUrl!,
                                                        height: 60,
                                                        errorBuilder: (context, error,
                                                            stackTrace) {
                                                          return const Icon(
                                                            Icons.videocam,
                                                            size: 40,
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  else
                                                    const Icon(
                                                      Icons.videocam,
                                                      size: 40,
                                                    ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    service.name,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (isSelected)
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding: const EdgeInsets.all(4),
                                                  child: const Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            widget.onServicesSelected(selectedIds);
                            Navigator.pop(context);
                          },
                          child: Text(
                            selectedIds.isEmpty
                                ? 'Select at least one service'
                                : 'Apply (${selectedIds.length} selected)',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
