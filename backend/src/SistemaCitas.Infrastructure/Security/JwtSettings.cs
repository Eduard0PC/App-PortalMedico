namespace SistemaCitas.Infrastructure.Security;

public sealed class JwtSettings
{
    public string ClaveSecreta { get; init; } = string.Empty;
    public string Issuer { get; init; } = string.Empty;
    public string Audience { get; init; } = string.Empty;
    public int ExpiracionMinutos { get; init; }
}