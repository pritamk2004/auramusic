# Stage 1: Build Flutter Web Release
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release

# Stage 2: Serve with Lightweight Python Real-Time Backend
FROM python:3.11-slim

WORKDIR /app
COPY --from=build /app/build/web ./build/web
COPY backend/server.py ./backend/server.py

EXPOSE 8080 10000
ENV PORT=8080

CMD ["python", "backend/server.py"]
