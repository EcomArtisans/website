# This Dockerfile is copy-pasted into our main docs at /docs/handbook/deploying-with-docker.
# Make sure you update both files!
FROM node:20.10.0-alpine3.19 AS base 

# Add lockfile and package.json's of isolated subworkspace
FROM base AS installer
ENV PNPM_VERSION=8.9.2

RUN apk add --no-cache libc6-compat
RUN apk update
RUN corepack enable
RUN corepack prepare pnpm@${PNPM_VERSION} --activate
WORKDIR /app

# First install the dependencies (as they change less often)
COPY . .
RUN pnpm install --frozen-lockfile
RUN pnpm build 


FROM base AS runner
WORKDIR /app

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
USER nextjs


# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=installer --chown=nextjs:nodejs /app/next.config.js .
COPY --from=installer --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=installer --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=installer --chown=nextjs:nodejs /app/public ./public

EXPOSE 3000

CMD HOSTNAME="0.0.0.0" node server.js