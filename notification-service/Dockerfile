FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY . .
RUN mvn clean package -DskipTests -q

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /workspace/notification-service/target/notification-service-*[0-9].jar app.jar
EXPOSE 3005
ENTRYPOINT ["java", "-jar", "app.jar"]
