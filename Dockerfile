# Stage 1: Build the project using Maven
FROM maven:3.8.4-openjdk-11-slim AS build
WORKDIR /app
COPY . .
RUN mvn -f backend/pom.xml clean package -DskipTests

# Stage 2: Run the app using Jetty (Lighter than Tomcat)
FROM jetty:9.4-jre11-slim

# Copy the built classes and web resources directly
# This ensures no "WAR packaging" issues
USER root
RUN rm -rf /var/lib/jetty/webapps/ROOT && mkdir -p /var/lib/jetty/webapps/ROOT
COPY --from=build /app/web/ /var/lib/jetty/webapps/ROOT/
COPY --from=build /app/backend/target/classes/ /var/lib/jetty/webapps/ROOT/WEB-INF/classes/
COPY --from=build /app/backend/target/blood-bank-system/WEB-INF/lib/ /var/lib/jetty/webapps/ROOT/WEB-INF/lib/

# Set permissions
RUN chown -R jetty:jetty /var/lib/jetty/webapps/ROOT

USER jetty
EXPOSE 8080

