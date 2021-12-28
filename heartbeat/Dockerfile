FROM docker.elastic.co/beats/heartbeat:7.16.2
COPY heartbeat.yml /usr/share/heartbeat/heartbeat.yml
USER root
RUN chown root:heartbeat /usr/share/heartbeat/heartbeat.yml
USER heartbeat
RUN heartbeat setup
ENTRYPOINT ["/usr/share/heartbeat/heartbeat"]
CMD ["-e"]