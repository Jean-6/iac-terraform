FROM eclipse-temurin:17-jdk
LABEL authors="Jean"

WORKDIR /app

COPY target/*.jar app.jar

EXPOSE 8082

CMD ["java","-jar","app.jar"]
