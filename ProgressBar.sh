#!/usr/bin/env bash
#/**
# * @link      https://github.com/robsonalexandre/progressbar
# * @license   https://www.gnu.org/licenses/gpl-3.0.txt GNU GENERAL PUBLIC LICENSE
# * @author    Robson Alexandre <alexandrerobson@gmail.com>
# */

ProgressBar.usage() {
  printf '%s\n  ProgressBar.sh [-s|--speed fast|normal|slow|slowest|zero] [-t|--total NUM] [-i|--initial NUM]\n' "$*" >&2
}

ProgressBar.init() {
  #/**
  # * lib array
  # */
  in_array() {
    local needle haystack
    printf -v haystack '%s|' "${@:2}"
    [[ $1 == @(${haystack%|}) ]]
  }

  #/**
  # * lib parsing arguments
  # */
  checkArgType() {
    # valor de um parâmetro (arg: 3) não pode começar com - 'hifen'
    if [[ -z $3 || "$3" =~ ^- ]]; then
      echo "Opção $2 requer parâmetro." >&2
      return 1
    fi
    case $1 in
      bool) re='^(on|off|true|false|1|0)$';;
      string) re='^[[:print:]]+$';;
      int) re='^[-+]?[[:digit:]]+$';;
      float) re='^[-+]?[0-9]+([.,][0-9]+)?$';;
    esac
    [[ ${3,,} =~ $re ]]
  }

  #/**
  # * ProgressBar
  # * estilo apt upgrade
  # * Progress: [ 60%] [#####################..............................]
  # * estilo wget
  # * linux-4.15.18.tar.xz  45%[============>        ] 44,18M 5,97MB/s eta 7s
  # */
  ProgressBar.print() {
    local partial=$1 \
          total=${2:-100} \
          msg=${3:-Progress:} \
          cols offset p percento pad bar_on bar_off

    cols=$(tput cols)
    p=$((partial*100/total))
    percento=$((p>100?100:p))
    offset=$((cols-${#msg}-10))

    printf -v pad '%*s' $((percento*offset/total))
    bar_on=${pad// /$bar_char_on}
    printf -v pad '%*s' $((offset-${#bar_on}))
    bar_off=${pad// /$bar_char_off}

    printf "$bar_format" "$msg" $percento $bar_on $bar_off
  }

  ProgressBar.run() {
    local msg
    declare -i nivel=${initial:-0}
    tput civis

    while :; do
      if [[ $forward != 'zero' ]]; then
        nivel=$(((++i%${forward:-$bar_forward_default})?nivel:nivel+1))
      fi

      ProgressBar.readFromStdin || break
      read -a REPLY -t .001 -u 3
      # [[ $? != 142 ]] # read timeout
      str="${REPLY[*]}"
      if [[ $REPLY =~ ^[0-9]+$ ]]; then
        nivel=$REPLY
        str="${REPLY[@]:1}"
      fi
      msg="${str:-$msg}"

#      ProgressBar.checkProcess && break
      #   Se processo em bg concluir, ou
      #     não tiver processo em bg e nivel chegar a 100,
      #     termina barra de progresso
      ps -p ${main_pid:-1} > /dev/null 2>&1 || break

      ProgressBar.print "$nivel" "$total" "$msg"
    done
  }
  ProgressBar.cleanup() {
    tput el
    echo -e "Concluído [100%]"
    tput cnorm
    [ -d "$tmp" ] && rm -fr $tmp
  }
  trap ProgressBar.cleanup EXIT KILL

  ProgressBar.setProgress() {
    [ $# -gt 0 ] && echo $@ >&3
  }
  export -f ProgressBar.setProgress

  ProgressBar.readFromStdin() {
    read -t .001
    [[ $? == 1 ]] && return 1
    [[ $REPLY ]] && ProgressBar.setProgress "$REPLY"
    return 0
  }

  shopt -s extglob
  tmp=$(mktemp -d)
  fifo=$(mktemp -u --tmpdir=$tmp)
  mkfifo $fifo
  exec 3<>$fifo

  total=100
  bar_char_on='#'
  bar_char_off='.'
  bar_progress_color='\e[37;1m'              # fg=Negrito Branco; bg=
  bar_text_color='\e[0;30m\e[42m'            # fg=Preto; bg=Verde
  normal_color='\e[0m'
  bar_format="${bar_text_color}%s [%3d%%]${normal_color} ${bar_progress_color}[%s%s]${normal_color}\r"
  bar_forward_default=1000
  declare -A speed=(
    [fast]=20
    [normal]=200
    [slow]=1000
    [slowest]=2000
    [zero]=zero
  )
  while [[ $1 ]]; do
    case $1 in
      -z)
        forward=zero
        shift
        ;;
      -s|--speed)
        checkArgType string $1 $2 || { ProgressBar.usage; return 1; }
        if in_array $2 ${!speed[@]}; then
          forward=${speed[$2]}
        fi
        shift 2
        ;;
      -i|--initial)
        checkArgType string $1 $2 || { ProgressBar.usage; return 1; }
        initial=$2
        shift 2
        ;;
      -t|--total)
        checkArgType string $1 $2 || { ProgressBar.usage; return 1; }
        total=$2
        shift 2
        ;;
      -h|--help|-\?)
        ProgressBar.usage; return 1;
        ;;
      *)
        if [[ $1 =~ ^- ]]; then
          ProgressBar.usage "Opção $1 desconhecida (?)"; return 1;
        fi
        args[${#args[@]}]=$1
        shift
    esac
  done
  if [ ${#args[@]} -gt 0 ]; then
    if [ -f "$args" ]; then
      bash "$args" &
    else
      bash -c "${args[*]}" &
    fi
    main_pid=$!
  fi
  [ -r .progressbarrc ] && source .progressbarrc
}

ProgressBar.main() {
  ProgressBar.init "$@"
  ProgressBar.run
}
[[ ${BASH_SOURCE[0]} == $0 ]] && ProgressBar.main "$@"
