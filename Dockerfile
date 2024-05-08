#
# Multi Stage: Dev Image
#
FROM python:3.11-slim-bookworm AS dev

# Set environemntal variables
ENV PATH = "${PATH}:/home/poetry/bin"
ENV POETRY_VIRTUALENVS_IN_PROJECT=1

# Install graphviz, git and git lfs
RUN apt-get update && apt-get install -y \
    curl \
    graphviz \
    graphviz-dev \
    git \
    git-lfs

# Install poetry
RUN mkdir -p /home/poetry && \
    curl -sSL https://install.python-poetry.org | POETRY_HOME=/home/poetry python3 - && \
    poetry self add poetry-plugin-up

#
# Multi Stage: Bake Image
#

FROM dev AS bake

# Make working directory
RUN mkdir -p /app

# Only copy necessary files when implemented
COPY . /app

# Set working directory
WORKDIR /app

# Install python dependencies in container
RUN poetry install --without dev,vis

#
# Multi Stage: Runtime Image
#

# Local python is preferred but this image
# has complete system dependencies
FROM python:3.11-slim-bookworm AS runtime

# Copy over baked environment
COPY --from=bake /app /app

# Set 
WORKDIR /app

# Set executables in PATH
ENV PATH="/app/.venv/bin:$PATH"

# TODO: Add a command to start a FastAPI service
# ENTRYPOINT
