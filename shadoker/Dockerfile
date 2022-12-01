FROM python:3.10.2 as build
COPY requirements.txt .
RUN pip3 install --user -r requirements.txt

FROM python:3.10.2-slim as base
RUN apt-get update
RUN apt-get install -y ca-certificates curl gnupg lsb-release
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update  
#RUN apt-get install -y git docker-ce docker-ce-cli containerd.io
RUN apt-get install -y git docker-ce-cli

COPY --from=build /root/.local /root/.local
ENV PATH=/root/.local:$PATH
WORKDIR /shadoker
COPY . .

FROM base
RUN pip3 install pytest
ENV PYTHONPATH=/
RUN pytest /shadoker

FROM base
VOLUME [ "/data" ]
WORKDIR /data
ENV PYTHONPATH=/
ENTRYPOINT [ "python", "/shadoker/__main__.py" ]
