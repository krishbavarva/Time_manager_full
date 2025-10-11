import { http } from '../api/http';

const API_URL = '/api/chat';

export const chatService = {
  async sendMessage(messages) {
    try {
      // Send messages to the backend chat endpoint
      const response = await http.post(API_URL, { messages });

      // Return the backend’s response in the expected structure
      console.log('Chatbot response:', response);
      return response;
    } catch (error) {
      console.error('Error sending message to chatbot:', error);
      throw error;
    }
  }
};
