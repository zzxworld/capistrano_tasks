namespace :backup do
  def download(file)
    if test "[[ -f #{file} ]]"
      system "scp " \
        "user@#{host}:~/#{file} " \
        "/local_backup_path/#{file}"
      execute :rm, file
    end
  end

  desc "Backup config files"
  task :config do
    config_file = 'config.tar.gz'
    on roles(:app) do |host|
      execute :tar,
        "zcf #{config_file} " \
        "-C #{shared_path} " \
        "nginx.conf " \
        '.rbenv-vars'
      download config_file
    end
  end

  desc "Backup database"
  task :db do
    db_file = 'database.sql.gz'
    ask :password, "password"
    on roles(:db) do |host|
      execute :mysqldump,
        "-umysql_user -p#{fetch(:password)} " \
        "db_name | gzip > #{db_file}"
      download db_file
    end
  end

  desc "Backup upload files"
  task :uploads do
    uploads_file = 'uploads.tar.gz'
    on roles(:app) do |host|
      execute :tar,
        "zcf #{uploads_file} " \
        "-C #{shared_path}/public " \
        "uploads "
      download uploads_file
    end
  end
end

desc "Backup from server"
task :backup do
  invoke 'backup:db'
  invoke 'backup:config'
end
