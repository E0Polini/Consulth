<template>
  <div>
    <h2>Adicionar Contato</h2>
    <form @submit.prevent="submitContact">
      <div class="form-row">
        <div class="form-group">
          <input v-model="nome" placeholder="Nome" required />
          <input v-model="email" placeholder="Email" required />
        </div>
        <div class="form-group">
          <input v-model="endereco" placeholder="Endereço" required />
          <input v-model="telefone" placeholder="Telefone" required />
        </div>
      </div>
      <button type="button" @click="addContact">Adicionar</button>
    </form>
  </div>
</template>

<script>
export default {
  data() {
    return {
      nome: '',
      email: '',
      endereco: '',
      telefone: ''
    };
  },
  methods: {
    addContact() {
      this.$emit('contact-added', { nome: this.nome, email: this.email, endereco: this.endereco, telefone: this.telefone });
      this.nome = '';
      this.email = '';
      this.endereco = '';
      this.telefone = '';
    }
  }
};
</script>

<style scoped>
.add-contact {
  margin-bottom: 20px;
}

.form-row {
  display: flex;
  flex-direction: column;
}

.form-group {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
}

input {
  flex: 1;
  margin-right: 10px;
  padding: 10px;
  border-radius: 5px;
  border: 1px solid #ccc;
}

input:last-child {
  margin-right: 0;
}

button {
  padding: 10px;
  border-radius: 5px;
  border: none;
  background-color: #28a745;
  color: white;
  cursor: pointer;
  transition: background-color 0.3s;
}

button:hover {
  background-color: #218838;
}
</style>