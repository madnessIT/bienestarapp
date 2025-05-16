import 'package:flutter/material.dart';

class ServiciosMedicosPage extends StatelessWidget {
  const ServiciosMedicosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios Médicos'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF01B32D), Color(0xFF003E8F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final content = isWide
                ? GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 4,
                    padding: const EdgeInsets.all(12),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: _menuItems.map((item) => _hoverableCard(context, item)).toList(),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _menuItems.length,
                    itemBuilder: (context, i) => _hoverableCard(context, _menuItems[i]),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                  );

            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Seleccione un servicio:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isWide ? 800 : 400),
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: content,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static const List<_MenuItemData> _menuItems = [
    _MenuItemData(
      icon: Icons.receipt_long,
      title: 'Recetas',
      subtitle: 'Consulta tus recetas médicas.',
      route: '/servicios_medicos/recetas',
    ),
    _MenuItemData(
      icon: Icons.monitor_heart,
      title: 'Última Toma de Signos Vitales',
      subtitle: 'Revisa la última toma de signos vitales.',
      route: '/servicios_medicos/signos_vitales',
    ),
    _MenuItemData(
      icon: Icons.science,
      title: 'Laboratorios',
      subtitle: 'Consulta los resultados de tus laboratorios.',
      route: '/servicios_medicos/laboratorios',
    ),
    _MenuItemData(
      icon: Icons.woman,
      title: 'Papanicolaou',
      subtitle: 'Consulta los resultados de tus estudios.',
      route: '/servicios_medicos/pap',
    ),
    _MenuItemData(
      icon: Icons.medical_services,
      title: 'Interconsultas Médicas',
      subtitle: 'Consulta tus interconsultas médicas.',
      route: '/servicios_medicos/interconsultas',
    ),
  ];

  Widget _hoverableCard(BuildContext context, _MenuItemData item) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.of(context).pushNamed(item.route),
            hoverColor: Colors.grey.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFE6FAEB),
                    child: Icon(item.icon, size: 24, color: const Color(0xFF01B32D)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(item.subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  const _MenuItemData({required this.icon, required this.title, required this.subtitle, required this.route});
}
