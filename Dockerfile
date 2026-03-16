FROM runpod/comfyui-base:latest

USER root

RUN apt-get update \
    && apt-get install -y dumb-init \
    && rm -rf /var/lib/apt/lists/*

COPY custom-runpod.sh /custom-runpod.sh
RUN chmod +x /custom-runpod.sh

EXPOSE 18080

ENTRYPOINT ["dumb-init", "--"]
CMD ["/custom-runpod.sh"]
