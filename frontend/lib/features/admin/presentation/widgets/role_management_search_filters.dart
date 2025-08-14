import 'package:flutter/material.dart';
import '../../../../l10n/features/admin/admin_localizations.dart';

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
    final l10n = AdminLocalizations.of(context);
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
                  Text(
                    l10n.searchAndFilters,
                    style: const TextStyle(
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
                            decoration: InputDecoration(
                              hintText: l10n.searchByNameEmployeeId,
                              prefixIcon: const Icon(Icons.search),
                              border: const OutlineInputBorder(),
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
                            decoration: InputDecoration(
                              labelText: l10n.filterByRole,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'all',
                                child: Text(l10n.allRoles),
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
                            decoration: InputDecoration(
                              labelText: l10n.filterByStatus,
                              border: const OutlineInputBorder(),
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
                      decoration: InputDecoration(
                        hintText: l10n.searchUsers,
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
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
                            decoration: InputDecoration(
                              labelText: l10n.roleLabel,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'all',
                                child: Text(l10n.allStatus),
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
                            decoration: InputDecoration(
                              labelText: l10n.statusFilterLabel,
                              border: const OutlineInputBorder(),
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