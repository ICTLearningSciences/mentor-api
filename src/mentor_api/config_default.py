# This software is Copyright ©️ 2020 The University of Southern California. All Rights Reserved.
# Permission to use, copy, modify, and distribute this software and its documentation for educational, research and non-profit purposes, without fee, and without a written agreement is hereby granted, provided that the above copyright notice and subject to the full license file found in the root of this software deliverable. Permission to make commercial use of this software may be obtained by contacting:  USC Stevens Center for Innovation University of Southern California 1150 S. Olive Street, Suite 2300, Los Angeles, CA 90115, USA Email: accounting@stevens.usc.edu
#
# The full terms of this copyright and license should always be found in the root directory of this software deliverable as "license.txt" and if these terms are not found with this software, please contact the USC Stevens Center for the full license.
import os
from pathlib import Path


class Config(object):
    SECRET_KEY = (
        os.environ.get("SECRET_KEY") or "production_servers_must_provide_a_secret_key"
    )
    CLASSIFIER_ARCH = os.environ.get("CLASSIFIER_ARCH")
    CLASSIFIER_CHECKPOINT = os.environ.get("CLASSIFIER_CHECKPOINT") or os.environ.get(
        "CHECKPOINT"
    )
    CLASSIFIER_CHECKPOINT_ROOT = os.environ.get("CLASSIFIER_CHECKPOINT_ROOT") or str(
        Path("/app/checkpoint")
    )
    # override with a list of ids for mentors
    # that should preload with the server
    MENTOR_IDS_PRELOAD = []
    MENTOR_DATA_ROOT = os.environ.get("MENTOR_DATA_ROOT") or str(Path("/app/mentors"))
    MENTOR_VIDEO_HOST = (
        os.environ.get("MENTOR_VIDEO_HOST") or "https://video.mentorpal.org"
    )
