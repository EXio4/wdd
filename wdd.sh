#!/bin/bash
#
#    WWD v0.5
#    Copyright (C) 2011 EXio4
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

## Version 0.5.1
## TopList funcionando a medias. Revisando demas funciones.

## Version 0.5
## Ahora vuelve a funcionar

## Version 0.4.1
## Cambios:
##			Agregado menu de categorias [Al hacer Random en WallBase]

## Version 0.4
## Se agrego:
##			Soporte de busquedas en Deviantart
## Cambios minimos:
##			Algunos colores agregados

## Version 0.3 [Rearmada]
## Cambios de esta version:
##			No se usan mas bucles
##			Soporte de categorias
##			Opcion de bajar wallpapers con solo pasar el link (a wallbase)
##			Soporte de directorios corregido
##
## Se borro:
##			El manejo de la cantidad por bucles
##			El uso de funciones a medias

## Variables globales [Default]

walls=10 # Cantidad de wallpapers por default
categoria="high-resolution" # Aca puede ir 'high-resolution' 'rozne' 'manga-anime'
dir="$PWD" # Directorio por default [A USAR]

## Variables del programa [Se recomienda no editarlas]
file1="cache1.txt"
file2="cache2.txt"
file3="cache3.txt"
wget_list="wget-list.txt"
option="normal"
cant=0

## Colores..
export    esc="\033"
export    red="${esc}[31m${esc}[1m" # Rojo
export    green="${esc}[32m${esc}[1m" # Verde
export    yellow="${esc}[33m${esc}[1m" # Amarillo
export    bold="${esc}[1m" # Negrita
export    reset2="${esc}[0m" # Restablecer colores

recho() {
echo -e "${yellow}>> ${red}${@}${reset2}"
}

gecho() {
echo -e "${yellow}>> ${green}${@}${reset2}"
}
gprintf() {
echo -en "${green}${@}${reset2}"	
}
rprintf() {
echo -en "${red}${@}${reset2}"	
}


normal.reload() {
	wget -O "$file1" "http://wallbase.cc/random" &>/dev/null
}

proc_line_code() {
cat | grep jpg | grep "<img" | cut -d"'" -f2 | tr '"' '\n' | tr "'" '\n' | grep -iE '(png|jpeg|jpg)'
}

normal.extract2() {
code=$(cat $1 | proc_line_code) 
for i in $code; do
	if [[ "$i" = *${categoria}* ]]; then
		gecho "URL: $i"
		echo $i >> $wget_list
		return 0
	else
		recho "URL: $i [Not downloading...]"
		return 1
	fi
done
}
normal.extract2l() {
code=$(cat $1 | proc_line_code) 
for i in $code; do
		gecho "URL: $i"
		echo $i >> $wget_list
		return 0

done
}


normal.extract() {
recho "RandomWallBase running.."
while true; do
normal.reload
wallpapers=$(cat $file1 | grep "<a href=" | grep wallpaper | cut -d"=" -f2 | cut -d"\"" -f2 | grep wallbase | cut -d'"' -f2) # 
for i in $wallpapers; do
	[[ "$cant" = "$walls" ]] && break 2
	wget -O "$file2" "$i" &>/dev/null 
	normal.extract2 $file2
	result=$?
	if [[ $result = 0 ]]; then
		cant=$(expr $cant + 1)
	fi
done
done
}

download_list() {
gecho "Downloading list of files.."
for i in $(cat $wget_list); do # Leemos la lista
	if [[ ! -e "$(basename $i)" ]]; then
		wget -O "./$(basename $i)" $i # Bajamos el archivo si existe
	else
		recho "$i already downloaded.." # sino tiramos el "error"
	fi
done	
}

