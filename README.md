# `k3s deploy`

My deployment script for k3s.

See `local-config.sh.in` for configuration settings.

## Usage

1) Clone repo

    git clone https://github.com/exafi/k3s-stack.git

2) Customize for personal use

    cd k3s-stack
    cp local-config.sh.in local-config.sh
    nano local-config.sh
    git checkout -b local
    git add -f local-config.sh
    git commit -m "Add local config"
    gh repo create --private k3s-stack --push --source .
    git remote add upstream https://github.com/exafi/k3s-stack.git
    git branch local -u origin/local
    git branch main -u upstream/main

3) Deploy

    bash deploy.sh

4) Incorporate upstream changes

    git fetch upstream
    git checkout main
    git pull --ff-only
    git checkout local
    git merge main
    # check release notes to ensure this is safe on an existing cluster.
    # bash deploy.sh

## License

See [LICENSE](./LICENSE) file.
