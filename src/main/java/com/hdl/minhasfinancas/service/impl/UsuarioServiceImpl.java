package com.hdl.minhasfinancas.service.impl;

import org.springframework.stereotype.Service;

import com.hdl.minhasfinancas.exception.RegraNegocioException;
import com.hdl.minhasfinancas.model.entity.Usuario;
import com.hdl.minhasfinancas.model.repository.UsuarioRepository;
import com.hdl.minhasfinancas.service.UsuarioService;

@Service
public class UsuarioServiceImpl  implements UsuarioService{
	
	private UsuarioRepository repository;
	
	 
	public UsuarioServiceImpl(UsuarioRepository repository) {
		super();
		this.repository = repository;
	}

	@Override
	public Usuario autenticar(String email, String senha) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Usuario salvarUsuario(Usuario usuario) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public void validarEmail(String email) {
	boolean existe = repository.existsByEmail(email);
		if(existe) {
			throw new RegraNegocioException("Já existe um usuário cadastrado com este email.");
		}
	}

}
