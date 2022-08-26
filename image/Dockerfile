FROM alpine:3.16.1
COPY start.sh /start.sh
RUN apk add --no-cache squid && \
    chmod +x /start.sh
CMD ["/start.sh"]
