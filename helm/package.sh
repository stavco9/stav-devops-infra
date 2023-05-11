CURR_BRANCH=$(git rev-parse --abbrev-ref HEAD)
git checkout helm-repo

echo "Packaging chart"
docker run --rm --volume "$(pwd)/flask-sample-app/helm-chart:/helm-docs" -u $(id -u) jnorwood/helm-docs:latest
helm package flask-sample-app/helm-chart
git add flask-sample-app/*

echo "Indexing"
helm repo index --url https://stavco9.github.io/stav-devops-infra/helm/ .

git add index.yaml
git add *.tgz 
git commit -m "Updating helm chart"
git push origin helm-repo

git checkout $CURR_BRANCH