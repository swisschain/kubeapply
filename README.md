# kubeapply
Apply all changed in commit to kunernetes
# example of usage in pipeline
```
name: Deploy test

on:
  push:
    branches: [ master ]
#    paths:
#    - 'Lykke-Jobs-Mailerlite/**'
#    - 'Lykke-Service-Mailerlite/**'

jobs:
  deploy:
    name: deploy
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
      with:
        fetch-depth: 0
#    - uses: actions/checkout@v2
    - name: deploy
      uses: swisschain/kubeapply@master
      env:
        KUBE_CONFIG_DATA: ${{ secrets.LYKKE_TEST_KUBE_CONFIG_DATA }}
```

