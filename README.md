# TITDev-Docker
Docker repo for the TIT-Dev Website

## Installation
### Install docker and docker-compose

Docker: https://docs.docker.com/engine/installation/

Docker-Compose: https://docs.docker.com/compose/install/

### Clone this repo (Duh)

```
git clone https://github.com/tritanium-industries/TITDev-Docker.git
```

### Building the docker image
The following instructions assumes your current working directory is the root of this repo.

All references to "python" in the instructions below should be your python alias (ex. python3 on ubuntu 15.4)

#### Initial image
Initialize your config file

```
python config.py init
```

Edit your config file with the necessary parameters. Use your favorite text editor to do so. I'm an oldie so I use vi.

All fields are required, but you won't be able to fill in the discourse_* settings just yet.

```
vi unified_config.json
```

Build your compose image with your new config file

```
python config.py build
```

Run the installer. This takes a LONG time. Go get a coffee or something.

```
sudo ./run_compose.sh
```

#### Initializing Murmur (Mumble Server)
You can either initialize murmur with your own sqlite database, or with the super minimal database given. 

If you are using your own sqlite database, copy it to the backups directory and replace the initial_murmur.sqlite file in the following command with your own.

```
sudo ./backups.sh init murmur initial_murmur.sqlite
```

**Note:** If you use your own murmur database, you'll also have to change the "not_authed_channel" setting in AuthSticky.ini.

Set it to the id of the channel you want to stick not authenticated users to. AuthSticky.ini is in the mumo folder.

Changes to the AuthSticky.ini will not appear to do anything until you rerun the installer.

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

#### Locking down your forum
Because there is no possible way to upload custom css on discourse build, you'll have to do it through the admin console.

This custom css prevents users from editing their email from the forums. 
If users change their email through the forums, they will lose the account association with the dashboard.

**Warning:** Do NOT uncheck the "email editable" option in discourse.
This will prevent the dashboard from changing their email if they change it from the dashboard.

In the admin panel > Customise > CSS/HTML (unified_config["forum_url"]/admin/customise/css_html):

New, Name it: Remove email edit, copy the following CSS,

```
div.user-preferences div.pref-email div.controls a {
  display: none;
}
```

check enabled, and save.

#### Final image
Copy the API Key into your unified_config.json for the discourse_api_key.

For the username, use the username with the "_", not the name of your account.

```
vi unified_config.json
{
    ...
	"discourse_api_key": "<<example_api>>",
	"discourse_api_username": "<<username>>",
	...
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
sudo docker exec -it titdev-database bash
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

If you just want to backup the entire data container, which will also backup your murmur database, run:

```
sudo ./backups.sh backup all current_date
```

You can also make individual backups of specific containers:

```
sudo ./backups.sh backup murmur current_date
```

When you want to restore (your list of backups are in the backups directory):

**Warning:** This will remove all files in the data directory (all applicable data) and replace it with the data in the backup.

```
sudo ./backups.sh restore all previous_date
```

As long as you are familiar with bash commands, you should also be able to restore individual folders. Ex:

```
sudo ./backups.sh restore murmur previous_date
```

## Useful commands

Viewing running containers and get their names (last parameter in the lines printed).

```
sudo docker ps
```

Watching the outputs of nginx or uwsgi (dashboard). Ctrl-C to exit.

**Note:** Because sig-proxy is false, Ctrl-C will not stop the process running in the container.

```
sudo docker attach --sig-proxy=false container_name
```

Viewing the image or running commands on a running container. Ctrl-C to exit.

**Warning:** Any changes made to the container this way will be lost when rebuilding the container.

```
sudo docker exec -it container_name bash
```

Read the docker documentation for more: https://docs.docker.com/