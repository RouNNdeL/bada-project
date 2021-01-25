FROM gradle:6.7.1-jdk11 AS cache
WORKDIR /app
RUN mkdir -p /cache
ENV GRADLE_USER_HOME /cache
COPY build.gradle.kts settings.gradle.kts ./
RUN gradle clean build --stacktrace --info

FROM gradle:6.7.1-jdk11 AS builder
WORKDIR /app
COPY --from=cache /cache /home/gradle/.gradle
COPY . .
RUN gradle bootJar --stacktrace --info

FROM openjdk:11-jre-slim
WORKDIR /app
RUN apt-get update && apt-get install -y curl
COPY --from=builder /app/build/libs/*.jar /bada.jar
ENV PORT 8080
EXPOSE 8080

HEALTHCHECK --timeout=5s --start-period=5s --retries=1 \
    CMD curl -f http://localhost:8081/health_check

CMD ["java","-jar","-Dspring.profiles.active=default","/bada.jar"]