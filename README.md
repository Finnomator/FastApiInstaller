# FastApiInstaller

Set up your FastAPI server with a virtual environment and a systemd service within a minute.

## Usage

0. (Optional) Use this repository as a template.
1. Update `config.conf` with your desired service name and description.

### Using the Installer (Recommended)

2. Run `install.sh`:
    - Enter the network port for the FastAPI server.
    - Choose whether to create a systemd service file to automatically start the server on system reboot (requires root
      privileges).:
        - Select if you would like to start the service immediately.
        - You can always start the service later.

### Manual Setup

(Manual setup is not the primary purpose of this repository.)

2. (Optional) Set up and activate a virtual environment.
3. Install the required dependencies: `pip3 install -r requirements.txt`.
4. Choose **one** of the following methods to start the server:
    - Run `start_server.sh`, ensuring `$PORT` is defined beforehand.
    - Execute `fastapi run`.