deviantart_search() {
walls=$1
shift
search=$1
[[ -z $search ]] && return 1
recho "Searching $search in deviantart..."
wget -O "$file1" "http://browse.deviantart.com/?qh=&section=&q=$search" -U Mozilla &>/dev/null
lista=$(cat $file1 | grep href | grep "http://"|grep ".deviantart.com/art/" | cut -d"<" -f4|grep href|cut -d'"' -f4)
cant=0
for i in $lista; do
	wget -O "$file2" "$i" -U Mozilla &>/dev/null
	url=$(cat $file2 | grep jpg | grep "<img" | grep deviantart | sed -e 's/<.*>//g' | cut -d"=" -f3|cut -d'"' -f2|grep devian)
	for a in $url; do
		[[ "$cant" = "$walls" ]] && break 3
		recho "URL: $a"
		echo "$a" >> $wget_list
		cant=$(expr $cant + 1)
	done
done
}


menu2.1() {
rprintf "Inserte la cantidad de wallpapers a bajar: "
read cantidad
[[ -z $cantidad ]] && exit 2
walls=$cantidad
if ! [[ "$walls" =~ ^[0-9]+$ ]] ; then 
               recho "Introduzca un numero positivo y sin coma.."
               exit 3
fi 
recho "De que categoria?"
recho "1- high-resolution"
recho "2- rozne"
recho "3- manga-anime"
rprintf ">> " 
read catg
case $catg in
	1)
		recho "Usando high-resolution.."
		categoria="high-resolution"
	;;	
	2)
		recho "Usando rozne.."
		categoria="rozne"
	;;	
	3)
		recho "Usando manga-anime.."
		categoria="manga-anime"
	;;	
	*)
		recho "Categoria nula o erronea.. usando la default [ $categoria ]"
	;;
esac
#categoria="" # Aca puede ir 'high-resolution' 'rozne' 'manga-anime'
normal.extract
}

menu2.2() {
rprintf "Inserte la url: "
read url
[[ -z $url ]] && exit 2
unset categoria
wget -O $file1 $url
result=$?
[[ $result != 0 ]] && exit 3
normal.extract2 $file1
}
menu2.3() {
recho "Que desea buscar?"
rprintf ">> "
read search 
[[ -z $search ]] && exit 2
gecho "Bajando la pagina de busquedas.."
wget -O "$file1" "http://wallbase.cc/search/_${search}_" &> /dev/null
recho "Cuantos resultados desea bajar?"
rprintf ">> "
read cantidad
if ! [[ "$cantidad" =~ ^[0-9]+$ ]] ; then 
               recho "Introduzca un numero positivo y sin coma.."
               exit 3
fi 
cant=0
wallpapers=$(cat $file1 | grep "<a href=" | grep wallpaper | cut -d"=" -f2 | cut -d"\"" -f2 | grep wallbase) # 
for i in $wallpapers; do
	[[ "$cant" = "$cantidad" ]] && break 2
	wget -O "$file2" "$i" &>/dev/null 
	normal.extract2l $file2
	cant=$(expr $cant + 1)
done
return 0
}




## EXPERIMENTAL FUNCTIONS

toplist.reload() {
	local cual
	cual=$1
	[[ -z $cual ]] && cual="0"
	wget -O "$file1" "http://wallbase.cc/toplist/$cual/all/eqeq/0x0/0/$cat/32/0" &>/dev/null
}


toplist.extract2() {
code=$(cat $1 | proc_line_code) 
for i in $code; do
		gecho "URL: $i"
		echo $i >> $wget_list
		return 0
done	
}

toplist.extract() {
num=0
recho "TopListWallBase running.."
while true; do
toplist.reload $num
wallpapers=$(cat $file1 | grep "<a href=" | grep wallpaper | cut -d"=" -f2 | cut -d"\"" -f2 | grep wallbase) # 
for i in $wallpapers; do
	[[ "$cant" = "$walls" ]] && break 2
	wget -O "$file2" "$i" &>/dev/null 
	toplist.extract2 $file2
	result=$?
	if [[ $result = 0 ]]; then
		cant=$(expr $cant + 1)
	fi
done
num=$(expr $num + 32)
done
}

