import os

from flask import Blueprint, jsonify

ping_blueprint = Blueprint("ping", __name__)


@ping_blueprint.route("/", methods=["GET"], strict_slashes=False)
def ping():
    return jsonify(
        {"status": "success", "message": "pong!", "container_id": os.uname()[1]}
    )
