# ProgressBar v2.0.2

## Sobre
Script em shell que exibe o progresso da execução de um script principal
ou uma lista de comandos em uma barra de progresso.
A barra de progresso é atualizada com mensagens definidas e o percentual do total.

## Modo de Uso
Existem x modos de uso:

`ProgressBar.setProgress [(int) parcial(%)] [(int) total] [(string) Mensagem exibida]`

![ProgressBar](img/progressbar.gif)

1. Importando-o dentro do script principal (main) e chamando o método run, o script principal será monitorado pela variável PID

```bash
source ProgressBar.sh
ProgressBar.init --initial 0 --total 100 --speed slow

declare -a commands=(
  "7 Atualizando sistema"
  "12 Executando Comando 1"
  "18 Verificando dependências (Comando 2)"
  "23 Atualizando Comando 3"
  "33 Configurando os pacotes instalados"
  "37 Executando Comandos 4,5,etc..."
  "49"
  "66"
  "Executando cleanup primeira etapa"
  "Executando cleanup segunda etapa"
  "Executando cleanup terceira etapa"
  "72 Removendo arquivos temporários"
  "86 Finalizando o script principal"
)

sleep 5
for pg in "${commands[@]}"; do
  ProgressBar.setProgress "$pg"
  sleep $((RANDOM%10))
done
```

2. Chamando a progressbar e passando o script como parâmetro

```bash
ProgressBar.sh exemplo/script.sh
```

3. Chamando a progressbar e passando como parâmetro, uma lista de comandos

```bash
ProgressBar.sh 'sleep 3; setprogress "8 Executando Comando 1"; sleep 5; setprogress 86 Finalizando...; sleep 5'
```

## Função ProgressBar

A função __ProgressBar()__ utiliza tput e printf para criar uma barra de progresso preenchendo toda a largura do terminal que executa e roda com os seguintes parâmetros:

`ProgressBar.sh [-i|--initial NUM] [-t|--total NUM] [-s|--speed fast|normal|slow|slowest|zero] [-z]`

Caso as variáveis **total** e **mensagem** estejam indefinidas, assumem os valores **total=100** e **msg=Progress**
