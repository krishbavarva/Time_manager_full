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
          <div
            v-for="(message, index) in messages"
            :key="index"
            :class="['message', message.role]"
          >
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
          content: "Hello! I'm your Time Manager Assistant."
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
    content: `You are an instructional chatbot for the Time Manager website, a web-based time and attendance management system. Your job is to guide users—employees, managers, and admins—through all features of the platform.

User Roles and Actions:

Employee:
- Can mark attendance by pressing the "Present" button on the dashboard. This will start the timer automatically for the day.
- Can manually start or stop work time via the Clock In / Clock Out page.
- Can clock out for breaks using the "Clock Out" button.
- Can set their work schedule via the Schedule page by clicking "Set My Schedule."
- Can view their schedule by clicking "View My Schedule."
- Can view pay and check overtime on the Work Times page.

Manager:
- Can see all the teams they are managing.
- Can add or remove team members from a team via the Team Member page.
- Can view analytics for their teams through graphs and tables (attendance, work hours, etc.).

Admin:
- Can create new teams and appoint managers for those teams via the Admin Teams page.
- Can view all users and their details on the Users page.
- Can update user roles (Employee, Manager, Admin).
- Can see all attendances of all users, mark them absent, and track punctuality via the Attendance page.
- Must approve leave requests submitted by employees.

Guidelines:
- Always respond in a friendly, instructional tone.
- Give step-by-step instructions when guiding users.
- Tailor instructions to the user’s role: employee, manager, or admin.
- Guide users to the correct page or button if they are unsure.
- Do not make assumptions outside the described functionality.`
  },
  ...this.messages
]);


    console.log('Backend response:', response);

    // Update to handle { reply: "..." } structure
    const assistantMessage = {
      role: 'assistant',
      content: response.reply || 'Sorry, no response from the server.'
    };

    this.messages.push(assistantMessage);

  } catch (error) {
    console.error('Error sending message:', error);
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
.chat-container {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background-color: #f8fafc; /* light background */
  display: flex;
  flex-direction: column;
  font-family: 'Inter', sans-serif;
}

/* Chat Header */
.chatbot-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: #4f46e5;
  color: white;
  padding: 16px;
  font-weight: 600;
  font-size: 1.2rem;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
}

.chatbot-header button {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  border-radius: 50%;
  color: white;
  font-size: 1.4rem;
  width: 36px;
  height: 36px;
  cursor: pointer;
  display: flex;
  justify-content: center;
  align-items: center;
  transition: background 0.2s, transform 0.2s;
}

.chatbot-header button:hover {
  background: rgba(255, 255, 255, 0.4);
  transform: scale(1.1);
}

/* Messages Area */
.messages {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  background-color: #f8fafc;
  scroll-behavior: smooth;
}

/* Individual Message Bubbles */
.message {
  max-width: 75%;
  padding: 10px 16px;
  border-radius: 20px;
  line-height: 1.5;
  position: relative;
  word-wrap: break-word;
  font-size: 0.95rem;
  animation: fadeIn 0.3s ease-out;
}

.message.user {
  align-self: flex-end;
  background: #4f46e5;
  color: white;
  border-bottom-right-radius: 6px;
}

.message.assistant {
  align-self: flex-start;
  background: #ffffff;
  border: 1px solid #e2e8f0;
  color: #1f2937;
  border-bottom-left-radius: 6px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

/* Typing Indicator */
.typing-indicator {
  display: flex;
  align-self: flex-start;
  gap: 6px;
  padding: 10px 14px;
  border-radius: 16px;
  background-color: #e5e7eb;
}

.typing-indicator span {
  width: 8px;
  height: 8px;
  background-color: #6b7280;
  border-radius: 50%;
  animation: bounce 1.4s infinite ease-in-out both;
}

.typing-indicator span:nth-child(1) { animation-delay: -0.32s; }
.typing-indicator span:nth-child(2) { animation-delay: -0.16s }

/* Input Area */
.input-area {
  display: flex;
  gap: 10px;
  padding: 12px 16px;
  border-top: 1px solid #e5e7eb;
  background-color: #ffffff;
}

.message-input {
  flex: 1;
  padding: 10px 14px;
  border-radius: 12px;
  border: 1px solid #d1d5db;
  font-size: 0.95rem;
  outline: none;
  transition: all 0.2s ease;
}

.message-input:focus {
  border-color: #4f46e5;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
  background-color: #ffffff;
}

.send-button {
  padding: 0 16px;
  border-radius: 12px;
  background-color: #4f46e5;
  color: white;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.send-button:hover:not(:disabled) {
  background-color: #4338ca;
  transform: translateY(-1px);
}

.send-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* Animations */
@keyframes bounce {
  0%, 80%, 100% { transform: scale(0); }
  40% { transform: scale(1); }
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Scrollbar Styling */
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
