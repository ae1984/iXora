/* ss-vrd.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

define input  parameter in-summa  as decimal.
define output parameter out-summa as character.
define input  parameter big  as log.

define variable int-c       as char.
define variable i           as integer.
define variable j           as integer.
define variable cur-klase   as integer.
define variable klas-s      as integer.
define variable sim-cip     as integer.
define variable vien-cip    as integer.
define variable des-cip     as integer.
define variable klas-dal    as integer init 1000000000.
define variable klase       as character extent 12 init
        ["miljards ","miljardu ","miljardi ","miljons ","miljonu ",
        "miljoni ","t­kstotis ","t­kstoЅu ","t­kstoЅi "," "," "," "].
define variable vieni       as character extent 10 init
        [" ","viens ","divi ","trЁs ","ўetri ","pieci ","seЅi ",
        "septi‡i ","asto‡i ","devi‡i "].
define variable desmiti     as character extent 10 init
        [" ","desmit ","divdesmit ","trЁsdesmit ","ўetrdesmit ","piecdesmit ",
        "seЅdesmit ","septi‡desmit ","asto‡desmit ","devi‡desmit "].
define variable padsmiti    as character extent 10 init
        [" ","vienpadsmit ","divpadsmit ","trЁspadsmit ","ўetrpadsmit ",
        "piecpadsmit ","seЅpadsmit ","septi‡padsmit ",
        "asto‡padsmit ","devi‡padsmit "].
define variable simti       as character extent 10 init
        [" ","simts ","divi simti ","trЁs simti ","ўetri simti ","pieci simti ",
        "seЅi simti ","septi‡i simti ","asto‡i simti ","devi‡i simti "].
define variable mazie       as character extent 7 init
       ["v","d","t","ў","p","s","a"].
define variable lielie      as character extent 7 init
       ["V","D","T","°","P","S","A"].
define variable ira as log init true.
define variable viesi as char init "viens simts ".

/* int-s = in-summa. */
out-summa = "".
if in-summa < 0
then.
else if in-summa = 0
     then out-summa = "nulle ".
     else do:
          i = 1.
          repeat while i <= 4 :
klas-s = integer(substring(string(in-summa,"999999999999.99"),(3 * (i - 1)) + 1,03)).
int-c = substring(string(in-summa,"999999999999.99"),(3 * (i - 1)) + 1,03).
             if klas-s > 0
             then do:
                  sim-cip = integer(substring(int-c,1,1)).  des-cip =
                  integer(substring(int-c,2,1)).  vien-cip =
                  integer(substring(int-c,3,1)).  if i LE 3 and klas-s GT
                  0.0 then ira = false.  if i = 4 and ira and sim-cip = 1
                  then out-summa = out-summa + viesi. /* устное указание до
                              дpугого pаспоpяжения свыше              */
                  else
                  out-summa = out-summa + simti[sim-cip + 1].
                  j = 3.
                  if des-cip > 1 or des-cip = 1 and vien-cip = 0
                  then do:
                       out-summa = out-summa + desmiti[des-cip + 1].
                       if vien-cip = 1 and des-cip > 1
                       then j = 1.
                       else if vien-cip >= 1 and des-cip =1
                            then j = 2.
                            else if 1 < vien-cip and vien-cip <= 4
                            then j = 3.
                            else if vien-cip = 0
                                 then j = 2.
                       out-summa = out-summa + vieni[vien-cip + 1].
                  end.
                  else if des-cip = 1 and vien-cip > 0
                       then out-summa = out-summa + padsmiti[vien-cip + 1].
                       else if des-cip = 0 and vien-cip > 0
                            then do:
                                 if vien-cip = 1
                                 then j = 1.
                                 else if vien-cip <= 4
                                      then j = 3.
                                 out-summa = out-summa + vieni[vien-cip + 1].
                            end.
                  out-summa = out-summa + klase[3 * (i - 1) + j].
             end.
             i = i + 1.
          end.
     end.
     out-summa = trim(out-summa).
     if big then do:
     do i = 1 to 7:
        if substring(out-summa,1,1) = mazie[i]
        then leave.
     end.
     if i <= 7
     then overlay(out-summa,1,1) = lielie[i].
     end.
return.
