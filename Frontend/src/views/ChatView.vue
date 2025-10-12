<template>
  <div class="min-h-screen bg-gradient-to-br from-indigo-50 via-white to-purple-50 flex items-center justify-center p-4">
    <div class="w-full max-w-4xl h-[80vh] bg-white/80 backdrop-blur-xl rounded-3xl shadow-2xl border border-white/20 overflow-hidden flex flex-col">
      <!-- Header -->
      <div class="bg-gradient-to-r from-indigo-600 to-purple-600 p-6 flex items-center justify-between">
        <div class="flex items-center space-x-4">
          <div class="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center">
            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/>
            </svg>
          </div>
          <div>
            <h1 class="text-xl font-bold text-white">Timemanager Assistant</h1>
            <p class="text-indigo-100 text-sm">Your AI-powered time management helper</p>
          </div>
        </div>
        <button @click="closeChat" class="p-2 hover:bg-white/20 rounded-full transition-colors duration-200" title="Close Chat">
          <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
        </button>
      </div>
      
      <!-- Messages Area -->
      <div class="flex-1 overflow-y-auto p-6 space-y-4" ref="messagesContainer">
        <div v-for="(message, index) in messages" :key="index" class="flex message" :class="message.role === 'user' ? 'justify-end' : 'justify-start'">
          <div class="max-w-xs lg:max-w-md xl:max-w-lg">
            <div v-if="message.role === 'assistant'" class="flex items-start space-x-3">
              <div class="w-8 h-8 bg-gradient-to-r from-indigo-500 to-purple-500 rounded-full flex items-center justify-center flex-shrink-0">
                <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                </svg>
              </div>
              <div class="bg-gray-100 rounded-2xl rounded-tl-md px-4 py-3 shadow-sm">
                <p class="text-gray-800 text-sm leading-relaxed">{{ message.content }}</p>
              </div>
            </div>
            <div v-else class="bg-gradient-to-r from-indigo-500 to-purple-500 rounded-2xl rounded-tr-md px-4 py-3 shadow-sm">
              <p class="text-white text-sm leading-relaxed">{{ message.content }}</p>
            </div>
          </div>
        </div>
        
        <!-- Typing Indicator -->
        <div v-if="isLoading" class="flex justify-start">
          <div class="max-w-xs lg:max-w-md xl:max-w-lg">
            <div class="flex items-start space-x-3">
              <div class="w-8 h-8 bg-gradient-to-r from-indigo-500 to-purple-500 rounded-full flex items-center justify-center flex-shrink-0">
                <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                </svg>
              </div>
              <div class="bg-gray-100 rounded-2xl rounded-tl-md px-4 py-3 shadow-sm">
                <div class="flex space-x-1">
                  <div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                  <div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 0.1s"></div>
                  <div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 0.2s"></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Input Area -->
      <div class="p-6 border-t border-gray-200 bg-gray-50/50">
        <div class="flex space-x-3">
          <div class="flex-1 relative">
            <input
              v-model="userInput"
              @keyup.enter="sendMessage"
              placeholder="Ask me anything about time management..."
              class="w-full px-4 py-3 pr-12 bg-white border border-gray-200 rounded-2xl focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent shadow-sm transition-all duration-200"
              :disabled="isLoading"
            />
            <button @click="sendMessage" :disabled="isLoading || !userInput.trim()" class="absolute right-2 top-1/2 transform -translate-y-1/2 p-2 rounded-xl transition-all duration-200" :class="isLoading || !userInput.trim() ? 'bg-gray-100 text-gray-400 cursor-not-allowed' : 'bg-gradient-to-r from-indigo-500 to-purple-500 text-white hover:shadow-lg hover:scale-105'">
              <svg v-if="!isLoading" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"/>
              </svg>
              <div v-else class="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
            </button>
          </div>
        </div>
        <p class="text-xs text-gray-500 mt-2 text-center">Press Enter to send • AI Assistant for Timemanager</p>
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
          content: 'Hello! I\'m your Timemanager Assistant. I can help you with time tracking, clock-in/out processes, leave requests, dashboard analytics, and general questions about the system. How can I assist you today?'
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
            content: `You are Timemanager Assistant, an AI helper for a professional time management system. 
            The Timemanager application allows employees, managers, and admins to:
            - Clock in/out with location tracking
            - View work time analytics and dashboard metrics
            - Submit and manage leave requests
            - Track productivity and time statistics
            - Manage user roles (Admin, Manager, Employee)
            
            Provide helpful, professional guidance about these features. Be concise, friendly, and informative.`
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
        if (container) container.scrollTop = container.scrollHeight;
      });
    }
  }
};
</script>

<style scoped>
/* Custom animations for enhanced user experience */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.message {
  animation: fadeInUp 0.3s ease-out;
}

/* Custom scrollbar for messages area */
.messages::-webkit-scrollbar {
  width: 6px;
}

.messages::-webkit-scrollbar-track {
  background: transparent;
}

.messages::-webkit-scrollbar-thumb {
  background: rgba(99, 102, 241, 0.3);
  border-radius: 3px;
}

.messages::-webkit-scrollbar-thumb:hover {
  background: rgba(99, 102, 241, 0.5);
}
</style>
