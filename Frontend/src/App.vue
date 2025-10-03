<template>
  <div id="app">
    <header class="topbar">
      <nav class="nav">
        <RouterLink to="/dashboard">Dashboard</RouterLink>
        <RouterLink to="/working-times">Working Times</RouterLink>
        <RouterLink to="/clockins">Clockins</RouterLink>
        <span class="spacer"/>
        <RouterLink to="/login">Logout</RouterLink>
      </nav>
    </header>
    <main class="content">
      <RouterView />
    </main>
    <ChatBot />
  </div>
</template>

<script setup>
import { RouterLink, RouterView } from 'vue-router';
import ChatBot from '@/components/ChatBot.vue';
</script>

<style>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');
@import '@/assets/styles/shared.css';

:root {
  --primary: #4f46e5;
  --primary-hover: #4338ca;
  --text: #111827;
  --text-muted: #6b7280;
  --border: #e5e7eb;
  --bg: #f9fafb;
  --card-bg: #ffffff;
  --success: #10b981;
  --warning: #f59e0b;
  --danger: #ef4444;
  --info: #3b82f6;
}

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

html, body, #app {
  height: 100%;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
  line-height: 1.5;
  color: var(--text);
  background-color: var(--bg);
}

#app {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

/* Top Navigation */
.topbar {
  background-color: var(--card-bg);
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 0;
  z-index: 50;
  border-bottom: 1px solid var(--border);
}

.nav {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0.75rem 1rem;
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.nav a {
  color: var(--text);
  text-decoration: none;
  font-weight: 500;
  font-size: 0.9375rem;
  padding: 0.5rem 0;
  position: relative;
  transition: color 0.2s;
}

.nav a:hover {
  color: var(--primary);
}

.nav a.router-link-active {
  color: var(--primary);
  font-weight: 600;
}

.nav a.router-link-active::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 2px;
  background-color: var(--primary);
  border-radius: 1px;
}

.spacer {
  flex: 1;
}

.content {
  flex: 1;
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  padding: 1.5rem 1rem;
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .nav {
    padding: 0.5rem 1rem;
    gap: 1rem;
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
  }
  
  .nav a {
    font-size: 0.875rem;
    white-space: nowrap;
  }
  
  .content {
    padding: 1rem 0.75rem;
  }
}
</style>
