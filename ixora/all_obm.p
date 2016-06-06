/* all_obm.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Отчет обменного пункта о пок прод ин валюты
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
 * BASES
        BANK
 * AUTHOR
        21/02/09 marinav 
 * CHANGES
*/

{functions-def.i}
{global.i}

/*define var g-today  as date initial '02/25/02'.  */

define variable symb1 as integer extent 5 init [21,43,65,87,109].
define variable symb2 as integer extent 7 init [4,32,39,59,78,97,116].
define variable t_amt as decimal init 0.
define variable v_amt as decimal init 0.
define variable rur_amt as decimal init 0.
define variable tot1 as decimal.
define variable eur_amt as decimal init 0.
define variable c_dam like crc.rate[1].
define variable c_cam like crc.rate[1].
define variable i as integer.
define var tg-today  as date.

def var pwidth as int init 103.
                                         
define temp-table tot_sum
  field ts_crc like crc.crc
  field ts_dam like jl.dam
  field ts_damkzt like jl.dam
  field ts_damkzth like jl.dam
  field ts_cam like jl.cam
  field ts_camkzt like jl.cam
  field ts_camkzth like jl.cam
  index icrc is primary ts_crc.

define temp-table t_ofc
  field to_ofc like g-ofc.



def new shared var v-dtb as date.
def new shared var v-dte as date.

update 
  v-dtb label " Начальная дата " format "99/99/9999" skip
  v-dte label "  Конечная дата " format "99/99/9999" 
  with centered row 5 side-label frame f-dt.


  
procedure add_to_TS:
define input param namt like jl.dam.
define input param nrate like crc.rate[1].
define input param hrate like crc.rate[1].

find tot_sum where ts_crc = jl.crc no-error.
if not avail tot_sum then do: create tot_sum. ts_crc = jl.crc. end.
if jl.dc = 'd' then 
                 do: 
                   ts_dam = ts_dam + namt.
                   ts_damkzt = ts_damkzt + namt * nrate.
                   ts_damkzth = ts_damkzth + namt * hrate.
                 end.
               else
                 do:
                   ts_cam = ts_cam + namt.
                   ts_camkzt = ts_camkzt + namt * nrate.
                   ts_camkzth = ts_camkzth + namt * hrate.
                 end.
end procedure.

tg-today = 02/20/09.

for each jl where (jl.gl = 100100 or jl.gl = 100200 or jl.gl = 100300) and substring(jl.rem[1],1,5) = 'Обмен' and jl.crc <> 1 and jl.jdt >= v-dtb and jl.jdt <= v-dte:
    find joudoc where joudoc.jh = jl.jh and joudoc.who = jl.who and joudoc.whn =jl.jdt no-lock no-error.
      if avail joudoc 
         then
           do:
             find last crchis where crchis.crc = jl.crc and crchis.rdt <= jl.jdt no-lock no-error.
             if not avail crchis then do: displ jl.jdt. pause. end.
             if jl.dc = 'd' and jl.dam <> 0 then run add_to_TS(jl.dam, joudoc.brate, crchis.rate[1]).
             if jl.dc = 'c' and jl.cam <> 0 then run add_to_TS(jl.cam, joudoc.srate, crchis.rate[1]).
           end.   
end.


find first tot_sum no-lock no-error.
if not avail tot_sum 
   then
     do:
             create tot_sum.
             tot_sum.ts_crc = 2.
             tot_sum.ts_dam = 0.  
             tot_sum.ts_damkzt = 0.
             tot_sum.ts_cam    = 0.
             tot_sum.ts_camkzt = 0.
     end.
  
output to rpt2.img.

put unformatted padc ('ОТЧЕТ', pwidth, ' ') skip.
put unformatted padc ('обменного пункта', pwidth, ' ') skip.
put unformatted padc ('о покупке, продаже иностранной валюты и выручке', pwidth, ' ') skip.
put unformatted fill (' ',47) 'c ' v-dtb ' по ' v-dte skip(1).


