# Stage 1: Build the WAR file using Maven
FROM maven:3.9.9-eclipse-temurin-21 AS builder

# Copy documents folder separately into the image for vectorizing part
COPY documents /documents

# Set working directory inside the builder container
WORKDIR /app

# Copy the entire project (including documents folder)
COPY . .

# Build the project and skip tests to save time (optional)
RUN mvn clean package -DskipTests

# Stage 2: Base image with Tomcat 10.1.40 and Java 21
FROM tomcat:10.1.40-jdk21-temurin

# Set environment variable (for passing Gemini API key at runtime)
ENV TATVASCAN_GEMINI_API_KEY=""

# Clean default webapps to avoid collisions
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR file from the builder image
COPY --from=builder /app/target/tatvascan.war /usr/local/tomcat/webapps/tatvascan.war

# Expose Tomcat's default port (8080)
EXPOSE 8080

# Start Tomcat server
CMD ["catalina.sh", "run"]
