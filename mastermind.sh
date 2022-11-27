#!/bin/bash

function koniec
{
        echo "Hľadaný kód: ${hc[1]} ${hc[2]} ${hc[3]} ${hc[4]}"
        read
        exit 0
}

echo "*** Vitajte v hre logik ***"
echo "Vašou úlohou bude nájsť štvorfarebný farebný kód."
echo "Farby sú červená zelená modrá fialová žltá svetlomodrá."
echo "Jednotlivé farby sú zadávané číselnou formou v jednom riadku oddelené medzerou."
echo "Po zadaní 4 farieb sa vyhodnotí Váš pokus."
echo "Zobrazí sa Vám informácia o tom, koľko farieb v kóde ste uhádli (biely znak o)"
echo "a koľko farieb a ich umiestnení ste uhádli (čierny znak ø)"

# zadanie nicku a obtiažnosti
read -p "Zadajte svoj nick: " nick
echo "$nick zadajte obtiažnosť:"
echo "1. ľahká - 6 farieb a 12 pokusov na uhádnutie"
echo "2. stredná - 6 farieb a 9 pokusov na uhádnutie"
echo "3. ťažká - 6 farieb a 6 pokusov na uhádnutie"
read -t 5 zad_obt

case "$zad_obt" in
"1"|"1."|"l"|"ľ"|"lahka"|"ľahká")
        obtiaznost="ľahká"
        poc_pokusov=12;;
"2"|"2."|"s"|"stredna"|"stredná")
        obtiaznost="stredná"
        poc_pokusov=9;;
"3"|"3."|"t"|"ť"|"tazka"|"ťažká")
        obtiaznost="ťažká"
        poc_pokusov=6;;
*)
        echo "Nezadaná správna voľba"
        obtiaznost="ľahká"
        poc_pokusov=12;;
esac
echo "Zvolená $obtiaznost obtiažnosť!"

# generovanie správnej kombinácie
declare -a hc # hádané čísla
declare -a pom
poc_pinov=4
for i in $(seq $poc_pinov); do
        let hc[i]=1+RANDOM%6
done

#debug
#hc[1]=5
#hc[2]=2
#hc[3]=2
#hc[4]=4

#echo "Debug: ${hc[1]} ${hc[2]} ${hc[3]} ${hc[4]}"

declare -a tc # tipované čísla
pokus_c=0
while [ $pokus_c -lt $poc_pokusov ]; do
        let pokus_c++
        echo "Pokus č.$pokus_c"
        echo "červená - 1, zelená - 2, modrá - 3, fialová - 4, žltá - 5, svetlomodrá - 6"
		
        kombinacia=""
        while [ ${#kombinacia} -lt 7 ]; do
                read -p "$nick zadajte kombináciu v tvare 1 1 1 1: " kombinacia

                if [ ${#kombinacia} -lt 7 ]; then
                        echo "Zle zadaná kombinácia!"
                fi
        done

        pozicia=0
        for i in $(seq $poc_pinov); do
                tc[i]=${kombinacia:pozicia:1}
                pom[i]=${hc[i]}
                let pozicia+=2
        done

        # zhodnotenie pokusu
        poc_spravnych_poz=0
        poc_spravnych=0

        for i in $(seq $poc_pinov); do
                if [ ${tc[$i]} == ${hc[$i]} ]; then
                        let poc_spravnych_poz++
                        pom[i]="0"
                fi
        done

        for i in $(seq $poc_pinov); do
				if [ ${pom[i]} == "0" ]; then
					continue
				fi
                for j in $(seq $poc_pinov); do
                        if [ ${tc[$i]} == ${pom[$j]} ]; then
                                let poc_spravnych++
                                pom[j]="O"
                                break
                        fi
                done
        done

        if [ $poc_spravnych_poz -eq $poc_pinov ]; then
                echo "%%% Kód bol nájdený, gratulujem %%%"
                echo "Potrebný počet pokusov: $pokus_c"
                case "$obtiaznost" in
                        "ľahká") echo "$nick, mali by ste skúsiť strednú obtiažnosť";;
                        "stredná") echo "$nick, čo tak skúsiť aj ťažkú obtiažnosť?";;
                        *) echo "$nick na najťažšej obtiažnosti! Tak to je niečo!";;
                esac
                koniec
        elif [ $pokus_c -eq $poc_pokusov ]; then
                echo "~Žiadny ďalší pokus~ kód sa nenašiel!"
                case "$obtiaznost" in
                        "ľahká") echo "$nick, naozaj ste prehrali na ľahkej obtiažnosti? Skúste to znova";;
                        "stredná") echo "$nick, stred nie je to pravé? Skúste ľahkú obtiažnosť";;
                        *) echo "$nick, skúste to znova alebo vyskúšajte strednú obtiažnosť";;
                esac
                koniec
        else
                echo "$nick kód nenájdený"
        fi

        echo -n "Zhodnotenie pokusu "
        for i in $(seq $poc_spravnych_poz); do
                echo -n "ø"
        done
        for i in $(seq $poc_spravnych); do
                echo -n "o"
        done
        printf "\n"
done
read
