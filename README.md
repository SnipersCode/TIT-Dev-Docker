# TITDev-Docker
Docker repo for the TIT-Dev Website

## Installation
### Install docker and docker-compose
Docker: https://docs.docker.com/engine/installation/
Docker-Compose: https://docs.docker.com/compose/install/

### Building the docker image
The following instructions assumes your current working directory is the root of this repo.

#### Initial image
Initialize your config file
```
python config.py init
```

Edit your config file with the necessary parameters.
All fields are required, but you won't be able to fill in the discourse_* settings yet.
```
vi unified_config.json
```

Build your compose image with your new config file
```
python config.py build
```

Run the installer
```
sudo ./run_compose.sh
```

#### Integrating with discourse forum
Login to the site, go to the account page, and set your email to the main email listed in the unified config.
```
In browser, go to: unified_config["dashboard_url"]/account
Edit Email: unified_config["main_email"]
```

Go to the forums and log in. It will ask you to create an account. All defaults are ok.
```
In browser, go to: unified_config["forum_url"]
Sign In
Create Account
```

Create an API key
```
In browser, go to: unified_config["forum_url"]/admin/api
Generate Master API Key
```

#### Final image
Copy the API Key into your unified_config.json for the discourse_api_key.\
For the username, use the username with the "_", not the name of your account.
```
vi unified_config.json
{
	"discourse_api_key": "<<example_api>>",
	"discourse_api_username": "<<username>>"
}
```

Rebuild the installer
```
python config.py build
```

Run the installer again
```
sudo ./run_compose.sh
```

**YOU'RE DONE!!! :D**
If you ever want to change the unified_config again, redo the steps for the final image.

## Adding Super Admins
Super admins can only be added by directly connecting to the database.
They cannot be added or removed from the web interface in order to limit who can be super admins

```
sudo docker exec -it titdevdocker_database_1 bash
mongo
use dashboard
db.eve_auth.update({"_id": "super_admin"}, {$push: {"users": "example_site_id"}})
exit
exit
```

## Backing up and restoring the database
I recommend externally backing up the database (following the 3-2-1 rule).
3-2-1 is 3 copies of the data, 2 different devices, 1 off-site.


The default mongo port is exposed on the container, so you should be able to get to it from the dashboard hostname.
Back it up like so:
```
mongodump -h dashboard_hostname -d dashboard -u dashboard -p unified_config["random_password"] -o output_directory
```
Then to restore:
```
mongorestore -h dashboard_hostname -d dashboard -u dashboard -p unified_config["random_password"] --drop output_directory
```

## Useful commands
Watching the outputs of nginx or uwsgi (dashboard)
```
sudo docker attach --sig-proxy=false titdevdocker_nginx_1
sudo docker attach --sig-proxy=false titdevdocker_dashboard_1
```
Viewing the image or running commands on a running container. Ctrl-C to exit. (**Warning:** These don't persist on rebuild)
```
sudo docker exec -it titdevdocker_dashboard_1 bash
sudo docker exec -it titdevdocker_database_1 bash
```
Viewing running containers
```
sudo docker ps
```
Read the docker documentation for more: https://docs.docker.com/