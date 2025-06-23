# PromptCraft - Advanced Prompt Engineering Platform

PromptCraft is a comprehensive platform for creating, managing, and optimizing AI prompts. It combines a Flutter-based frontend with a Django backend and AI services integration.

## 🚀 Features

- **Template Management**: Create, edit, and organize prompt templates
- **AI Integration**: Analyze and optimize prompts using AI services
- **User Management**: User authentication, roles, and permissions
- **Analytics**: Track usage patterns and performance metrics
- **Gamification**: Engage users with challenges and achievements

## 🛠 Tech Stack

### Backend
- Django 4.2 with Django REST Framework
- PostgreSQL database
- Redis for caching and Celery tasks
- OpenAI and Anthropic AI integrations

### Frontend
- Flutter for cross-platform support (web, mobile, desktop)
- Responsive design with material design components

### DevOps
- Docker and Docker Compose for containerization
- Nginx for serving frontend and backend proxy

## 🔧 Setup & Installation

### Prerequisites
- Docker and Docker Compose
- Git

### Local Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/promptcraft.git
   cd promptcraft
   ```

2. **Create environment file**
   ```bash
   cp .env.sample .env
   # Edit .env file with your settings
   ```

3. **Start the application with Docker Compose**
   ```bash
   docker-compose up
   ```

4. **Access the applications**
   - Backend API: http://localhost:8000/api/
   - Frontend App: http://localhost:3000/
   - Django Admin: http://localhost:8000/admin/

### Development without Docker

#### Backend Setup

1. **Set up Python environment**
   ```bash
   cd my_prmpt_bakend
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

2. **Apply migrations and create superuser**
   ```bash
   python manage.py migrate
   python manage.py createsuperuser
   ```

3. **Run development server**
   ```bash
   python manage.py runserver
   ```

#### Frontend Setup

1. **Set up Flutter environment**
   ```bash
   cd my_prmpt_app
   flutter pub get
   ```

2. **Run Flutter web app**
   ```bash
   flutter run -d chrome
   ```

## 📊 Project Structure

```
promptcraft/
├── my_prmpt_bakend/           # Django backend
│   ├── apps/                  # Django apps
│   │   ├── ai_services/       # AI integration services
│   │   ├── analytics/         # User analytics and data tracking
│   │   ├── core/              # Core functionality and utilities
│   │   ├── gamification/      # User achievements and challenges
│   │   ├── templates/         # Prompt templates management
│   │   └── users/             # User authentication and profiles
│   ├── promptcraft/           # Project settings
│   └── manage.py              # Django management script
│
├── my_prmpt_app/              # Flutter frontend
│   ├── lib/                   # Dart/Flutter code
│   ├── assets/                # Static assets
│   └── test/                  # Frontend tests
│
├── docker-compose.yml         # Docker Compose configuration
└── .env.sample                # Sample environment variables
```

## 📝 API Documentation

API documentation is available at `/api/docs/` when running the server. It provides detailed information about all available endpoints, request/response formats, and authentication requirements.

## 🧪 Testing

### Backend Tests
```bash
cd my_prmpt_bakend
python manage.py test
```

### Frontend Tests
```bash
cd my_prmpt_app
flutter test
```

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔗 Links

- [Frontend Repository](#)
- [Backend Repository](#)
- [Production Demo](#)
