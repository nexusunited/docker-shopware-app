FROM nexusnetsoft/shopware-app:7.4
MAINTAINER Nexus Netsoft

RUN apt-get update \
 && apt-get install -y rsync pcov

# Install VueJs Componente
RUN curl -sL https://deb.nodesource.com/setup_13.x -o nodesource_setup.sh && bash nodesource_setup.sh && apt-get -y --force-yes install nodejs
RUN npm install
RUN rm -rf nodesource_setup.sh
RUN npm install vue babel lint @vue/cli
RUN npm install @vue/cli-service
RUN npm install @vue/cli-service-global
RUN npm install @vue/cli-plugin-babel
RUN npm install @vue/cli-plugin-eslint
RUN npm install vue-template-compiler
RUN npm install axios
RUN npm install vue-notifications
RUN npm install mini-toastr
RUN npm install lodash
RUN npm install acorn-jsx
RUN npm install esquery
RUN cp -Rf /var/www/html/node_modules /root/ /var/www/

RUN usermod -g www-data root
