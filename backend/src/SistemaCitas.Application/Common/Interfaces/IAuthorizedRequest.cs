namespace SistemaCitas.Application.Common.Interfaces;

public interface IAuthorizedRequest
{
    string[] RolesPermitidos { get; }
}