namespace :nginx do
  desc "Setup the nginx conf file for application"
  task :setup do
    conf_template = <<-EOF
upstream <%= fetch(:application) %>_puma {
    server unix:/<%= shared_path %>/tmp/sockets/puma.sock fail_timeout=0;
}

server {
    server_name <%= fetch(:domain, 'localhost') %>;
    client_max_body_size 10M;
    keepalive_timeout 5;
    root <%= current_path %>/public;
    try_files $uri/index.html $uri.html $uri @<%= fetch(:application) %>_app;

    location @<%= fetch(:application) %>_app {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_pass http://<%= fetch(:application) %>_puma;
    }

    error_page 500 502 504 /500.html;
    location = /500.html {
        root <%= current_path %>/public;
    }

    if (-f $document_root/system/maintenance.html) {
        return 503;
    }

    error_page 503 @maintenance;
    location @maintenance {
        rewrite  ^(.*)$  /system/maintenance.html break;
    }

    location ^~ /assets/ {
        expires max;
        add_header Cache-Control public;
    }
}
    EOF

    conf_file = "#{shared_path}/nginx.conf"
    content = ERB.new(conf_template).result()

    on roles(:web) do
      if test "[[ ! -f #{conf_file} ]]"
        upload!(StringIO.new(content), conf_file)
      end
    end
  end
end
