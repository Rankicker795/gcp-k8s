import os
from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/")
def hello():
    # Fetch the Pod Name from environment variables (set by K8s usually)
    # or default to "Localhost" if running locally.
    pod_name = os.getenv("HOSTNAME", "Localhost")

    return jsonify(
        {
            "message": "Hello from Google Kubernetes Engine!",
            "status": "success",
            "pod_name": pod_name,
            "version": "v1.0.0",
        }
    )


if __name__ == "__main__":
    # This block is only run for local testing, not in the container
    app.run(host="0.0.0.0", port=8080, debug=True)
