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


## Testing the setup

You can send metrics to Graphite by running

    $ echo "<metric_name> <value> `date +%s`" | nc -c 127.0.0.1 2003

where `<metric_name>` and `<value>` must be substituted. The Graphite web
interface can be accessed at *localhost:80*.
