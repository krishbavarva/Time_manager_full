<template>
  <div class="chat-container">
    <!-- Chat Icon (always visible) -->
    <div class="chat-icon-container" @click="toggleChat">
      <div class="chat-icon">💬</div>
    </div>

    <!-- Chat Modal -->
    <div v-if="isOpen" class="chat-modal">
      <div class="chat-window">
        <div class="chat-header">
          <h3>Time Manager Assistant</h3>
          <button class="close-button" @click="toggleChat">×</button>
        </div>
        
        <div class="messages" ref="messagesContainer">
          <div v-for="(message, index) in messages" 
               :key="index" 
               :class="['message', message.role]">
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
          <button 
            @click="sendMessage" 
            class="send-button" 
            :disabled="isLoading || !userInput.trim()"
          >
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
  name: 'ChatBot',
  data() {
    return {
      isOpen: false,
      isLoading: false,
      userInput: '',
      messages: [
        {
          role: 'assistant',
          content: 'Hello! I\'m your Time Manager Assistant.'
        }
      ]
    };
  },
  mounted() {
    this.scrollToBottom();
  },
  methods: {
    toggleChat() {
      this.isOpen = !this.isOpen;
      if (this.isOpen) {
        this.$nextTick(() => {
          this.scrollToBottom();
          const input = this.$el.querySelector('.message-input');
          if (input) input.focus();
        });
      }
    },
    async sendMessage() {
  if (!this.userInput.trim() || this.isLoading) return;

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

    console.log('✅ Full Chat API Response:', response);

    // Just display the entire response as assistant message
    this.messages.push({
      role: 'assistant',
      content: JSON.stringify(response, null, 2) // pretty-print
    });

  } catch (error) {
    console.error('❌ Chatbot Error:', error);
    this.messages.push({
      role: 'assistant',
      content: '⚠️ Sorry, I encountered an error. Please try again later.'
    });
  } finally {
    this.isLoading = false;
    this.scrollToBottom();
  }
}

  }
};
</script>

<style scoped>
.chat-container {
  position: relative;
  z-index: 1000;
}

/* Chat Icon */
.chat-icon-container {
  position: fixed;
  bottom: 2rem;
  right: 2rem;
  width: 60px;
  height: 60px;
  background-color: #4f46e5;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  cursor: pointer;
  transition: all 0.3s ease;
  z-index: 1001;
}

.chat-icon-container:hover {
  background-color: #4338ca;
  transform: scale(1.1);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.2);
}

.chat-icon {
  font-size: 28px;
  color: white;
}

/* Chat Modal */
.chat-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: flex-end;
  align-items: flex-end;
  padding: 1rem;
  z-index: 1000;
}

.chat-window {
  width: 100%;
  max-width: 400px;
  height: 70vh;
  max-height: 700px;
  background: white;
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  overflow: hidden;
}

.chat-header {
  padding: 1rem 1.5rem;
  background-color: #4f46e5;
  color: white;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.chat-header h3 {
  margin: 0;
  font-size: 1.1rem;
  font-weight: 600;
}

.close-button {
  background: none;
  border: none;
  color: white;
  font-size: 1.8rem;
  cursor: pointer;
  line-height: 1;
  padding: 0.25rem;
  opacity: 0.8;
  transition: opacity 0.2s;
}

.close-button:hover {
  opacity: 1;
}

.messages {
  flex: 1;
  overflow-y: auto;
  padding: 1.5rem;
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
  color: black;
  border-bottom-right-radius: 0.25rem;
}

.message.assistant {
  align-self: flex-start;
  background-color: #ffffff;
  color: #000000; /* Changed to black for better visibility */
  border: 1px solid #e2e8f0;
  border-bottom-left-radius: 0.25rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.input-area {
  padding: 1rem;
  background-color: white;
  border-top: 1px solid #e2e8f0;
  display: flex;
  gap: 0.75rem;
}

.message-input {
  flex: 1;
  padding: 0.75rem 1rem;
  border: 1px solid #e2e8f0;
  border-radius: 0.75rem;
  font-size: 1rem;
  color: black;
  transition: all 0.2s ease;
  background-color: #f8fafc;
}

.message-input:focus {
  outline: none;
  border-color: #4f46e5;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
  background-color: white;
}

.send-button {
  background-color: #4f46e5;
  color: white;
  border: none;
  border-radius: 0.75rem;
  padding: 0 1.25rem;
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

/* Scrollbar */
.messages::-webkit-scrollbar {
  width: 6px;
}

.messages::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 10px;
}

.messages::-webkit-scrollbar-thumb {
  background: #c7d2fe;
  border-radius: 10px;
}

.messages::-webkit-scrollbar-thumb:hover {
  background: #a5b4fc;
}
.debug-border {
  border: 2px solid red !important;
}
.chatbot-header {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: #4f46e5;
  color: white;
  padding: 12px 16px;
  border-radius: 12px 12px 0 0;
  font-size: 16px;
  font-weight: 600;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.chatbot-header span {
  font-weight: 600;
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  padding-right: 10px;
}

.chatbot-header button {
  background: none;
  border: none;
  color: white;
  font-size: 24px;
  line-height: 1;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  transition: background-color 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.chatbot-header button:hover {
  background-color: rgba(255, 255, 255, 0.2);
}

/* Modal Overlay */
.chat-icon-container {
  position: fixed;
  bottom: 30px;
  right: 30px;
  width: 64px;
  height: 64px;
  background-color: #4f46e5;
  border: 3px solid white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
  cursor: pointer;
  z-index: 1000;
  transition: all 0.3s ease;
  opacity: 1;
  visibility: visible;
}

/* Hide chat icon when chat is open */
.modal-overlay .chat-icon-container {
  opacity: 0;
  visibility: hidden;
  pointer-events: none;
}

.chat-icon-container:hover {
  transform: scale(1.1);
  background-color: #4338ca;
  box-shadow: 0 6px 25px rgba(0, 0, 0, 0.3);
}

.chat-icon {
  font-size: 32px;
  color: rgb(0, 0, 0);
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 600;
  font-size: 1.1em;
  user-select: none;
}

.close-button {
  background: black;
  border: none;
  color: white;
  font-size: 1.8em;
  line-height: 1;
  cursor: pointer;
  padding: 0 5px;
  transition: transform 0.2s, opacity 0.2s;
  opacity: 0.8;
}

.close-button:hover {
  transform: scale(1.2);
  opacity: 1;
}

.chat-window {
  background-color: #ffffff;
  border-radius: 12px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  display: flex;
  flex-direction: column;
  height: 100%;
  max-height: 80vh;
  overflow: hidden;
}

.messages {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 20px;
  background-color: #f9fafb;
  overflow-y: auto;
  color: black;
}

.typing-indicator {
  display: flex;
  padding: 10px 16px;
  background: #ffffff;
  border-radius: 18px;
  align-self: flex-start;
  color: black;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
}

.typing-indicator span {
  height: 8px;
  width: 8px;
  background-color: #9ca3af;
  color: black;
  border-radius: 50%;
  display: inline-block;
  margin: 0 2px;
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
  } 40% { 
    transform: scale(1.0);
  }
}

/* Scrollbar styling */
.messages::-webkit-scrollbar {
  width: 6px;
}

.messages::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 10px;
}

.messages::-webkit-scrollbar-thumb {
  background: #c7d2fe;
  border-radius: 10px;
}

.messages::-webkit-scrollbar-thumb:hover {
  background: #a5b4fc;
}
</style>
