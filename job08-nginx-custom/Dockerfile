FROM debian:bookworm
RUN apt update && apt install -y nginx
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
