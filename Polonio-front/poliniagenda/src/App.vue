<template>
  <div id="app">
    <AddContact @contact-added="addContact" />
    <ContactList 
      :contacts="contacts" 
      @edit-contact="setCurrentContact" 
      @delete-contact="deleteContact" 
    />
    <EditContact 
      v-if="currentContactIndex !== null" 
      :contact="contacts[currentContactIndex]" 
      :index="currentContactIndex" 
      @contact-updated="updateContact" 
      @cancel-edit="resetCurrentContact"
      ref="editContact" 
    />
    <p v-if="isLoading">Carregando contatos...</p>
    <p v-else-if="contacts.length === 0">Nenhum contato disponível.</p>
  </div>
</template>

<script>
import axios from 'axios';
import AddContact from './components/AddContact.vue';
import ContactList from './components/ContactList.vue';
import EditContact from './components/EditContact.vue';

export default {
  components: {
    AddContact,
    ContactList,
    EditContact
  },
  data() {
    return {
      contacts: [],
      isLoading: true,
      currentContactIndex: null
    };
  },
  created() {
    this.fetchContacts();
  },
  methods: {
    async fetchContacts() {
      try {
        const response = await axios.get('http://localhost/api/contatos');
        this.contacts = response.data;
        this.isLoading = false;
      } catch (error) {
        console.error('Error fetching contacts:', error);
      }
    },
    async addContact(contact) {
      try {
        const response = await axios.post('http://localhost/api/contatos', contact);
        this.contacts.push(response.data);
      } catch (error) {
        console.error('Error adding contact:', error);
      }
    },
    async updateContact(contact, index) {
      try {
        const response = await axios.put(`http://localhost/api/contatos/${contact.id}`, contact);
        this.contacts[index] = response.data;
        this.currentContactIndex = null;
      } catch (error) {
        console.error('Error updating contact:', error);
      }
    },
    async deleteContact(index) {
      try {
        const contactId = this.contacts[index].id;
        await axios.delete(`http://localhost/api/contatos/${contactId}`);
        this.contacts.splice(index, 1);
      } catch (error) {
        console.error('Error deleting contact:', error);
      }
    },
    setCurrentContact(index) {
      this.currentContactIndex = index;
      this.$nextTick(() => {
        this.$refs.editContact.$el.scrollIntoView({ behavior: 'smooth' });
      });
    },
    resetCurrentContact() {
      this.currentContactIndex = null;
    }
  }
};
</script>

<style scoped>
#app {
  max-width: 80%;
  margin: 0 auto;
  padding: 20px;
  background-color: #c8c8c8;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

h1 {
  text-align: center;
  color: #333;
}

button {
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 5px;
  padding: 10px 15px;
  cursor: pointer;
  transition: background-color 0.3s;
}

button:hover {
  background-color: #0056b3;
}

p {
  font-size: 16px;
  color: gray;
  text-align: center;
  margin-top: 20px;
}

.contact-list {
  margin-top: 20px;
}

.contact-item {
  padding: 10px;
  margin: 5px 0;
  background-color: #ffffff;
  border-radius: 5px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.contact-item:hover {
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
}
</style>

