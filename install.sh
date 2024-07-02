#Install Docker
apt-get update
apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Create docker volumes
docker volume create portainer_vol
docker volume create postgres_vol
# docker volume create clickhouse_vol

# Create docker network
docker network create app_net

# Run container for Portainer
docker run -d \
  --name portainer \
  --net=app_net \
  -p 9000:9000 \
  -v portainer_vol:/data \
  portainer/portainer

# Run container for Portainer agent
docker run -d \
  --name portainer_agent \
  --net=app_net \
  -p 9001:9001 \
  -v portainer_vol:/data \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/lib/docker/volumes:/var/lib/docker/volumes \
  portainer/agent

# Preference for environment:
# Name: Docker
# Environment address: portainer_agent:9001

# Run container for Postgres
docker run -d \
  --name postgres \
  --net=app_net \
  -e POSTGRES_HOST_AUTH_METHOD=trust \
  -e POSTGRES_USER=postgres_admin \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=test_db \
  -p 5432:5432 \
  -v postgres_vol:/var/lib/postgresql/data \
  postgres

# Run container for Superset
#docker run -d \
#  --name superset \
#  -e "SUPERSET_SECRET_KEY=H0gPQm5MLuFb45ABSv/W1o1kQNBHH9elbjhc515Uqc+C5WgPNidKtzlQ" \
#  -p 8080:8088 \
#  apache/superset \
#docker exec -it superset superset fab create-admin \
#  --username admin \
#  --firstname Superset \
#  --lastname Admin \
#  --email superset@example.com \
#  --password admin
#docker exec -it superset superset db upgrade
## docker exec -it superset superset load_examples
#docker exec -it superset superset init

# Run Superset with docker
git clone https://github.com/apache/superset.git
cd superset
docker compose -f docker-compose-non-dev.yml up

# Run container for clickhouse
# docker run -d \
#  --name clickhouse \
#  --net=app_net \
#  -v clickhouse_vol:/var/lib/clickhouse \
#  clickhouse/clickhouse-server

# Superset-clickhouse
# docker exec superset pip install clickhouse-sqlalchemy
# docker restart superset

# Remove containers
# docker stop portainer
# docker stop postgres
# docker stop superset
# docker stop clickhouse
# docker volume prune
