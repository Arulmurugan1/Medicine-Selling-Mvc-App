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
RUN mvn dependency:go-offline -pl common-lib,notification-service -am -q
COPY common-lib/src common-lib/src
COPY notification-service/src notification-service/src
RUN mvn clean package -pl common-lib,notification-service -am -DskipTests -q

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /workspace/notification-service/target/notification-service-*.jar app.jar
EXPOSE 3005
ENTRYPOINT ["java", "-jar", "app.jar"]
