FROM gradle:8.11.1-jdk17 AS builder

ADD --chown=gradle . /app

WORKDIR /app

RUN ./gradlew --no-daemon clean build -x test && rm -rf /root/.kotlin/daemon /tmp/*


FROM eclipse-temurin:17.0.8_7-jre-jammy

WORKDIR /app

COPY --from=builder /app/build/libs/*.jar .

RUN useradd -ms /bin/bash pharma



USER pharma

EXPOSE 8080

ENTRYPOINT exec java -ea -Dspring.profiles.active=prod -jar /app/*.jar
