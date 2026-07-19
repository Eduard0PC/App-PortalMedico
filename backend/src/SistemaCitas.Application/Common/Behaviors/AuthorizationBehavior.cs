using MediatR;
using SistemaCitas.Application.Common.Interfaces;
using SistemaCitas.Domain.Exceptions;

namespace SistemaCitas.Application.Common.Behaviors;

public sealed class AuthorizationBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : notnull
{
    private readonly ICurrentUserService _currentUser;

    public AuthorizationBehavior(ICurrentUserService currentUser) => _currentUser = currentUser;

    public async Task<TResponse> Handle(
        TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken ct)
    {
        if (request is not IAuthorizedRequest autorizado)
            return await next();

        if (!_currentUser.EstaAutenticado)
            throw new AccesoDenegadoException("No hay un usuario autenticado.");

        if (!autorizado.RolesPermitidos.Contains(_currentUser.Rol))
            throw new AccesoDenegadoException(
                $"El rol '{_currentUser.Rol}' no tiene permiso para realizar esta operación.");

        if (request is IOwnedRequest propio && _currentUser.Rol == propio.RolPropietario)
        {
            if (propio.IdPropietario != _currentUser.Id)
                throw new AccesoDenegadoException("No puedes acceder a un recurso que no te pertenece.");
        }

        return await next();
    }
}