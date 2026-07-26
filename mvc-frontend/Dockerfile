FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY . .
RUN mvn clean package -DskipTests -q

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /workspace/mvc-frontend/target/mvc-frontend-*[0-9].war app.war
EXPOSE 3006
ENTRYPOINT ["java", "-jar", "app.war"]
