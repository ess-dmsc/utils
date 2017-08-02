# docker-metrics-env

A local Graphite and Grafana Docker setup for development and testing.


## Instructions

Start a swarm with

    $ docker swarm init

and deploy the stack by running

    $ docker stack deploy -c docker-compose.yml <name>

substituting `<name>` by a name for the stack. You can remove the stack with

    $ docker stack rm <name>

and leave the swarm with

    $ docker swarm leave --force
