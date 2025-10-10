<template>
  <div class="chat-view">
    <div class="chat-container">
      <div class="chat-window">
        <div class="chatbot-header">
          <span>Time Manager Assistant</span>
          <button @click="closeChat" class="close-button" title="Close Chat">
            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" class="close-icon">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>
        
        <div class="messages" ref="messagesContainer">
          <div v-for="(message, index) in messages" :key="index" :class="['message', message.role]">
            <div class="message-content">
              <strong v-if="message.role === 'assistant'">Assistant:</strong>
              <strong v-else>You:</strong>
              {{ message.content }}
            </div>
          </div>
          <div v-if="isLoading" class="typing-indicator">
            <span></span>
            <span></span>
            <span></span>
          </div>
        </div>
        
        <div class="input-area">
          <input
            v-model="userInput"
            @keyup.enter="sendMessage"
            placeholder="Type your message..."
            class="message-input"
            :disabled="isLoading"
          />
          <button @click="sendMessage" class="send-button" :disabled="isLoading">
            {{ isLoading ? 'Sending...' : 'Send' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { chatService } from '@/services/chatService';

export default {
  name: 'ChatView',
  data() {
    return {
      isOpen: true,
      isLoading: false,
      userInput: '',
      messages: [
        {
          role: 'assistant',
          content: 'Hello! I\'m your Time Manager Assistant. How can I help you today?'
        }
      ]
    };
  },
  mounted() {
    this.scrollToBottom();
  },
  methods: {
    async sendMessage() {
      if (!this.userInput.trim() || this.isLoading) return;

      // Add user message
      const userMessage = { role: 'user', content: this.userInput };
      this.messages.push(userMessage);
      this.userInput = '';
      this.isLoading = true;

      try {
        const response = await chatService.sendMessage([
          {
            role: 'system',
            content: `You are an instructional chatbot. Your job is to guide users on how to use the Time Manager website. 
            The website is a time scheduler for employees. Time Manager has been overrun by villains and the time management for 
            the employees is in shambles. This website allows users to login, signup, set their own time schedule, 
            clock in/out, and view their work time history and statistics.`
          },
          ...this.messages
        ]);
        
        const assistantMessage = response.choices[0].message;
        this.messages.push(assistantMessage);
      } catch (error) {
        console.error('Error:', error);
        this.messages.push({
          role: 'assistant',
          content: 'Sorry, I encountered an error. Please try again later.'
        });
      } finally {
        this.isLoading = false;
        this.scrollToBottom();
      }
    },
    closeChat() {
      this.$router.push('/dashboard');
    },
    scrollToBottom() {
      this.$nextTick(() => {
        const container = this.$refs.messagesContainer;
        if (container) {
          container.scrollTop = container.scrollHeight;
        }
      });
    }
  }
};
</script>

<style scoped>
/* Styles now mapped via Tailwind @apply in main.css */
@keyframes bounce { 0%,80%,100% { transform: scale(0);} 40% { transform: scale(1);} }
@keyframes fadeIn { from { opacity: 0; transform: translateY(10px);} to { opacity: 1; transform: translateY(0);} }
</style>
