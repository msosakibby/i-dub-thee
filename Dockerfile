# Use a highly secure, minimal Python 3.11 image
FROM python:3.11-slim

# Prevent Python from writing pyc files and enforce unbuffered stdout for logging
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Establish the secure working directory
WORKDIR /app

# Copy dependency ledger and install mathematically locked versions
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the physical codebase and the legal rules ledger
COPY src/ /app/src/
COPY rules/ /app/rules/

# Default CMD (Layer 1 Service). Will be overridden by Layer 2 Job.
CMD exec uvicorn src.main:app --host 0.0.0.0 --port ${PORT:-8080}
