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
COPY .gitignore .gitignore
RUN pnpm install --frozen-lockfile
RUN pnpm build 


FROM base AS runner
WORKDIR /app

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
USER nextjs

COPY --from=installer /app/next.config.js .

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=installer --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=installer --chown=nextjs:nodejs /app/.next/static ./
COPY --from=installer --chown=nextjs:nodejs /app/public ./

EXPOSE 3000

CMD node app/server.js