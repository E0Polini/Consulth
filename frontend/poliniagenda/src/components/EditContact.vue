<template>
  <div v-if="contact">
    <h2>Editar Contatos</h2>
    <form @submit.prevent="updateContact">
      <div class="form-row">
        <div class="form-group">
          <input v-model="editedContact.nome" required placeholder="Nome" />
          <input v-model="editedContact.email" required placeholder="Email" />
        </div>
        <div class="form-group">
          <input v-model="editedContact.endereco" required placeholder="Endereço" />
          <input v-model="editedContact.telefone" required placeholder="Telefone" />
        </div>
      </div>
      <div class="button-group">
        <button type="submit">Atualizar</button>
        <button type="button" @click="cancelEdit">Cancelar</button>
      </div>
    </form>
  </div>
</template>

<script>
export default {
  props: {
    contact: Object,
    index: Number
  },
  data() {
    return {
      editedContact: { ...this.contact }
    };
  },
  watch: {
    contact: {
      immediate: true,
      handler(newContact) {
        this.editedContact = { ...newContact };
      }
    }
  },
  methods: {
    updateContact() {
      this.$emit('contact-updated', this.editedContact, this.index);
    },
    cancelEdit() {
      this.editedContact = { ...this.contact };
      this.$emit('cancel-edit');
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

.button-group {
  display: flex;
  justify-content: flex-start;
}

button {
  padding: 10px 20px;
  border-radius: 5px;
  border: none;
  background-color: #28a745;
  color: white;
  cursor: pointer;
  transition: background-color 0.3s;
}


button[type="button"] {
  background-color: #dc3545;
  margin-left: 10px;
}

button[type="button"]:hover {
  background-color: #c82333;
}

button:hover {
  background-color: #218838;
}
</style>