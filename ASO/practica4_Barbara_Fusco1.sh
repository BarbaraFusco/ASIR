#!/bin/bash

# Comprobar si es el script está siendo ejecutado por root
# Sino salimos del programa
if [ $(id -u) != 0 ]; then
	echo "Este script sólo puede ejecutarse como root"
	exit 1
fi

# Declarar un array para poder iterar sobre el fichero "paquetes.txt"
declare -a paquetes=($(cat paquetes.txt))

instalador=""

# Por cada línea paquete:
for paquetesDisponibles in "${paquetes[@]}" ; do
	accion=$(echo $paquetesDisponibles | awk -F ':' '{print $2}')
	nombrePaquete=$(echo $paquetesDisponibles | awk -F ':' '{print $1}')

	# Comprobamos si el paquete se instala con apt o con snap
	if apt show $nombrePaquete &> /dev/null; then
		echo "El instalador para $nombrePaquete es apt..."
		instalador="apt"
	elif snap info $nombrePaquete &> /dev/null; then
		echo "El instalador para $nombrePaquete es snap..."
		instalador="snap"
	fi

	# En caso de añadir el paquete
	if [[ "$accion" == 'add' ]] ; then
		# Si el instalador es apt
		if [[ "$instalador" == "apt-get" ]]; then
			# Instalamos
			if ! dpkg -l | grep -q "^ii  $nombrePaquete" ; then
				sudo $instalador install -y  "$nombrePaquete"
				echo "$nombrePaquete se ha instalado correctamente"
			#
			else
				echo "El paquete ya se encuentra instalado"
			fi
		# En caso de que sea snap
		else
		    if ! dpkg -l | grep -q "^ii  $nombrePaquete" ; then
				# Algunos programas no se pueden instalar sin la opción --classic porque fueron diseñados originalmente para ser ejecutados fuera del entorno confinado de Snap y requieren un acceso más amplio al sistema.
           		sudo $instalador install "$nombrePaquete"
        	else
           		echo "El paquete ya se encuentra instalado"
        	fi
  		fi
		# En caso de que la acción a realizar sea 'remove', se elimina
	elif [[ "$accion" == 'remove' ]] ; then
			# Verificar si el programa está instalado. Aquellos que empiecen por ii están instalados.
        	if dpkg -l | grep -q "^ii  $nombrePaquete" ; then
				# Eliminar el paquete
           		sudo apt purge -y  "$nombrePaquete"
           		echo "$nombrePaquete se ha desinstalado correctamente"
        	else
          		echo "$nombrePaquete no está instalado"
        	fi
	fi
	# En caso de que la acción sea status, se verificará el estado del programa (si está o no instalado)
   	if [[ "$accion" == 'status' ]] ; then
			# Verificar si el programa está instalado
        	if dpkg -l | grep -q "^ii  $nombrePaquete "; then
                	echo "$nombrePaquete está instalado."
        	else
                	echo "$nombrePaquete está instalado."
        	fi
   	fi
done
