# KJSL build everything in Docker...

#!/bin/bash

# Kev's build script
HERE=$PWD

IMAGE_STATE=$(docker images -q kjsl_ffmpeg_build:latest 2> /dev/null)
RUN_STATE=$(docker ps -qf "ancestor=kjsl_ffmpeg_build")

whack_docker_image() {
  if [[ "$RUN_STATE" != "" ]]; then
    docker stop $RUN_STATE
  fi
  RUN_STATE=
  if [[ "$IMAGE_STATE" != "" ]]; then
    docker image rm -f $IMAGE_STATE
  fi
  IMAGE_STATE=
}

create_docker_image () {
  if [[ "$IMAGE_STATE" == "" ]]; then
    docker build -t kjsl_ffmpeg_build .
  fi
}

run_docker_container () {
  if [[ "$RUN_STATE" == "" ]]; then
    echo "Spinning up new Kev's FFmpeg build container"
    docker run -i --rm --name kjsl_ffmpeg_build --cap-add sys_ptrace -p127.0.0.1:2222:22 -d -v "$HERE:/host" kjsl_ffmpeg_build
    sleep 2

    # update running state image id to be the newly created Docker container
    RUN_STATE=$(docker ps -qf "ancestor=kjsl_ffmpeg_build")

    ssh-keygen -f "$HOME/.ssh/known_hosts" -R [localhost]:2222
  fi

  echo "Rejoining Kev's FFmpeg build container $RUN_STATE"
  docker exec -i -t "$RUN_STATE" /bin/bash
}

#whack_docker_image
create_docker_image
run_docker_container