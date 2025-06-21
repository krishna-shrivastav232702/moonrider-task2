FROM maven:3.9.9-eclipse-temurin-17-alpine AS build

WORKDIR /app

COPY pom.xml .

RUN mvn dependency:go-offline -B

COPY src ./src

RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

RUN addgroup -g 1001 appgroup && \
    adduser -D -u 1001 -G appgroup appuser

COPY --from=build /app/target/*.jar app.jar

RUN chown -R appuser:appgroup /app

USER appuser

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
 CMD wget --no-verbose --tries=1 --spider http://localhost:9191/actuator/health || exit 1

EXPOSE 9191

ENTRYPOINT [ "java","-jar","app.jar" ]