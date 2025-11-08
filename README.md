# Скрипты для установки сервисов

Все скприты рекомендуется запускать от пользователя `root`


### Устанвока Master ноды в Kubernetes
```bash	
bash <(curl -sSL https://raw.githubusercontent.com/danteriz/scrips_service/master/scripts/install_master_node.sh?$(date +%s)")
```

### Устанвока Worker ноды в Kubernetes
```bash	
bash <(curl -sSL https://raw.githubusercontent.com/danteriz/scrips_service/master/scripts/install_worker_node.sh?$(date +%s)")
```

### Базовая настрйока SSH на ВМ 
```bash	
bash <(curl -sSL https://raw.githubusercontent.com/danteriz/scrips_service/master/scripts/ssh.sh?$(date +%s)")
```
