# Stage 1: Build the project using Maven
FROM maven:3.8.4-openjdk-11-slim AS build
WORKDIR /app

# Copy all files to the build container
COPY . .

# Run the Maven build to create the .war file
RUN mvn -f backend/pom.xml clean package -DskipTests

# Stage 2: Run the app using Tomcat with Exploded Deployment
FROM tomcat:9.0-jdk11-openjdk-slim

# --- RENDER OPTIMIZATION: JVM TUNING ---
ENV JAVA_OPTS="-Xms256m -Xmx440m -XX:+UseSerialGC -Djava.security.egd=file:/dev/./urandom"

# Remove default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/* && mkdir -p /usr/local/tomcat/webapps/ROOT

# Copy the built .war file and UNZIP it (Exploded deployment)
WORKDIR /usr/local/tomcat/webapps/ROOT
COPY --from=build /app/backend/target/blood-bank-system.war ./app.war
RUN jar xf app.war && rm app.war
WORKDIR /usr/local/tomcat

# Port 8080
EXPOSE 8080

# Start the server
CMD ["catalina.sh", "run"]
