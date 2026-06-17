FROM gradle:8.11.1-jdk17 AS builder

ADD --chown=gradle . /app

WORKDIR /app

# Force Kotlin to run in-process to stop daemon files from being created
RUN ./gradlew --no-daemon clean build -x test -Dkotlin.compiler.execution.strategy=in-process


FROM eclipse-temurin:17.0.8_7-jre-jammy

WORKDIR /app

COPY --from=builder /app/build/libs/*.jar .

RUN useradd -ms /bin/bash pharma



USER pharma

EXPOSE 8080

ENTRYPOINT exec java -ea -Dspring.profiles.active=prod -jar /app/*.jar
