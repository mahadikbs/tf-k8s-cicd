# pull microk8s image
FROM kindest/node AS base

#install additional dependencies
RUN apt update && apt install -y \
    curl \
    openjdk-11-jdk \
    git \
    && apt clean

#pull prometheus image

FROM prom/prometheus AS prometheus    

#pull Jenkins image

FROM jenkins/jenkins:lts AS jenkins

# pull Grafana image

FROM grafana/grafana AS grafana

# Build custom image

FROM base

# copy Prometheus, Jenkins, and Grafana into the base/final image

COPY --from=prometheus /etc/prometheus etc/prometheus
COPY --from=jenkins /var/jenkins_home /var/jenkins_home
COPY --from=grafana /var/lib/grafana /var/lib/grafana

#expose respective ports for k8s, grafana, prometheus, jenkins

EXPOSE 16443 3030 9090 8080

# Start all services

CMD microk8s.start && systemctl start prometheus && systemctl start jenkins && systemctl start grafana-server && tail -f /dev/null