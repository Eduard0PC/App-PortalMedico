namespace SistemaCitas.Application.Common.Interfaces;

/// <summary>
/// Se implementa junto con IAuthorizedRequest en los Commands/Queries marcados como "(propio)"
/// en la especificación (ej. GET /api/pacientes/{id}, GET /api/medicos/{id}/horario): declara a
/// quién le pertenece el recurso pedido, para que AuthorizationBehavior verifique que coincide
/// con el usuario autenticado — así un paciente no puede pasar el id de otro paciente en la URL
/// y obtener sus datos, aunque tenga el rol correcto.
/// </summary>
public interface IOwnedRequest
{
    /// <summary>Id del Paciente o Médico dueño del recurso solicitado (ej. el {id} de la ruta).</summary>
    int IdPropietario { get; }

    /// <summary>Rol al que aplica esta validación de propiedad, ej. "Paciente" o "Medico". Un
    /// Administrador siempre pasa sin este chequeo, sin importar este valor.</summary>
    string RolPropietario { get; }
}