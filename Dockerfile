FROM alpine:edge
MAINTAINER gup <1725763838@qq.com>

RUN apk update && \  
        apk upgrade && \  
        apk add --update bash jq git openssh && \  
    wget -c http://gosspublic.alicdn.com/ossutil/1.6.7/ossutil32 && \  
        mkdir -p /util_modules && \  
        mv ossutil32 /util_modules && \  
		chmod 777 /util_modules/ossutil32  
        
COPY ./assets/* /opt/resource/
RUN chmod 777 -R /opt/resource
