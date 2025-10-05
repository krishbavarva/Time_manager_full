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
            The website is a time scheduler for employees. Gotham has been overrun by villains and the time management for 
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
.chat-view {
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
  height: calc(100vh - 4rem);
  display: flex;
  flex-direction: column;
}

.chat-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
}

.chat-window {
  background-color: #ffffff;
  border-radius: 16px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  width: 100%;
  max-width: 800px;
  height: 80vh;
  overflow: hidden;
}

.chatbot-header {
  background-color: #4f46e5;
  color: white;
  padding: 1.25rem 2rem;
  font-size: 1.25rem;
  font-weight: 600;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.close-button {
  background: none;
  border: none;
  color: white;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 0.5rem;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-button:hover {
  background-color: rgba(255, 255, 255, 0.1);
}

.close-icon {
  width: 20px;
  height: 20px;
  stroke-width: 2;
}

.messages {
  flex: 1;
  overflow-y: auto;
  padding: 1.5rem 2rem;
  background-color: #f8fafc;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.message {
  max-width: 80%;
  padding: 0.75rem 1.25rem;
  border-radius: 1rem;
  line-height: 1.5;
  position: relative;
  word-wrap: break-word;
  animation: fadeIn 0.3s ease-out;
}

.message.user {
  align-self: flex-end;
  background-color: #4f46e5;
  color: white;
  border-bottom-right-radius: 0.25rem;
}

.message.assistant {
  align-self: flex-start;
  background-color: #ffffff;
  color: #1e293b;
  border: 1px solid #e2e8f0;
  border-bottom-left-radius: 0.25rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.input-area {
  padding: 1.25rem 2rem;
  background-color: #ffffff;
  border-top: 1px solid #e2e8f0;
  display: flex;
  gap: 0.75rem;
  align-items: center;
}

.message-input {
  flex: 1;
  padding: 0.75rem 1.25rem;
  border: 2px solid #e2e8f0;
  border-radius: 0.75rem;
  font-size: 1rem;
  transition: all 0.2s ease;
  background-color: #f8fafc;
}

.message-input:focus {
  outline: none;
  border-color: #4f46e5;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
  background-color: #ffffff;
}

.send-button {
  background-color: #4f46e5;
  color: white;
  border: none;
  border-radius: 0.75rem;
  padding: 0.75rem 1.5rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  white-space: nowrap;
}

.send-button:hover:not(:disabled) {
  background-color: #4338ca;
  transform: translateY(-1px);
}

.send-button:active:not(:disabled) {
  transform: translateY(0);
}

.send-button:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.typing-indicator {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.25rem;
  background-color: #f1f5f9;
  border-radius: 1.5rem;
  width: fit-content;
  margin: 0.5rem 0;
}

.typing-indicator span {
  width: 8px;
  height: 8px;
  background-color: #64748b;
  border-radius: 50%;
  display: inline-block;
  animation: bounce 1.4s infinite ease-in-out both;
}

.typing-indicator span:nth-child(1) {
  animation-delay: -0.32s;
}

.typing-indicator span:nth-child(2) {
  animation-delay: -0.16s;
}

@keyframes bounce {
  0%, 80%, 100% { 
    transform: scale(0);
  } 
  40% { 
    transform: scale(1.0);
  }
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>
