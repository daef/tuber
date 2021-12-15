FROM alpine

RUN apk --no-cache add curl
RUN apk --no-cache add jq
RUN apk --no-cache add cargo
RUN cargo install htmlq
RUN apk add --no-cache bash

COPY tuber.sh /
WORKDIR /data

ENV PATH="/root/.cargo/bin:${PATH}"

ENTRYPOINT ["bash", "/tuber.sh"]

