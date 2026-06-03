class ProjectItem {
  const ProjectItem({
    required this.title,
    required this.category,
    required this.description,
    required this.tech,
    required this.year,
  });

  final String title;
  final String category;
  final String description;
  final String tech;
  final String year;
}

class TeamMember {
  const TeamMember({
    required this.name,
    required this.role,
    required this.bio,
    required this.initials,
    required this.isLeadership,
  });

  final String name;
  final String role;
  final String bio;
  final String initials;
  final bool isLeadership;
}

const projects = [
  ProjectItem(
    title: 'Retail POS & Inventory',
    category: 'Enterprise',
    description:
        'Full sales platform with barcode scanning, multi-branch stock, and live dashboards for store owners.',
    tech: 'Flutter · .NET · SQL Server',
    year: '2025',
  ),
  ProjectItem(
    title: 'Healthcare Appointment Hub',
    category: 'Web App',
    description:
        'Patient booking, doctor schedules, SMS reminders, and admin analytics for a clinic network.',
    tech: 'React · Node · PostgreSQL',
    year: '2024',
  ),
  ProjectItem(
    title: 'Logistics Tracking Suite',
    category: 'Mobile',
    description:
        'Driver app with GPS routes, proof-of-delivery photos, and dispatcher web console.',
    tech: 'Flutter · Firebase · Maps API',
    year: '2024',
  ),
  ProjectItem(
    title: 'Corporate Brand Website',
    category: 'Marketing',
    description:
        'Scroll-driven storytelling site with animated sections — built to replace a slow WordPress setup.',
    tech: 'HTML · GSAP · CDN deploy',
    year: '2025',
  ),
];

const team = [
  TeamMember(
    name: 'Ashif Saheer',
    role: 'Founder & Lead Developer',
    bio: 'Architecture, full-stack delivery, and client strategy. Turns ideas into shipped products.',
    initials: 'AS',
    isLeadership: true,
  ),
  TeamMember(
    name: 'Priya Nair',
    role: 'Co-founder · Product Design',
    bio: 'UX flows, design systems, and motion direction so every screen feels intentional.',
    initials: 'PN',
    isLeadership: true,
  ),
  TeamMember(
    name: 'Rahul Menon',
    role: 'Senior Flutter Engineer',
    bio: 'Cross-platform apps, performance tuning, and clean state management.',
    initials: 'RM',
    isLeadership: false,
  ),
  TeamMember(
    name: 'Sneha Thomas',
    role: 'Backend & Cloud',
    bio: 'APIs, DevOps, Azure/AWS deployments, and security best practices.',
    initials: 'ST',
    isLeadership: false,
  ),
];

const capabilities = [
  ('Web & SaaS', 'Dashboards, portals, and high-performance marketing sites.'),
  ('Mobile Apps', 'Flutter apps for Android, iOS, and desktop from one codebase.'),
  ('Cloud & APIs', 'Secure backends, integrations, and automated deployments.'),
  ('UI & Motion', 'Scroll animations, micro-interactions, and premium brand feel.'),
];

const enquiryTypes = [
  'New project',
  'Website redesign',
  'Mobile app',
  'Support & maintenance',
  'Partnership',
];