menu2.5() {

rprintf "Inserte la cantidad de wallpapers a bajar: "
read cantidad
[[ -z $cantidad ]] && exit 2
walls=$cantidad
if ! [[ "$walls" =~ ^[0-9]+$ ]] ; then
               recho "Introduzca un numero positivo y sin coma.."
               exit 3
fi
recho "De que categoria?"
recho "1- Normal"
recho "2- Softcore"
recho "3- XXX"
rprintf ">> "
read catg
case $catg in
        1)
                recho "Usando normal.."
                cat="100"
        ;;
        2)
                recho "Usando softcore.."
                cat="010"
        ;;
        3)
                recho "Usando XXX.."
                cat="001"
        ;;
        *)
				recho "Usar categoria de modo RAW ? [Solo use esta funcion si sabe lo que hace]"
				rprintf "[Y/*]>"
				read opt
				case "$opt" in 
					Y|y|S|s)
						recho "Usando categoria de modo raw.."
						cat="$opt"
					;;
					*)
						cat="100"
						recho "Usando la default [ Normal ]..."
					;;
				esac
        ;;
esac
#categoria="" # Aca puede ir 'high-resolution' 'rozne' 'manga-anime'
toplist.extract

##http://wallbase.cc/toplist/[cual_empieza]/all/eqeq/0x0/0/[apto_para_cardiacos][softcore][hardcore]/32/0

}

bajar_todo_wallbase() {
	
recho "Experimental function.."
recho "Use [Ctrl-C] to quit.. or enter to continue"
read
recho "<-  Starting 'downloder' ->"
walls="500000" 
cat="111"

toplist.extract

##http://wallbase.cc/toplist/[cual_empieza]/all/eqeq/0x0/0/[apto_para_cardiacos][softcore][hardcore]/32/0

}





menu2.4() {
recho "Que desea buscar?"
rprintf ">> "
read search 
[[ -z $search ]] && exit 2
recho "Cuantos resultados desea bajar?"
rprintf ">> "
read cantidad
if ! [[ "$cantidad" =~ ^[0-9]+$ ]] ; then 
               recho "Introduzca un numero positivo y sin coma.."
               exit 3
fi 
deviantart_search "$cantidad" "$search"
return 0
	
}
licence() {
printf "$red"
echo "This program under GPL Licence"
printf "$green"
echo "    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>."
printf "$reset2"
exit 0
}

menu() {
recho "WWD -> 0.5   By EXio4"
recho "Vamos a un directorio.."
if [[ "$1" = "-d" ]]; then
	gprintf "Inserte el directorio: "
	read path
	cd $path
	result=$?
	if [[ $result != 0 ]]; then
		recho "Hubo un error, compruebe que existe el directorio"
		exit 3
	fi
fi
if [[ -e $wget_list ]]; then
	recho "$wget_list exist.."
	gprintf "Remove it? [Y/*]"
	read opt
	case "$opt" in
		y|Y|s|S)
			rm $wget_list
			result=$?
			if [[ $result != 0 ]]; then
				recho "Failed deleting $wget_file .."
				exit 1
			fi
		;;		
		*)
			recho "Warning.. no deleting $wget_list.."
		;;
	esac
fi
gecho "Que desea?"
recho "1- Bajar wallpapers al azar [WallBase]"
recho "2- Bajar un wallpaper especifico [WallBase]"
recho "3- Buscar wallpapers en Wallbase"
recho "4- Buscar wallpapers en Deviantart"
recho "5- Bajar el toplist [WallBase]"
recho "Experimental:"
recho "6- Bajar TODO Wallbase [Opcion no probada]"
rprintf ">> "
read opt
[[ -z $opt ]] && exit 1
case $opt in 
		1)
			menu2.1
		;;
		2)
			menu2.2
		;;
		3)
			menu2.3
		;;
		4)
			menu2.4
		;;
		5)
			menu2.5
		;;
		6)
			bajar_todo_wallbase
		;;
		*)
			recho "Opcion incorrecta"
			exit 1
		;;
esac
}




[[ "$1" = "-l" ]] && licence
menu $@
download_list
