from os import environ
from flask import Blueprint, current_app, jsonify

config_blueprint = Blueprint("config", __name__)


@config_blueprint.route("/video-host", methods=["GET"], strict_slashes=False)
def video_host():
    return jsonify(
        {
            "url": environ.get("MENTOR_VIDEO_HOST")
            or current_app.config["MENTOR_VIDEO_HOST"]
        }
    )
