import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../shared/models.dart';

class HistorialPacientesView extends StatefulWidget {
  const HistorialPacientesView({super.key});

  @override
  State<HistorialPacientesView> createState() => _HistorialPacientesViewState();
}

class _HistorialPacientesViewState extends State<HistorialPacientesView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    // Get all unique patients that have had contact with this doctor
    final allPatients = appState.uniquePatients;

    // Filter based on search query
    final filteredPatients = allPatients.where((patient) {
      final name = patient['nombre'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query);
    }).toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header title
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historial Clínico de Pacientes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                SizedBox(height: 4),
                Text(
                  'Busque un paciente para revisar su registro histórico de consultas.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),

          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar paciente por nombre...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppTheme.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                ),
              ),
            ),
          ),
          
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Results List
          Expanded(
            child: filteredPatients.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No se encontraron pacientes',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Intente buscando con otro nombre o verifique las citas en la agenda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredPatients.length,
                    itemBuilder: (context, index) {
                      final patient = filteredPatients[index];
                      final patientId = patient['id'] as int;
                      final patientName = patient['nombre'] as String;

                      // Get appointments history for this patient
                      final patientHistory = appState.getCitasPaciente(patientId);

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ExpansionTile(
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          collapsedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryLight,
                            child: Text(
                              patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            patientName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            '${patientHistory.length} consulta${patientHistory.length == 1 ? '' : 's'} en total',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                          childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          children: [
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Historial de Consultas',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...patientHistory.map((cita) => _buildHistoryItem(context, cita)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, Cita cita) {
    final formattedDate = DateFormat("d 'de' MMMM, yyyy", 'es').format(cita.fecha);
    
    Color badgeColor;
    Color badgeTextColor;
    switch (cita.estado) {
      case 'Atendida':
        badgeColor = const Color(0xFFE6F7F0);
        badgeTextColor = AppTheme.secondary;
        break;
      case 'Programada':
        badgeColor = AppTheme.primaryLight;
        badgeTextColor = AppTheme.primary;
        break;
      case 'Cancelada':
      default:
        badgeColor = const Color(0xFFFDE8E8);
        badgeTextColor = AppTheme.error;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date, Time & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$formattedDate a las ${cita.horaInicio}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  cita.estado,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Specialty & Doctor
          Text(
            '${cita.especialidad.nombre} - ${cita.medico.nombreCompleto}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 4),

          // Reason
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
              children: [
                const TextSpan(
                  text: 'Motivo: ',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                ),
                TextSpan(text: cita.motivoConsulta),
              ],
            ),
          ),
          
          // Medical Notes
          if (cita.notaMedica != null && cita.notaMedica!.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 6),
            const Text(
              'Notas Médicas:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              cita.notaMedica!,
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
