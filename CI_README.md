CI/CD setup (GitHub Actions)

This repository now includes a GitHub Actions workflow that will deploy to your EC2 server whenever you push to `main`.

What the workflow does
- Checks out the repo
- Rsyncs the repository to `/home/<SSH_USER>/time_manager_full` on the EC2 host
- SSHes to the host and runs `docker-compose down` followed by `docker-compose up -d --build`

Required GitHub Secrets
- SSH_HOST: public IP or DNS of your EC2 host (e.g., 13.60.187.152)
- SSH_USER: SSH username (e.g., ec2-user)
- SSH_KEY: The private key contents (PEM) — set as a GitHub secret value
- SSH_PORT: optional, default 22

How to set up
1) In your GitHub repo, go to Settings -> Secrets -> Actions -> New repository secret and add the values above.
   - Paste the full content of `/home/hadeed/Downloads/TM_key_pair.pem` as the `SSH_KEY` secret.
2) Push to the `main` branch. The workflow will run and deploy the changes to the server.

Notes and security
- The action uses rsync and will overwrite files on the remote path. Be careful with local-only files you don't want overwritten.
- Keep your SSH key secret. Consider creating a dedicated deploy user on the EC2 host with limited privileges.
- For better security, consider using a GitHub deploy key or a more advanced strategy (pull-based deploy or using a CI runner within your VPC).

Troubleshooting
- If the workflow fails, check the Actions tab for logs. Common issues: wrong key format, wrong remote path, insufficient permissions to run docker-compose.
- Ensure `/usr/local/bin/docker-compose` exists and is executable on the remote host.

