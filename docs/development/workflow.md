# Local Development Guide

## Prerequisites
- [Docker](https://docs.docker.com/get-docker/) installed
- [Docker Compose](https://docs.docker.com/compose/) installed
- MongoDB Atlas account with M0 cluster ([sign up free](https://www.mongodb.com/atlas))

## Setup

### 1. Clone the Repository
```bash
git clone https://github.com/your-org/cloud-native-eks-platform.git
cd cloud-native-eks-platform
```

### 2. Configure Environment Variables
```bash
cp app/.env.example .env
```

Edit `.env` and fill in your MongoDB Atlas connection string:
```
MONGODB_URI=mongodb+srv://<username>:<password>@<cluster>.mongodb.net/fintrack?retryWrites=true&w=majority
```

### 3. Run with Docker Compose
```bash
# Build and start the app
docker-compose up --build

# Or run in detached mode
docker-compose up --build -d
```

### 4. Access the App
Open [http://localhost:3000](http://localhost:3000) in your browser.

## Common Tasks

### Rebuild After Code Changes
```bash
docker-compose up --build
```

### View Logs
```bash
docker-compose logs -f app
```

### Stop Everything
```bash
docker-compose down
```

### Run Without Docker (Node.js directly)
```bash
cd app
npm install
npm run dev
# Open http://localhost:3000
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `MONGODB_URI` not set | Copy `app/.env.example` to `.env` and fill in URI |
| Connection refused to Atlas | Whitelist your IP in Atlas → Network Access |
| Port 3000 in use | `docker-compose down` or kill the process on port 3000 |
| Build fails | Run `docker system prune` then rebuild |
