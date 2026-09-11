from flask import Flask, send_file
import requests
from pathlib import Path
import hashlib

app = Flask(__name__)
CACHE_PATH = Path("/var/cache/filecacheserver")

def download_to_cache(url, path):
    response = requests.get(url, timeout=30)
    response.raise_for_status()

    tmp_path = path.with_suffix(".tmp")
    tmp_path.write_bytes(response.content)
    tmp_path.replace(path)

@app.route("/<path:fileurl>")
def index(fileurl):
    CACHE_PATH.mkdir(parents=True, exist_ok=True)
 
    filename = hashlib.sha256(fileurl.encode()).hexdigest()
    fileurl = f"https://{fileurl}"

    path = CACHE_PATH / filename

    try:
        download_to_cache(fileurl, path)
    except:
        if not path.exists():
            return "Bad Gateway", 502

    return send_file(path, download_name=Path(fileurl).name)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=True)
