
FROM node:lts-slim as builder

LABEL version="0.0.6"
LABEL description="Demo app showing PingOne Protect integration"
LABEL maintainer="Chris Price <cprice@pingidentity.com>"

# update packages, to reduce risk of vulnerabilities
RUN apt-get update && apt-get upgrade -y && apt-get autoclean -y && apt-get autoremove -y

# set a non privileged user to use when running this image
RUN groupadd -r nodejs && useradd -g nodejs -s /bin/bash -d /home/nodejs -m nodejs
USER nodejs
# set right (secure) folder permissions
RUN mkdir -p /home/nodejs/app/node_modules && chown -R nodejs:nodejs /home/nodejs/app

WORKDIR /home/nodejs/app

# set default node env
ARG NODE_ENV=development
# ARG NODE_ENV=production
# to be able to run tests (for example in CI), do not set production as environment
ENV NODE_ENV=${NODE_ENV}

ENV NPM_CONFIG_LOGLEVEL=warn

# Deployment Environment Variables
ENV HOSTNAME=${HOSTNAME}
ENV ENVID=${ENVID}
ENV OIDCLIENTID=${OIDCLIENTID}
ENV WORKERID=${WORKERID}
ENV WORKERSECRET=${WORKERSECRET}
ENV PROTECTPOLICYID=${PROTECTPOLICYID}

# copy project definition/dependencies files, for better reuse of layers
COPY --chown=nodejs:nodejs package*.json ./

# install dependencies here, for better reuse of layers
RUN npm install && npm audit fix && npm cache clean --force

# copy all sources in the container (exclusions in .dockerignore file)
COPY --chown=nodejs:nodejs . .

# exposed port/s
EXPOSE 3000

# ENTRYPOINT [ "node" ]
CMD [ "node", "./server.js" ]

# end.