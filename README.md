# Flashcards AI

## Project Description

Flashcards AI is a web application designed to simplify and accelerate the creation of educational flashcards. The platform supports both manual input and AI-assisted generation, enabling efficient study material creation and review. Key features include:

- **Manual Flashcard Creation:** Create flashcards by entering a front (up to 200 characters) and a back (up to 500 characters) with real-time validation.
- **AI-Assisted Generation:** Input text (up to 10,000 characters) to generate flashcards using AI, complete with status feedback and minimal animations during processing.
- **Flashcard Review:** Review AI-generated flashcards with options to accept, edit (with confirmation), or reject the proposals.
- **User Management:** Includes user registration, login, password changes, and account deletion with secure data handling.
- **Activity Logging:** Generation operations are logged for monitoring purposes.

## Tech Stack

- **Frontend:**
  - Astro for performance optimization
  - React for interactive components
  - TypeScript for reliable development
  - Tailwind CSS and Shadcn/ui for styling and pre-built components

- **Backend:**
  - Supabase providing PostgreSQL database support with built-in authentication and SDK integration

- **Additional Technologies:**
  - Openrouter.ai integration
  - CI/CD pipelines
  - Docker for containerization

## Getting Started Locally

### Prerequisites

- **Node.js:** Use version specified in `.nvmrc` (node version 22.14.0)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the development server:
   ```bash
   npm run dev
   ```

## Available Scripts

The project includes several npm scripts defined in the `package.json`:

- `npm run dev` - Starts the Astro development server
- `npm run build` - Builds the project for production
- `npm run preview` - Previews the production build
- `npm run astro` - Runs Astro CLI commands

## Project Scope

The project is focused on delivering a Minimum Viable Product (MVP) with the following scope:

- **Included Features:**
  - Manual flashcard creation with input validations
  - AI-assisted flashcard generation and review process
  - User account management (registration, login, password change, account deletion)
  - Logging of flashcard generation events

- **Out of Scope:**
  - Advanced spaced repetition algorithms (beyond basic implementations)
  - Importing flashcards from various formats (PDF, DOCX, etc.)
  - Sharing flashcard sets between users
  - Mobile application support (web version only)
  - Advanced data export and filtering functionalities

## Project Status

This project is currently in the MVP stage, with ongoing development to enhance features and scalability.

## License

This project is licensed under the MIT License. 