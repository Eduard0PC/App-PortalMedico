using MediatR;
using SistemaCitas.Application.Common.Interfaces;
using SistemaCitas.Domain.Entities;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;
using SistemaCitas.Domain.Primitives;

namespace SistemaCitas.Application.Auth.Commands.RegistrarPaciente;

public sealed class RegistrarPacienteCommandHandler
    : IRequestHandler<RegistrarPacienteCommand, AuthResponseDto>
{
    private readonly IPacienteRepository _pacienteRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtService _jwtService;
    private readonly IUnitOfWork _unitOfWork;

    public RegistrarPacienteCommandHandler(
        IPacienteRepository pacienteRepository,
        IPasswordHasher passwordHasher,
        IJwtService jwtService,
        IUnitOfWork unitOfWork)
    {
        _pacienteRepository = pacienteRepository;
        _passwordHasher = passwordHasher;
        _jwtService = jwtService;
        _unitOfWork = unitOfWork;
    }

    public async Task<AuthResponseDto> Handle(RegistrarPacienteCommand request, CancellationToken ct)
    {
        if (await _pacienteRepository.ExisteCorreoAsync(request.Correo, ct))
            throw new ReglaDeNegocioException("Ya existe un paciente registrado con ese correo.");

        var passwordHash = _passwordHasher.Hash(request.Password);

        var paciente = new Paciente(
            request.Nombre,
            request.Apellido,
            request.Correo,
            passwordHash,
            request.Telefono,
            request.FechaNacimiento);

        _pacienteRepository.Agregar(paciente);
        await _unitOfWork.SaveChangesAsync(ct);

        var token = _jwtService.GenerarToken(paciente.Id, paciente.Correo, "Paciente");

        return new AuthResponseDto(
            token,
            paciente.Id,
            $"{paciente.Nombre} {paciente.Apellido}",
            paciente.Correo,
            "Paciente");
    }
}