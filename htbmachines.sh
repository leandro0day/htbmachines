#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function crtl_c(){
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm && exit 1
}

# Ctrl+C
trap crtl_c INT 

# Variables globales
 main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
  echo -e "\n${yellowColour} [+]${endColour} ${grayColour}uso:${endColour}"
  echo -e "\t${purpleColour} u)${endColour} ${grayColour}Decargar o actualizar archivos necesario ${endColour}"
  echo -e "\t${purpleColour} a)${endColour} ${grayColour}Listar todas las maquinas ${endColour}"
  echo -e "\t${purpleColour} m)${endColour} ${grayColour}Buscar por un nombre de maquina ${endColour}"
  echo -e "\t${purpleColour} i)${endColour} ${grayColour}Buscar por direccion IP${endColour}"
  echo -e "\t${purpleColour} d)${endColour} ${grayColour}Buscar por dificultad de la maquina${endColour}"
  echo -e "\t${purpleColour} o)${endColour} ${grayColour}Buscar por sistema operativo${endColour}"
  echo -e "\t${purpleColour} s)${endColour} ${grayColour}Buscar por skills${endColour}"
  echo -e "\t${purpleColour} y)${endColour} ${grayColour}Obtener link de la resolucion de la maquina en youtube${endColour}"
  echo -e "\t${purpleColour} h)${endColour} ${grayColour}Mostrar este panel de ayuda${endColour} \n"
}

function updateFiles(){

  if [ ! -f bundle.js ]; then
    tput civis
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour} Descargando archivos necesarios...${endColour}"
    curl -s  GET $main_url | js-beautify > bundle.js
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour} Todos los archivos han sido descargados${endColour}"
    tput cnorm

  else
    tput civis 
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour} Comprobando si hay actualizaciones pendientes...${endColour}"
    curl -s $main_url | js-beautify > bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}') 
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')

    if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour} No se han detectado actualizaciones, lo tines todo al dia ;)${endColour}"
      rm bundle_temp.js

    else
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour} Se han encontrado actualizaciones disponibles${endColour}"
      sleep 1
      rm bundle.js && mv bundle_temp.js bundle.js 
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour} Se ha actualizado ${endColour}"
    fi

    tput cnorm
  fi  

}

function searcMachine(){

  machineName="$1"

  machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')"

  if [ "$machineName_checker" ]; then

    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando las propiedades de la maquina ${endColour}${blueColour} $machineName${endColour}${grayColour}:${endColour}\n"
    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//'

  else
    echo -e "\n${redColour}[!] La maquina no existe${endColour}"
  fi

}

function searchIP(){

  ipAddress="$1"

  machineName="$(cat bundle.js| grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"'| tr -d ',')"
  
  if [ "$machineName" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} La maquina correspondiente para la IP: ${endColour}${blueColour}$ipAddress${endColour}${grayColour} es:${endColour}${purpleColour} $machineName${endColour}\n"
  
  else
    echo -e "\n${redColour}[!] La IP no existe${endColour}"
  fi

}

function getYoutubeLink(){

  machineName="$1"

  youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"

  if [ "$youtubeLink" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} El tutorial para esta maquina esta en el siguiente enlace:${endColour}${blueColour} $youtube${endColour}\n"

  else 
    echo -e "\n${redColour}[!] La maquina no existe${endColour}"
  fi

}

function getMachinesDifficulty(){

  difficulty="$1"

  results_check="$(cat bundle.js| grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' )"

  if [ "$results_check" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Representando las maquinas que poseen un nivel de dificultad${endColour}${blueColour} $difficulty${endColour}${grayColour}:${endColour}\n"
    cat bundle.js| grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column

  else
    echo -e "\n${redColour}[!] La dificultad indicada no existe${endColour}"
  fi

}

function getOSMachines(){

  os="$1"

  os_results="$(cat bundle.js| grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

  if [ "$os_results" ]; then
   echo -e "\n${yellowColour}[+]${endColour}${grayColour} Mostrando las maquinas cuyo sistema operativo es ${endColour}${blueColour}$os${endColour}${grayColour}:${endColour}\n"
  cat bundle.js| grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column

  else
    echo -e "\n${redColour}[!] El sistema operativo indicado no existe${endColour}"
  fi

}

function getOSDifficultyMachines() {

  difficulty="$1"

  os="$2"

  check_results="$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' )"

  if [ "$check_results" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando maquinas de dificultad${endColour} ${blueColour}$difficulty${endColour} ${grayColour}que tengan sistema operativo${endColour}${purpleColour} $os${endColour}${yellowColour}:${endColour}"
    cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column

  else
  
    echo -e "\n${redColour}[!] Se ha${endColour}"
  fi

}

function getSkill(){

  skills="$1"

  check_skills="$(cat bundle.js| grep "skills: " -B 6 | grep "$skills" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$check_results" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} A continuacion se presentan las maquinas que incluyen la skill ${endColour}${blueColour}$skill${endColour} "
    cat bundle.js| grep "skills: " -B 6 | grep "" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column

  else
    echo -e "\n${redColour}[!] No se ha encontrado ninguna maquina con la skill indicada ${endColour}\n"
  fi

}

function getAllMachines(){

  echo -e "\n${yellowColour}[+]${endColour} ${grayColour} Estas son los nombres de todas las maquinas :${endColour}\n"
  cat bundle.js | grep "name: \"" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | tr -d '/' | column 

}

# Indicadores
declare -i parameter_counter=0

#Chivatos
declare -i chivato_difficulty=0
declare -i chivato_os=0

#Parametros
while getopts "m:ui:y:d:o:s:ah" arg; do 
  case $arg in 
   m) machineName=$OPTARG; let parameter_counter+=1;;
   u) let parameter_counter+=2;;
   i) ipAddress=$OPTARG; let parameter_counter+=3;;
   y) machineName=$OPTARG; let parameter_counter+=4;;
   d) difficulty=$OPTARG; chivato_difficulty=1; let parameter_counter+=5;;
   o) os=$OPTARG; chivato_os=1; let parameter_counter+=6;;
   s) skills=$OPTARG; let parameter_counter+=7;;
   a) let parameter_counter+=8;;
   h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searcMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
  getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  getMachinesDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
  getOSMachines $os
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ] ; then
  getOSDifficultyMachines $difficulty $os
elif [ $parameter_counter -eq 7 ]; then
  getSkill "$skill"
elif [ $parameter_counter -eq 8 ]; then
  getAllMachines
else
  helpPanel
fi
