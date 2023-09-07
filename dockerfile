# Import docker file
FROM osrm/osrm-backend

# Define variables
# country data
ARG DOWNLOAD_URL=http://download.geofabrik.de/south-america/guyana-latest.osm.pbf
ARG OSM_FILE=guyana-latest.osm.pbf
ARG OSRM_FILE=guyana-latest.osrm

# Transform variables
ENV OSM_FILE=$OSM_FILE
ENV OSRM_FILE=$OSRM_FILE
ENV DOWNLOAD_URL=$DOWNLOAD_URL

# Install wget
RUN echo "deb http://archive.debian.org/debian stretch main contrib non-free" > /etc/apt/sources.list
RUN apt-get update && apt-get install -y wget

# Create directory for data (this will be a volume)
VOLUME /data

# Download data
WORKDIR /data
RUN wget $DOWNLOAD_URL -O $OSM_FILE

# Extract the osm file
RUN osrm-extract -p /opt/car.lua $OSM_FILE

# Delete the osm file
RUN rm $OSM_FILE

# Create other formats
RUN osrm-partition $OSRM_FILE && osrm-customize $OSRM_FILE

# Start the Docker
CMD osrm-routed --algorithm mld $OSRM_FILE

# Expose port
EXPOSE 5000
