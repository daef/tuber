FROM alpine as cargo-build
RUN apk --no-cache add cargo
RUN cargo install htmlq


FROM alpine

RUN apk --no-cache add curl
RUN apk --no-cache add jq
RUN apk add --no-cache bash

COPY --from=cargo-build /root/.cargo/bin/htmlq /bin/htmlq

COPY tuber.sh /
WORKDIR /data

ENTRYPOINT ["bash", "/tuber.sh"]

