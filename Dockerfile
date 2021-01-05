FROM gradle:jdk11 AS cache
WORKDIR /app
ENV GRADLE_USER_HOME /cache
COPY build.gradle.kts settings.gradle.kts ./
RUN gradle --no-daemon jar --stacktrace

FROM gradle:jdk11 AS builder
WORKDIR /app
COPY --from=cache /cache /home/gradle/.gradle
COPY . .
RUN gradle --no-daemon build --stacktrace --info

FROM openjdk:11-jre-slim
WORKDIR /app
COPY --from=builder /app/build/libs/*.jar /bada.jar
EXPOSE 8080

ENTRYPOINT ["java","-jar","/bada.jar"]