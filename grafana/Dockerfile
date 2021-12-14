FROM grafana/grafana:latest-ubuntu
USER root
COPY ./provisioning /etc/grafana/provisioning
COPY ./config.ini /etc/grafana/config.ini
COPY ./dashboards /usr/share/grafana/dashboards
RUN export DEBIAN_FRONTEND=noninteractive ;\
	apt-get update ;\
	rm -rf /var/lib/apt/lists/* ;\
	apt-get clean
