FROM debian:bookworm
RUN apt update && apt install -y openssh-server
RUN echo "root:root123" | chpasswd
RUN mkdir /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
EXPOSE 2222
CMD ["/usr/sbin/sshd", "-D"]