put unformatted fill('-',pwidth) skip.
put "| N |" "Операция" at 7 '|' at 17 fill ('_',22) format 'x(22)' "Валюта" at 40 fill ('_',22) format 'x(22)' '|' at 68 /*fill ('_',2)*/ "Тенге" at 70 /*fill ('_',2)*/  '|' at 86 "Чистая выручка" at 87 '|' at 103 skip.
put "|   |" '|' at 17 "Вид"    at 22 '|' at 30 "Сумма"  at 32 '|' at 47 "Сумма в тенге" at 49 '|' at 68 "По курсу" at 70  '|' at 86 '|' at 103 skip.                    
put "|   |" '|' at 17 "валюты" at 20 '|' at 30 "валюты" at 32 '|' at 47 "по рыноч-"  at 49 '|' at 68 "покупки/продажи" at 70  '|' at 86 '|' at 103 skip.
put "|   |" '|' at 17 '|'                at 30 '|'                at 47 "ному курсу"    at 49 '|' at 68 '|' at 86 '|' at 103 skip.
put unformatted fill('-',pwidth) skip.


find tot_sum where tot_sum.ts_crc = 2 no-lock no-error.
/*find crc where crc.crc = 2 no-lock no-error.*/
if avail tot_sum then do:
    put "|   |" " Куплено " '|' at 17 ' USD ' 
                            '|' at 30 ts_dam format '-z,zzz,zzz,zz9.99' 
                            '|' at 47 ts_damkzth format '-z,zzz,zzz,zz9.99'  
                            '|' at 68 ts_damkzt format '-z,zzz,zzz,zz9.99' 
                            '|' at 86 ts_damkzth - ts_damkzt format '-zzz,zzz,zz9.99' 
                            '|' at 103 skip.
    put "| 1 |" "  валюты " '|' at 17 ' USD '
                            '|' at 30 
                            '|' at 47 
                            '|' at 68 '|' at 86 '|' at 103 skip.
end.
else do:
    put "|   |" " Куплено " '|' at 17 ' USD ' 
                            '|' at 30 
                            '|' at 47 
                            '|' at 68 
                            '|' at 86 
                            '|' at 103 skip.
    put "| 1 |" "  валюты " '|' at 17 
                            '|' at 30 
                            '|' at 47 
                            '|' at 68 '|' at 86 '|' at 103 skip.
end.

release tot_sum.

find tot_sum where tot_sum.ts_crc = 3 no-lock no-error.
/*find crc where crc.crc = 3 no-lock no-error.*/

if not avail tot_sum then 
    put "|   |" "         " '|' at 17 ' EUR ' '|' at 30 '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip. 
else
    put "|   |" "         " '|' at 17 ' EUR ' 
                        '|' at 30 ts_dam format '-z,zzz,zzz,zz9.99' 
                        '|' at 47 ts_damkzth format '-z,zzz,zzz,zz9.99'  
                        '|' at 68 ts_damkzt format '-z,zzz,zzz,zz9.99' 
                        '|' at 86 ts_damkzth - ts_damkzt format '-zzz,zzz,zz9.99' 
                        '|' at 103 skip.

find tot_sum where tot_sum.ts_crc = 4 no-lock no-error.

if not avail tot_sum then 
    put "|   |" "         " '|' at 17 ' RUR ' '|' at 30 '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.
else
    put "|   |" "         " '|' at 17 ' RUR ' 
                        '|' at 30 ts_dam format '-z,zzz,zzz,zz9.99' 
                        '|' at 47 ts_damkzth format '-z,zzz,zzz,zz9.99'  
                        '|' at 68 ts_damkzt format '-z,zzz,zzz,zz9.99' 
                        '|' at 86 ts_damkzth - ts_damkzt format '-zzz,zzz,zz9.99' 
                        '|' at 103 skip.


put unformatted fill('-',pwidth) skip.

release tot_sum.

find tot_sum where tot_sum.ts_crc = 2 no-lock no-error.

