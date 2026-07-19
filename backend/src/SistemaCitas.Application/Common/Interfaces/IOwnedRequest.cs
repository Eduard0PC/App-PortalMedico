namespace SistemaCitas.Application.Common.Interfaces;

public interface IOwnedRequest
{
    int IdPropietario { get; }
    string RolPropietario { get; }
}