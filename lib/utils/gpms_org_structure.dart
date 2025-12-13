class GPMSOrgStructure {
  // GPMS Departments with reporting structure
  static const Map<String, DepartmentInfo> departments = {
    'HR & Admin': DepartmentInfo(
      name: 'HR & Admin',
      manager: 'HR & Admin Manager',
      roles: [
        'HR & Admin Manager',
        'HR & Admin Officer',
        'Front Office Executive',
        'Drivers',
      ],
      reportsTo: 'General Manager',
    ),
    'QHSSE': DepartmentInfo(
      name: 'QHSSE',
      manager: 'QHSSE Manager',
      roles: ['QHSSE Manager', 'QHSSE Advisors', 'Sustainability Advisor'],
      reportsTo: 'General Manager',
    ),
    'Operations & Maintenance': DepartmentInfo(
      name: 'Operations & Maintenance',
      manager: 'Ops. & Maint. Manager',
      roles: [
        'Ops. & Maint. Manager',
        'Ops. & Maint. Officer',
        'Operations Supervisors',
        'Operations Officers',
        'Maintenance Field Supervisor',
        'Maintenance Planning Officer',
        'Workshop Supervisor',
        'Maintenance Operators',
        'Mooring Masters',
        'Dive Supervisor',
        'Divers/Trainee Divers',
        'Warehouse Officer',
        'Welders',
        'Lead Riggers',
        'Riggers',
        'Radio Operators',
      ],
      reportsTo: 'General Manager',
    ),
    'Finance': DepartmentInfo(
      name: 'Finance',
      manager: 'Finance Manager',
      roles: [
        'Finance Manager',
        'Senior Finance Officer',
        'Junior Finance Officers',
        'Senior Procurement & Logistic Officer',
        'Junior Procurement & Logistic Officer',
        'IT Officer',
      ],
      reportsTo: 'General Manager',
    ),
  };

  // Job grades based on GPMS structure (M1 lowest to M7 highest)
  static const List<String> jobGrades = [
    'M1 - Support Staff',
    'M2 - Technician/Operator',
    'M3 - Supervisor',
    'M4 - Officer',
    'M5 - Senior Officer',
    'M6 - Manager',
    'M7 - Executive',
  ];

  // Get all department names
  static List<String> getDepartmentNames() {
    return departments.keys.toList()..sort();
  }

  // Get roles for a specific department
  static List<String> getRolesForDepartment(String department) {
    return departments[department]?.roles ?? [];
  }

  // Get manager for a specific department
  static String getManagerForDepartment(String department) {
    return departments[department]?.manager ?? 'General Manager';
  }

  // Get reporting manager for a specific department
  static String getReportingManager(String department) {
    return departments[department]?.reportsTo ?? 'General Manager';
  }

  // Get all unique roles across organization
  static List<String> getAllRoles() {
    final roles = <String>{};
    for (var dept in departments.values) {
      roles.addAll(dept.roles);
    }
    final sortedRoles = roles.toList()..sort();
    return sortedRoles;
  }

  // Job grades are no longer automatically determined by role
  // Employees select their grade during registration

  // Get potential line managers for a role
  static List<String> getPotentialLineManagers(String department, String role) {
    final deptInfo = departments[department];
    if (deptInfo == null) return ['General Manager'];

    final managers = <String>[];
    
    // HR & Admin Department
    if (department == 'HR & Admin') {
      if (role == 'HR & Admin Manager') {
        managers.add('General Manager');
      } else if (role.contains('HR & Admin Officer') || role.contains('Front Office')) {
        managers.add('HR & Admin Manager');
      } else if (role.contains('Driver')) {
        managers.add('HR & Admin Officer');
        managers.add('HR & Admin Manager');
      }
    }
    
    // QHSSE Department - Advisors report to QHSSE Manager
    else if (department == 'QHSSE') {
      if (role.contains('Advisor')) {
        managers.add('QHSSE Manager');
      } else if (role == 'QHSSE Manager') {
        managers.add('General Manager');
      }
    }
    
    // Operations & Maintenance Department
    else if (department == 'Operations & Maintenance') {
      if (role == 'Ops. & Maint. Manager') {
        managers.add('General Manager');
      }
      // Operations roles
      else if (role == 'Operations Officers') {
        managers.add('Operations Supervisors');
        managers.add('Ops. & Maint. Manager');
      } else if (role == 'Operations Supervisors') {
        managers.add('Ops. & Maint. Manager');
      }
      // Maintenance roles
      else if (role.contains('Maintenance') && role.contains('Supervisor')) {
        managers.add('Ops. & Maint. Manager');
      } else if (role == 'Maintenance Planning Officer') {
        managers.add('Ops. & Maint. Manager');
      } else if (role == 'Maintenance Operators' || role.contains('Welder')) {
        managers.add('Maintenance Field Supervisor');
        managers.add('Workshop Supervisor');
      } else if (role == 'Warehouse Officer') {
        managers.add('Workshop Supervisor');
      }
      // Mooring Masters
      else if (role == 'Mooring Masters') {
        managers.add('Ops. & Maint. Manager');
      }
      // Diving roles
      else if (role.contains('Diver') && !role.contains('Supervisor')) {
        managers.add('Dive Supervisor');
      } else if (role == 'Dive Supervisor') {
        managers.add('Ops. & Maint. Manager');
      }
      // Riggers
      else if (role == 'Lead Riggers') {
        managers.add('Operations Supervisors');
      } else if (role == 'Riggers') {
        managers.add('Lead Riggers');
        managers.add('Operations Supervisors');
      }
      // Radio Operators
      else if (role == 'Radio Operators') {
        managers.add('Operations Supervisors');
      }
      // Ops. & Maint. Officer
      else if (role == 'Ops. & Maint. Officer') {
        managers.add('Ops. & Maint. Manager');
      }
    }
    
    // Finance Department
    else if (department == 'Finance') {
      // Finance roles
      if (role.contains('Junior Finance')) {
        managers.add('Senior Finance Officer');
        managers.add('Finance Manager');
      } else if (role.contains('Senior Finance')) {
        managers.add('Finance Manager');
      }
      // Procurement roles
      else if (role.contains('Junior Procurement')) {
        managers.add('Senior Procurement & Logistic Officer');
        managers.add('Finance Manager');
      } else if (role.contains('Senior Procurement')) {
        managers.add('Finance Manager');
      }
      // IT role
      else if (role == 'IT Officer') {
        managers.add('Finance Manager');
      }
      // Finance Manager
      else if (role == 'Finance Manager') {
        managers.add('General Manager');
      }
    }

    return managers.isEmpty ? ['General Manager'] : managers;
  }
}

class DepartmentInfo {
  final String name;
  final String manager;
  final List<String> roles;
  final String reportsTo;

  const DepartmentInfo({
    required this.name,
    required this.manager,
    required this.roles,
    required this.reportsTo,
  });
}
