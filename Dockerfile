# Stage 1: Build the project using Maven
FROM maven:3.8.4-openjdk-11-slim AS build
WORKDIR /app

# Copy all files to the build container
COPY . .

# Run the Maven build to create the .war file
RUN mvn -f backend/pom.xml clean package -DskipTests

# Stage 2: Run the app using Tomcat
FROM tomcat:9-jdk11-openjdk-slim

# Remove default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the built .war file from the build stage
# We rename it to ROOT.war so it loads at the main URL (/)
COPY --from=build /app/backend/target/blood-bank-system.war /usr/local/tomcat/webapps/ROOT.war

# Port 8080 is the standard for Tomcat
EXPOSE 8080

# Start the server
CMD ["catalina.sh", "run"]
