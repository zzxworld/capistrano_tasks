namespace :rbenv do
  desc "Setup the rbenv-vars for application"
  task :setup do
    content ="RAILS_ENV=production\n"
    rbenv_vars_file = "#{shared_path}/.rbenv-vars"

    run_locally do
      secret_key = capture "rails secret"
      content << "SECRET_KEY_BASE=#{secret_key}\n"
    end

    on roles(:app) do
      if test "[[ ! -f #{rbenv_vars_file} ]]"
        upload!(StringIO.new(content), rbenv_vars_file)
      end
    end
  end
end
