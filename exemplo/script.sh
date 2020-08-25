#!/usr/bin/env bash
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
sleep 5
