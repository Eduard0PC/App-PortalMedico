using System.Security.Claims;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.API.Common;

public sealed class CurrentUserService : ICurrentUserService
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public CurrentUserService(IHttpContextAccessor httpContextAccessor) =>
        _httpContextAccessor = httpContextAccessor;

    private ClaimsPrincipal? Usuario => _httpContextAccessor.HttpContext?.User;

    public bool EstaAutenticado => Usuario?.Identity?.IsAuthenticated ?? false;

    public int Id =>
        int.TryParse(Usuario?.FindFirstValue(ClaimTypes.NameIdentifier), out var id) ? id : 0;

    public string Correo => Usuario?.FindFirstValue(ClaimTypes.Email) ?? string.Empty;

    public string Rol => Usuario?.FindFirstValue(ClaimTypes.Role) ?? string.Empty;
}