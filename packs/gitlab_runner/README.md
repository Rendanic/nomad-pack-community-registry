# gitlab Runner

This pack starts a configured gitlab Runner.


## Variables

- `message` (string) - The message your application will respond with
- `count` (number) - The number of app instances to deploy
- `job_name` (string) - The name to use as the job name which overrides using the pack name
- `datacenters` (list of strings) - A list of datacenters in the region which are eligible for task placement
- `region` (string) - The region where jobs will be deployed
- `runner_token` (string) - gitlab Runner Token
- `runner_url` (string) - gitlab URL for Runner
