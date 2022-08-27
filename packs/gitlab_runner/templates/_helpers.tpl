// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .gitlab_runner.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .gitlab_runner.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .gitlab_runner.region "") -]]
region = [[ .gitlab_runner.region | quote]]
[[- end -]]
[[- end -]]
