# ---- Build Stage ----
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace

COPY pom.xml .
COPY common-lib/pom.xml common-lib/
COPY eureka-server/pom.xml eureka-server/
COPY api-gateway/pom.xml api-gateway/
COPY auth-service/pom.xml auth-service/
COPY medicine-service/pom.xml medicine-service/
COPY order-service/pom.xml order-service/
COPY notification-service/pom.xml notification-service/
COPY mvc-frontend/pom.xml mvc-frontend/
RUN mvn dependency:go-offline -pl common-lib,api-gateway -am -q

COPY common-lib/src common-lib/src
COPY api-gateway/src api-gateway/src
RUN mvn clean package -pl common-lib,api-gateway -am -DskipTests -q

# ---- Runtime Stage ----
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /workspace/api-gateway/target/api-gateway-*.jar app.jar
EXPOSE 3001
ENTRYPOINT ["java", "-jar", "app.jar"]
