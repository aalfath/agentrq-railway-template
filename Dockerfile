# AgentRQ for Railway: the official image, pinned by version and digest.
# Upstream's image is FROM scratch and runs as "nobody", which can't write to a
# Railway volume (mounted root-owned) and has no shell for a start script. So we
# copy its single static binary (web app embedded) onto a pinned Alpine base.
FROM agentrq/agentrq:0.17.4@sha256:de038f632cad3783e0f4c03624c4ad8e60dd667230dc9292ef2c6eb70f7d1357 AS upstream

FROM alpine:3.22.8@sha256:49340b346798875b5592e5d420241f2f9cfba5f47e62ebb1446a1b34734e898f

# No apk packages needed: Alpine ships the CA bundle, and BusyBox su drops to
# "nobody" while keeping PID 1 and the environment.
RUN mkdir -p /_storage

COPY --from=upstream /agentrq /usr/local/bin/agentrq
COPY start.sh /usr/local/bin/start.sh
RUN chmod 755 /usr/local/bin/start.sh /usr/local/bin/agentrq

ENV ENV=production \
    PORT=2026

EXPOSE 2026
ENTRYPOINT ["/usr/local/bin/start.sh"]
