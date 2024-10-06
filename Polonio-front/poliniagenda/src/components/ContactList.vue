<template>
  <div class="contact-list">
    <h2>Lista de Contatos</h2>
    <div class="contact-item-header">
      <p>Nome</p>
      <p>Email</p>
      <p>Endereço</p>
      <p>Telefone</p>
      <p></p>
      <p></p>
    </div>
    <div v-for="(contact, index) in contacts" :key="contact.id" class="contact-item">
      <p>{{ contact.nome }}</p>
      <p>{{ contact.email }}</p>
      <p>{{ contact.endereco }}</p>
      <p>{{ contact.telefone }}</p>
      <button @click="$emit('edit-contact', index)">Editar</button>
      <button @click="$emit('delete-contact', index)">Deletar</button>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    contacts: Array
  },
  methods: {
    editContact(index) {
      this.$emit('edit-contact', index);
    },
    deleteContact(index) {
      this.$emit('delete-contact', index);
    }
  }
};
</script>
<style scoped>
.contact-list {
  margin-top: 20px;
}

.contact-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;
  margin: 5px 0;
  background-color: #ffffff;
  border-radius: 5px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.contact-item:hover {
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
}

.contact-item-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;
  margin: 5px 0;
  background-color: #ffffff;
  border-radius: 5px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}
</style>