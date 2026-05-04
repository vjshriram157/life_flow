# Stage 1: Build the project using Maven
FROM maven:3.8.4-openjdk-11-slim AS build
WORKDIR /app

# Copy all files to the build container
COPY . .

# Run the Maven build to create the .war file
RUN mvn -f backend/pom.xml clean package -DskipTests

# Stage 2: Run the app using Tomcat with Optimized JVM
FROM tomcat:9.0-jdk11-openjdk-slim

# --- RENDER OPTIMIZATION: JVM TUNING ---
# We limit memory usage and use SerialGC to prevent lagging on free tier (512MB RAM)
ENV JAVA_OPTS="-Xms256m -Xmx440m -XX:+UseSerialGC -Djava.security.egd=file:/dev/./urandom"

# Remove default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the built .war file
COPY --from=build /app/backend/target/blood-bank-system.war /usr/local/tomcat/webapps/ROOT.war

# Port 8080
EXPOSE 8080

# Start the server
CMD ["catalina.sh", "run"]
