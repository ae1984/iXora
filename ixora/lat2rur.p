/* lat2rur.p
 * MODULE
        v6
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        16.10.2012 evseev
 * BASES
        BANK
 * CHANGES
*/

/* для проверки
define var v-org as char.
define var v-dest as char.
define var v-err as logical.

v-org = "OPLATA ZA TOVAR PO ScoTU n123 OT V T. c. NDS (20p) 1800 RUB.00 KOP.".
run lat2rur(input v-org, output v-dest, output v-err).
displ v-dest format "x(100)".
*/

define input parameter v-org as char.
define output parameter v-dest as char.
define output parameter v-err as logical.


def var i as int.
def var v-transl as logical.

run savelog( "lat2rur", "32. Начало....................... ").
run savelog( "lat2rur", v-org).

v-dest = "".
v-err = no.
v-transl = yes.
do i = 1 to length(v-org):
   if substr(v-org,i,1) = "'" and v-transl = yes then v-transl = no.
   else if substr(v-org,i,1) = "'" and v-transl = no  then v-transl = yes.
   if substr(v-org,i,1) = "'" then next.

   if v-transl then do:
      case  asc( substr(v-org,i,1) ) :
          when asc("A") then v-dest = v-dest + "А".
          when asc("B") then v-dest = v-dest + "Б".
          when asc("V") then v-dest = v-dest + "В".
          when asc("G") then v-dest = v-dest + "Г".
          when asc("D") then v-dest = v-dest + "Д".
          when asc("E") then v-dest = v-dest + "Е".
          when asc("o") then v-dest = v-dest + "Ё".
          when asc("J") then v-dest = v-dest + "Ж".
          when asc("Z") then v-dest = v-dest + "З".
          when asc("I") then v-dest = v-dest + "И".
          when asc("i") then v-dest = v-dest + "Й".
          when asc("K") then v-dest = v-dest + "К".
          when asc("L") then v-dest = v-dest + "Л".
          when asc("M") then v-dest = v-dest + "М".
          when asc("N") then v-dest = v-dest + "Н".
          when asc("O") then v-dest = v-dest + "О".
          when asc("P") then v-dest = v-dest + "П".
          when asc("R") then v-dest = v-dest + "Р".
          when asc("S") then v-dest = v-dest + "С".
          when asc("T") then v-dest = v-dest + "Т".
          when asc("U") then v-dest = v-dest + "У".
          when asc("F") then v-dest = v-dest + "Ф".
          when asc("H") then v-dest = v-dest + "Х".
          when asc("C") then v-dest = v-dest + "Ц".
          when asc("c") then v-dest = v-dest + "Ч".
          when asc("Q") then v-dest = v-dest + "Ш".
          when asc("q") then v-dest = v-dest + "Щ".
          when asc("x") then v-dest = v-dest + "Ъ".
          when asc("Y") then v-dest = v-dest + "Ы".
          when asc("X") then v-dest = v-dest + "Ь".
          when asc("e") then v-dest = v-dest + "Э".
          when asc("u") then v-dest = v-dest + "Ю".
          when asc("a") then v-dest = v-dest + "Я".
          when asc("j") then v-dest = v-dest + "'".
          when asc("0") then v-dest = v-dest + "0".
          when asc("1") then v-dest = v-dest + "1".
          when asc("2") then v-dest = v-dest + "2".
          when asc("3") then v-dest = v-dest + "3".
          when asc("4") then v-dest = v-dest + "4".
          when asc("5") then v-dest = v-dest + "5".
          when asc("6") then v-dest = v-dest + "6".
          when asc("7") then v-dest = v-dest + "7".
          when asc("8") then v-dest = v-dest + "8".
          when asc("9") then v-dest = v-dest + "9".
          when asc("(") then v-dest = v-dest + "(".
          when asc(")") then v-dest = v-dest + ")".
          when asc("?") then v-dest = v-dest + "?".
          when asc("+") then v-dest = v-dest + "+".
          when asc("n") then v-dest = v-dest + "№".
          when asc("m") then v-dest = v-dest + '"'.
          when asc("f") then v-dest = v-dest + "*".
          when asc("p") then v-dest = v-dest + "%".
          when asc("d") then v-dest = v-dest + "&".
          when asc(",") then v-dest = v-dest + ",".
          when asc("/") then v-dest = v-dest + "/".
          when asc("-") then v-dest = v-dest + "-".
          when asc(".") then v-dest = v-dest + ".".
          when asc(":") then v-dest = v-dest + ":".
          when asc(" ") then v-dest = v-dest + " ".
          when asc("b") then v-dest = v-dest + "!".
          when asc("s") then v-dest = v-dest + "$".
          when asc("v") then v-dest = v-dest + ";".
          when asc("z") then v-dest = v-dest + "_".
          when asc("r") then v-dest = v-dest + "=".

          otherwise do:
             v-dest = v-dest + substr(v-org,i,1).
             v-err = yes.
          end.
      end case.
   end. else v-dest = v-dest + substr(v-org,i,1).

end.

run savelog( "lat2rur", v-dest).
run savelog( "lat2rur", string(v-err)).
run savelog( "lat2rur", "121. Конец....................... ").
