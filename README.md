# 10x-cards

A web application for quickly creating and managing educational flashcards using AI-powered suggestions.

## Project Description

10x-cards enables users to quickly create and manage educational flashcard sets using Large Language Models (LLMs). 
The application uses AI to generate flashcard suggestions based on provided text, significantly reducing the time and effort required to create high-quality study materials. 

Key features:
- AI-powered flashcard generation from pasted text
- Manual creation and management of flashcards
- Integration with spaced repetition algorithms for efficient learning
- Basic user authentication and account management
- Secure data storage compliant with GDPR requirements

## Tech Stack

### Frontend
- Vue.js 3.2.13
- TypeScript 5
- Tailwind CSS 4
- Vue CLI for project scaffolding

### Backend
- Supabase as a comprehensive backend solution:
  - PostgreSQL database
  - SDK for Backend-as-a-Service functionality
  - Built-in user authentication

### AI Integration
- Communication with LLM models via Openrouter.ai service

### CI/CD & Hosting
- GitHub Actions for CI/CD pipelines
- DigitalOcean for application hosting via Docker

## Getting Started Locally

### Prerequisites
- Node.js v22.15.0 (specified in .nvmrc)
- npm or yarn package manager

### Installation

1. Clone the repository
```bash
git clone https://github.com/strozi28/10x-cards.git
cd 10x-cards
```

2. Install Node.js using nvm (recommended)
```bash
nvm install
```
or manually install Node.js v22.15.0

3. Install dependencies
```bash
npm install
```
or
```bash
yarn install
```

4. Set up environment variables
Create a `.env` file in the root directory with necessary API keys and configuration

5. Start the development server
```bash
npm run serve
```
or
```bash
yarn serve
```

6. Access the application at `http://localhost:8080`

## Available Scripts

- `npm run serve` - Starts the development server
- `npm run build` - Builds the app for production
- `npm run test:unit` - Runs unit tests
- `npm run test:e2e` - Runs end-to-end tests
- `npm run lint` - Runs the linter for code quality checks

## Project Scope

### Features Included in MVP
- AI-powered flashcard generation from text
- Manual flashcard creation and editing
- User authentication (registration, login)
- Integration with external spaced repetition algorithms
- Study session view with spaced repetition
- Basic user data management (view and delete personal data)
- Statistics on generated flashcards

## Project Status

This project is currently in early development.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
