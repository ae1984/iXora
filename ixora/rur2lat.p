/* rur2lat.p
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
        23.08.2013 evseev
 * BASES
        BANK
 * CHANGES
*/

/* для проверки
define var v-org as char.
define var v-dest as char.
define var v-err as logical.

v-org = "OPLATA ZA TOVAR PO ScoTU n123 OT V T. c. NDS (20p) 1800 RUB.00 KOP.".
run rur2lat(input v-org, output v-dest, output v-err).
displ v-dest format "x(100)".
*/

define input parameter v-org as char.
define output parameter v-dest as char.
define output parameter v-err as logical.


def var i as int.
def var v-transl as logical.
def var v-isRus as logical.

run savelog( "rur2lat", "32. Начало....................... ").
run savelog( "rur2lat", v-org).

v-dest = "".
v-err = no.
v-transl = no.

v-isRus = no.
do i = 1 to length(v-org):
   if lookup(caps(substr(v-org,i,1)),"А,Б,В,Г,Д,Е,Ё,Ж,З,И,Й,К,Л,М,Н,О,П,Р,С,Т,У,Ф,Х,Ц,Ч,Ш,Щ,Ъ,Ы,Ь,Э,Ю,Я") > 0 then do:
      v-isRus = yes.
   end.
end.

do i = 1 to length(v-org):
   if v-isRus then do:
       if lookup(caps(substr(v-org,i,1)),"A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z") > 0 then do:
          if v-transl <> yes then do:
             v-transl = yes.
             v-dest = v-dest + "'".
          end.
       end.
       if v-transl = yes then do:
          if lookup(caps(substr(v-org,i,1)),"А,Б,В,Г,Д,Е,Ё,Ж,З,И,Й,К,Л,М,Н,О,П,Р,С,Т,У,Ф,Х,Ц,Ч,Ш,Щ,Ъ,Ы,Ь,Э,Ю,Я") > 0 then do:
             v-transl = no.
             v-dest = v-dest + "'".
          end.
       end.
   end.

   if v-transl = no then do:
      case  asc( caps(substr(v-org,i,1)) ) :
          when asc("А") then v-dest = v-dest + "A".
          when asc("Б") then v-dest = v-dest + "B".
          when asc("В") then v-dest = v-dest + "V".
          when asc("Г") then v-dest = v-dest + "G".
          when asc("Д") then v-dest = v-dest + "D".
          when asc("Е") then v-dest = v-dest + "E".
          when asc("Ё") then v-dest = v-dest + "о".
          when asc("Ж") then v-dest = v-dest + "J".
          when asc("З") then v-dest = v-dest + "Z".
          when asc("И") then v-dest = v-dest + "I".
          when asc("Й") then v-dest = v-dest + "i".
          when asc("К") then v-dest = v-dest + "K".
          when asc("Л") then v-dest = v-dest + "L".
          when asc("М") then v-dest = v-dest + "M".
          when asc("Н") then v-dest = v-dest + "N".
          when asc("О") then v-dest = v-dest + "O".
          when asc("П") then v-dest = v-dest + "P".
          when asc("Р") then v-dest = v-dest + "R".
          when asc("С") then v-dest = v-dest + "S".
          when asc("Т") then v-dest = v-dest + "T".
          when asc("У") then v-dest = v-dest + "U".
          when asc("Ф") then v-dest = v-dest + "F".
          when asc("Х") then v-dest = v-dest + "H".
          when asc("Ц") then v-dest = v-dest + "C".
          when asc("Ч") then v-dest = v-dest + "c".
          when asc("Ш") then v-dest = v-dest + "Q".
          when asc("Щ") then v-dest = v-dest + "q".
          when asc("Ъ") then v-dest = v-dest + "x".
          when asc("Ы") then v-dest = v-dest + "Y".
          when asc("Ь") then v-dest = v-dest + "X".
          when asc("Э") then v-dest = v-dest + "e".
          when asc("Ю") then v-dest = v-dest + "u".
          when asc("Я") then v-dest = v-dest + "a".

          when asc("'") then v-dest = v-dest + "j".
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
          when asc("№") then v-dest = v-dest + "n".
          when asc("%") then v-dest = v-dest + "р".
          when asc("&") then v-dest = v-dest + "d".
          when asc(",") then v-dest = v-dest + ",".
          when asc("/") then v-dest = v-dest + "/".
          when asc("-") then v-dest = v-dest + "-".
          when asc(".") then v-dest = v-dest + ".".
          when asc(":") then v-dest = v-dest + ":".
          when asc(" ") then v-dest = v-dest + " ".

          when asc("A") then v-dest = v-dest + substr(v-org,i,1).
          when asc("B") then v-dest = v-dest + substr(v-org,i,1).
          when asc("C") then v-dest = v-dest + substr(v-org,i,1).
          when asc("D") then v-dest = v-dest + substr(v-org,i,1).
          when asc("E") then v-dest = v-dest + substr(v-org,i,1).
          when asc("F") then v-dest = v-dest + substr(v-org,i,1).
          when asc("G") then v-dest = v-dest + substr(v-org,i,1).
          when asc("H") then v-dest = v-dest + substr(v-org,i,1).
          when asc("I") then v-dest = v-dest + substr(v-org,i,1).
          when asc("J") then v-dest = v-dest + substr(v-org,i,1).
          when asc("K") then v-dest = v-dest + substr(v-org,i,1).
          when asc("L") then v-dest = v-dest + substr(v-org,i,1).
          when asc("M") then v-dest = v-dest + substr(v-org,i,1).
          when asc("N") then v-dest = v-dest + substr(v-org,i,1).
          when asc("O") then v-dest = v-dest + substr(v-org,i,1).
          when asc("P") then v-dest = v-dest + substr(v-org,i,1).
          when asc("Q") then v-dest = v-dest + substr(v-org,i,1).
          when asc("R") then v-dest = v-dest + substr(v-org,i,1).
          when asc("S") then v-dest = v-dest + substr(v-org,i,1).
          when asc("T") then v-dest = v-dest + substr(v-org,i,1).
          when asc("U") then v-dest = v-dest + substr(v-org,i,1).
          when asc("V") then v-dest = v-dest + substr(v-org,i,1).
          when asc("W") then v-dest = v-dest + substr(v-org,i,1).
          when asc("X") then v-dest = v-dest + substr(v-org,i,1).
          when asc("Y") then v-dest = v-dest + substr(v-org,i,1).
          when asc("Z") then v-dest = v-dest + substr(v-org,i,1).

          otherwise do:
             /*v-dest = v-dest + substr(v-org,i,1).*/
             v-err = yes.
          end.
      end case.
   end. else v-dest = v-dest + substr(v-org,i,1).

   if length(v-org) = i and v-transl = yes then do:
      v-transl = no.
      v-dest = v-dest + "'".
   end.

end.

run savelog( "rur2lat", v-dest).
run savelog( "rur2lat", string(v-err)).
run savelog( "rur2lat", "121. Конец....................... ").


