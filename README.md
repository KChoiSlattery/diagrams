# diagrams

For making diagrams using LaTeX, Photoshop, and Blender

## Usage

Build the Docker image:

```sh
docker compose build
```

Start the Docker-compose service:

```sh
docker compose up -d
```

Connect to running service and use shell:

```sh
docker compose exec env sh
```

Build Equation Images

```sh
./build.sh quantum/template.tex quantum/eq.tex quantum/eq
```

Close the shell: `ctrl-d`

Shut down Docker-compose services

```sh
docker compose down
```