if avail tot_sum then do:
    put "|   |" " Продано " '|' at 17 ' USD ' 
                            '|' at 30 ts_cam format '-z,zzz,zzz,zz9.99' 
                            '|' at 47 ts_camkzth format '-z,zzz,zzz,zz9.99' 
                            '|' at 68 ts_camkzt format '-z,zzz,zzz,zz9.99'
                            '|' at 86 ts_camkzt - ts_camkzth format '-zzz,zzz,zz9.99' 
                            '|' at 103 skip.
    put "| 2 |" "  валюты " '|' at 17 '|' at 30 '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.
end.
else do:
    put "|   |" " Продано " '|' at 17 ' USD ' 
                            '|' at 30 
                            '|' at 47 
                            '|' at 68 
                            '|' at 86 
                            '|' at 103 skip.
    put "| 2 |" "  валюты " '|' at 17 '|' at 30 '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.
end.

release tot_sum.

find tot_sum where tot_sum.ts_crc = 3 no-lock no-error.

if not avail tot_sum then 

put "|   |" "         " '|' at 17 ' EUR ' '|' at 30 '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.

else
    put "|   |" "         " '|' at 17 ' EUR ' 
                        '|' at 30 ts_cam format '-z,zzz,zzz,zz9.99' 
                        '|' at 47 ts_camkzth format '-z,zzz,zzz,zz9.99'  
                        '|' at 68 ts_camkzt format '-z,zzz,zzz,zz9.99' 
                        '|' at 86 ts_camkzt - ts_camkzth format '-zzz,zzz,zz9.99' 
                        '|' at 103 skip.

find tot_sum where tot_sum.ts_crc = 4 no-lock no-error.

if not avail tot_sum then 
    put "|   |" "         " '|' at 17 ' RUR ' '|' at 30 '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.
else
    put "|   |" "         " '|' at 17 ' RUR ' 
                        '|' at 30 ts_cam format '-z,zzz,zzz,zz9.99' 
                        '|' at 47 ts_camkzth format '-z,zzz,zzz,zz9.99'  
                        '|' at 68 ts_camkzt format '-z,zzz,zzz,zz9.99' 
                        '|' at 86 ts_camkzt - ts_camkzth format '-zzz,zzz,zz9.99' 
                        '|' at 103 skip.


put unformatted fill('-',pwidth) skip.

for each tot_sum:
t_amt=t_amt - ts_damkzt + ts_camkzt.
end.


put "|   |" " Всего  " '|' at 17 ' KZT ' '|' at 30 t_amt format '-z,zzz,zzz,zz9.99' '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.

find tot_sum where tot_sum.ts_crc = 2 no-lock no-error.
if avail tot_sum then 
   put "| 3 |" " валюты " '|' at 17 ' USD ' '|' at 30 v_amt + ts_dam - ts_cam format '-z,zzz,zzz,zz9.99' '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.
else
   put "| 3 |" " валюты " '|' at 17 ' USD ' '|' at 30 '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.


find tot_sum where tot_sum.ts_crc = 3 no-lock no-error.
if not avail tot_sum then 
   put "|   |" " и тенге" '|' at 17 ' EUR ' '|' at 30  '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.
else 
   put "|   |" " и тенге" '|' at 17 ' EUR ' '|' at 30 eur_amt + ts_dam - ts_cam format '-z,zzz,zzz,zz9.99' '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.

find tot_sum where tot_sum.ts_crc = 4 no-lock no-error.
      if not avail tot_sum then 
         put "|   |" "        " '|' at 17 ' RUR ' '|' at 30  '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.
      else 
         put "|   |" "        " '|' at 17 ' RUR ' '|' at 30 rur_amt + ts_dam - ts_cam format '-z,zzz,zzz,zz9.99' '|' at 47 '|' at 68 '|' at 86 '|' at 103 skip.

put unformatted fill('-',pwidth) skip.

tot1=0.
for each tot_sum:
    tot1 = tot1 + ts_damkzth - ts_damkzt + ts_camkzt - ts_camkzth.
end.

put "|Итого" '|' at 86  tot1 format '-zzz,zzz,zz9.99' '|' at 103 skip.
put unformatted fill('-',pwidth) skip(2).

output close.

pause 0 before-hide .
    run menu-prt('rpt2.img').
    pause before-hide.

{functions-end.i}



