<?php

namespace App\Http\Controllers;

use App\Models\Contato;
use Illuminate\Http\Request;

class ContatoController extends Controller
{
    /**
     * Exibir todos os contatos.
     */
    public function index()
    {
        $contatos = Contato::all();
        return response()->json($contatos);
    }

    /**
     * Criar um novo contato.
     */
    public function store(Request $request)
    {
        $request->validate([
            'nome' => 'required|string|max:255',
            'email' => 'required|email|unique:contatos,email',
            'endereco' => 'required|string',
            'telefone' => 'required|string|max:15',
        ]);

        $contato = Contato::create($request->all());
        return response()->json($contato, 201);
    }

    /**
     * Exibir um contato específico.
     */
    public function show($id)
    {
        $contato = Contato::findOrFail($id);
        return response()->json($contato);
    }

    /**
     * Atualizar um contato específico.
     */
    public function update(Request $request, $id)
    {
        $request->validate([
            'nome' => 'sometimes|required|string|max:255',
            'email' => 'sometimes|required|email|unique:contatos,email,' . $id,
            'endereco' => 'sometimes|required|string',
            'telefone' => 'sometimes|required|string|max:15',
        ]);

        $contato = Contato::findOrFail($id);
        $contato->update($request->all());

        return response()->json($contato, 200);
    }

    /**
     * Remover um contato específico.
     */
    public function destroy($id)
    {
        $contato = Contato::findOrFail($id);
        $contato->delete();

        return response()->json(null, 204);
    }
}
