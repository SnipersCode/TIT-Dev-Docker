import os
import re
import json
import sys
import random
import string
import uuid


def init():
    dynamics = ["mongo_uri", "redirect_uri",
                "oauth2_authorize_url", "oauth2_client_id", "oauth2_client_secret", "oauth2_logout_redirect",
                "oauth2_token_url", "oauth2_user_json_url", "oauth2_redirect_uri"]
    config_dict = {
        "dashboard_url": ""
    }
    # Start replacing
    replace_pattern = re.compile("(<<(.*)>>)")
    file_list = next(os.walk("templates"))[2]
    for template_file in file_list:
        # Start creating files
        with open(os.path.join("templates", template_file), "r") as input_file:
            for line in input_file:
                regex_result = re.findall(replace_pattern, line)
                if regex_result and regex_result[0][1] not in dynamics:
                    config_dict[regex_result[0][1]] = ""

    with open("unified_config.json", "w") as output_file:
        json.dump(config_dict, output_file, sort_keys=True, indent=4, separators=(',', ': '))


def build():
    # Read unified config
    with open("unified_config.json", "r") as unified_config_file:
        unified_config = json.load(unified_config_file)
    # Dynamic settings
    unified_config["mongo_uri"] = "mongodb://dashboard:{0}@titdev_database/dashboard".format(
            unified_config["random_password"])

    unified_config["oauth2_authorize_url"] = "{0}/oauth/authorize".format(unified_config["dashboard_url"])
    unified_config["oauth2_client_id"] = "id_" + str(uuid.uuid1()).replace("-", "")
    unified_config["oauth2_client_secret"] = ''.join(random.SystemRandom().choice(
            string.ascii_uppercase + string.digits) for _ in range(24))
    unified_config["oauth2_logout_redirect"] = "{0}/auth/log_out".format(unified_config["dashboard_url"])
    unified_config["oauth2_token_url"] = "{0}/oauth/token".format(unified_config["dashboard_url"])
    unified_config["oauth2_user_json_url"] = "{0}/api/user/me".format(unified_config["dashboard_url"])
    unified_config["oauth2_redirect_uri"] = "{0}/auth/oauth2_basic/callback".format(unified_config["forum_url"])

    unified_config["redirect_uri"] = "{0}/auth/sso_endpoint".format(unified_config["dashboard_url"])

    # Check for output folders
    if not os.path.exists("settings"):
        os.makedirs("settings")
    if not os.path.exists(os.path.join("nginx", "conf.d")):
        os.makedirs(os.path.join("nginx", "conf.d"))

    # Start replacing
    replace_pattern = re.compile("(<<(.*)>>)")
    file_list = next(os.walk("templates"))[2]
    for template_file in file_list:
        # Determine output locations
        if template_file == "base.json":
            output_folder = "dashboard"
        elif template_file in ["admin_add.txt", "users_add.txt"]:
            output_folder = "database"
        elif template_file == "default.conf":
            output_folder = os.path.join("nginx", "conf.d")
        elif template_file == "murmur.ini":
            output_folder = "murmur"
        elif template_file == "mumo.ini":
            output_folder = "mumo"
        else:
            output_folder = "settings"

        # Start creating files
        with open(os.path.join("templates", template_file), "r") as input_file, open(
                os.path.join(output_folder, template_file), "w") as output_file:
            for line in input_file:
                regex_result = re.findall(replace_pattern, line)
                if regex_result:
                    output_file.write(line.replace(regex_result[0][0], str(unified_config[regex_result[0][1]])))
                else:
                    output_file.write(line)


def maintenance(setting):
    if setting:
        os.environ["maintenance"] = "True"
    else:
        del os.environ["maintenance"]


if __name__ == "__main__":
    valid = True
    if len(sys.argv) > 1:
        if sys.argv[1].strip() == "init":
            init()
        elif sys.argv[1].strip() == "build":
            build()
        elif sys.argv[1].strip() == "maintenance":
            if sys.argv[2].strip() == "on":
                maintenance(True)
            elif sys.argv[2].strip() == "off":
                maintenance(False)
            else:
                valid = False
        else:
            valid = False
    else:
        valid = False

    if not valid:
        print("Did not supply a valid command.")
