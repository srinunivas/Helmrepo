FROM jenkins-deploy.fircosoft.net/third-parties/alpine-with-certs AS a

RUN apk add build-base
RUN echo "int main() {return 0;}" > /noop.c
RUN cc -static /noop.c -o /noop

FROM scratch

COPY --from=a /noop /noop

COPY licenses-easysoft3.5.1/* /opt/third-parties/easysoft/licenses/
COPY licenses-easysoft3.8.0/* /opt/third-parties/easysoft/licenses/
COPY entrypoint.sh /opt/third-parties/easysoft/

CMD ["/noop"]