/* pkdefadrcif.p
 * MODULE
        ПотребКРЕДИТ
 * DESCRIPTION
        Определение строки адреса прописки и фактического проживания по данным КЛИЕНТА (cif.dnb)
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        общая процедура ПК
 * AUTHOR
        01.02.2004 nadejda
 * BASE
        BANK COMM
 * CHANGES
        27.08.2013 damir - Внедрено Т.З. № 1985.
*/


{global.i}
{pk.i}

def input parameter p-ln like pkanketa.ln.
def input parameter p-space as logical.  /* yes - разрешены пробелы, no - заменять &nbsp; */
def output parameter p-adres1 as char.
def output parameter p-adres2 as char.

if p-ln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and
     pkanketa.ln = p-ln no-lock no-error.

if not avail pkanketa then return.

find cif where cif.cif = pkanketa.cif no-lock no-error.
if not avail cif then return.

def var v-adres as char extent 2.
def var v-adresdel as char extent 2.
def var v-adreslabel as char init "г. ,,д.,кв.,,,,,,".
def var i as integer.
def var n as integer.
def var v-data as char.
def var v-delim as char init "^".

if cif.dnb = "" then do:
  run pkdefadres (p-ln, p-space, output v-adres[1], output v-adres[2], output v-adresdel[1], output v-adresdel[2]).
end.
else do:
  do i = 1 to 2:
    if num-entries(cif.dnb, "|") < i then v-adres[i] = v-adres[1].
    else do:
      v-adresdel[i] = entry(i, cif.dnb, "|").
      v-adres[i] = "".
      do n = 1 to num-entries(v-adresdel[i], v-delim):
        v-data = trim(entry(n, v-adresdel[i], v-delim)).
        if v-data <> "" then do:
          v-data = entry(n, v-adreslabel) + v-data.
          if not p-space then v-data = replace (v-data, " ", "&nbsp;").

          if v-adres[i] <> "" then v-adres[i] = v-adres[i] + ", ".
          v-adres[i] = v-adres[i] + v-data.
        end.
      end.
    end.
  end.
end.

p-adres1 = v-adres[1].
if v-adres[2] = "" then p-adres2 = p-adres1.
                   else p-adres2 = v-adres[2].

