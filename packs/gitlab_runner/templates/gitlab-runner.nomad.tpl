job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .gitlab_runner.datacenters | toStringList ]]
  type = "service"

  group "runner" {
    count = [[ .gitlab_runner.count ]]
    }


    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "runner" {
      driver = "docker"

      config {
        image = "gitlab/gitlab-runner:latest"
      }
    }
  }
}
