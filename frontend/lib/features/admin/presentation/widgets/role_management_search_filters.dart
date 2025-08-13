import 'package:flutter/material.dart';

class RoleManagementSearchFilters extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final bool isDesktop;
  final List<String> roles;
  final List<String> statusOptions;
  final String selectedRoleFilter;
  final String selectedStatusFilter;
  final Function(String) onSearchChanged;
  final Function(String) onRoleFilterChanged;
  final Function(String) onStatusFilterChanged;

  const RoleManagementSearchFilters({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.isDesktop,
    required this.roles,
    required this.statusOptions,
    required this.selectedRoleFilter,
    required this.selectedStatusFilter,
    required this.onSearchChanged,
    required this.onRoleFilterChanged,
    required this.onStatusFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // Search toggle header
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.search),
                  const SizedBox(width: 8),
                  const Text(
                    'Search & Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more),
                  ),
                ],
              ),
            ),
          ),
          // Collapsible content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  // Search and filters row
                  if (isDesktop) ...{
                    Row(
                      children: [
                        // Search field
                        Expanded(
                          flex: 2,
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText:
                                  'Search by name, employee ID, or email...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: onSearchChanged,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Role filter
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedRoleFilter,
                            decoration: const InputDecoration(
                              labelText: 'Filter by Role',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: 'all',
                                child: Text('All Roles'),
                              ),
                              ...roles.map(
                                (role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role.toUpperCase()),
                                ),
                              ),
                            ],
                            onChanged: (value) => onRoleFilterChanged(value!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Status filter
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedStatusFilter,
                            decoration: const InputDecoration(
                              labelText: 'Filter by Status',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: statusOptions
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status.toUpperCase()),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => onStatusFilterChanged(value!),
                          ),
                        ),
                      ],
                    ),
                  } else ...{
                    // Mobile layout - stacked filters
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search users...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: onSearchChanged,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedRoleFilter,
                            decoration: const InputDecoration(
                              labelText: 'Role',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: 'all',
                                child: Text('All'),
                              ),
                              ...roles.map(
                                (role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role.toUpperCase()),
                                ),
                              ),
                            ],
                            onChanged: (value) => onRoleFilterChanged(value!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedStatusFilter,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: statusOptions
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status.toUpperCase()),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => onStatusFilterChanged(value!),
                          ),
                        ),
                      ],
                    ),
                  },
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}