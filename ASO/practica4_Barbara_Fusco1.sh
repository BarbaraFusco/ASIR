#!/bin/bash

# Comprobar si es el, script está siendo ejecutado por root
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
		#echo "El instalador para $nombrePaquete es apt..."
		instalador="apt"
	elif snap info $nombrePaquete &> /dev/null; then
		#echo "El instalador para $nombrePaquete es snap..."
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
           		sudo $instalador install "$nombrePaquete"
				if [[ $? != 0 ]] ; then
					echo "$nombrePaquete no se instaló correctamente"
				else
           			echo "$nombrePaquete se ha instalado correctamente"
				fi
        	else
           		echo "El paquete ya se encuentra instalado"
        	fi

  		fi
	elif [[ "$accion" == 'remove' ]] ; then
        	if dpkg -l | grep -q "^ii  $nombrePaquete" ; then
           		sudo apt purge -y  "$nombrePaquete"
           		echo "$nombrePaquete se ha desinstalado correctamente"
        	else
          		echo "$nombrePaquete no está instalado"
        	fi
	fi
   	if [[ "$accion" == 'status' ]] ; then
        	if dpkg -l | grep -q "^ii  $nombrePaquete "; then
                	echo "$nombrePaquete está instalado."
        	else
                	echo "$nombrePaquete está instalado."
        	fi
   	fi
done
