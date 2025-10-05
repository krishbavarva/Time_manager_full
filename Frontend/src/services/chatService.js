import { http } from '../api/http';

const API_URL = '/api/chat';

export const chatService = {
  async sendMessage(messages) {
    try {
      // For now, return a mock response since backend chat API isn't implemented
      // In a real implementation, this would call: const response = await http.post(API_URL, { messages });

      // Simulate API delay
      await new Promise(resolve => setTimeout(resolve, 1000));

      return {
        choices: [{
          message: {
            role: 'assistant',
            content: 'I understand your question about the Time Manager. This application helps you track your work hours, clock in/out, and manage your schedule. You can view your working time history and statistics here.'
          }
        }]
      };
    } catch (error) {
      console.error('Error sending message to chatbot:', error);
      throw error;
    }
  }
};
