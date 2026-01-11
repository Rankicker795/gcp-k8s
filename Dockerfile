# Use a lightweight Python base image to keep build times fast
FROM python:3.11-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file first to leverage Docker layer caching
# (If requirements don't change, Docker skips this step on re-builds)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose port 80 to allow traffic
EXPOSE 80

# Command to run the app using Gunicorn
# -w 2: Use 2 worker processes
# -b :80: Bind to port 80
CMD ["gunicorn", "-w", "2", "-b", ":80", "app:app"]
