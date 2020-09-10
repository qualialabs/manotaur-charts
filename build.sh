#!/bin/bash

set -e

helm repo add stable https://kubernetes-charts.storage.googleapis.com

changes=false

mkdir -p charts

sha_root=$(git log --pretty=oneline . | head -n 1 | awk '{print $1}')

for chart in $(ls src); do
  echo "Checking $chart"

  sha_chart=$(git log --pretty=oneline src/$chart/ | head -n 1 | awk '{print $1}')


  if [[ "$sha_chart" == "$sha_root" ]]; then
    echo "Changes"

    helm dependency update ./src/$chart
    helm package -d charts ./src/$chart
    changes=true
  else
    echo "No changes"
  fi
done


if $changes ; then
  git fetch --all

  git checkout gh-pages
  cp charts/index.yaml .
  git checkout master

  helm repo index --url https://razvvan.github.io/manotaur-charts/ --merge index.yaml .


  git checkout gh-pages
  mv index.yaml charts/
  git add charts/
  git commit -m "Chart updates"
  git push
fi


