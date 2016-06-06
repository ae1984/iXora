/* eknp998c.p
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
        11.06.2004 nadejda - все поменяла в связи с изменением отчета по постановлению НБ РК
                             теперь берутся только корсчета (ГК 1052), БИК можно не писать при некоторых условиях,
                             все в тенге
                             и в конце должна отражаться курсовая разница - для нее отдельная таблица
        30.07.2004 sasco - вывод всех проводок в Excel
        07.04.2005 sasco - вместо O998 - I998
*/


{gl-utils.i}
{mainhead.i}
{eknp_def.i new}

def var v-god as integer.
def var v-month as integer.
def var v-lastday as integer.
def var v-crc like crc.crc.

def temp-table t-sv
    field ptype as int format "99"
    field sumkzt1 as deci format "zzz,zzz,zzz,zz9.99" 
    field sumkzt2 as deci format "zzz,zzz,zzz,zz9.99" 
    index main ptype.

v-god = year(g-today).
v-month = month(g-today).
if v-month = 1 then do:
  v-month = 12.
  v-god = v-god - 1.
end.
else v-month = v-month - 1.

run mondays (v-month, v-god, output v-lastday).
v-dtb = date(v-month, 1, v-god).
v-dte = date(v-month, v-lastday, v-god).

def var v-msgnum as integer init 0.
find sysc where sysc.sysc = "eknpnm" no-lock no-error.
if avail sysc then v-msgnum = sysc.inval.
else do transaction:
  create sysc.
  sysc.sysc = "EKNPNM".
  sysc.des = "Номер телеграммы отчета ЕКНП".
  sysc.inval = 0.
end.
v-msgnum = v-msgnum + 1.

update skip(1)
       v-dtb    label "    Дата начала отчетного периода " format "99/99/9999" 
             validate (v-dtb < g-today, " Неверная дата!") " " skip
       v-dte    label "    Дата конца отчетного периода  " format "99/99/9999" 
             validate (v-dtb < g-today, " Неверная дата!") skip(1)
       v-msgnum label " Номер телеграммы (уник.референс) " format ">>>>>>>>9"
             validate (v-msgnum > 1, " Неверный номер телеграммы!") skip(1)
       with row 5 centered side-labels title " ПАРАМЕТРЫ ОТЧЕТА ".

if v-dte < v-dtb then v-dte = v-dtb.

do transaction:
  find sysc where sysc.sysc = "eknpnm" exclusive-lock no-error.
  sysc.inval = v-msgnum.
  release sysc.
end.

message " Формирование отчета...".

run eknp_998.

define stream mt998.
output stream mt998 to "temp.exp".

put "Отчет по ЕКНП с " v-dtb " по " v-dte skip.
put stream mt998 unformatted "\{1:F01K054700000000000000000\}" skip.
put stream mt998 unformatted "\{2:O998SSTAT0000000U3003\}" skip.
put stream mt998 unformatted "\{4:" skip.
put stream mt998 unformatted ":20:MKB" + trim(string(v-msgnum, ">>>>>>>>9")) skip.
put stream mt998 unformatted ":12:800" skip.
put stream mt998 unformatted ":77E:" skip.

find bank.sysc where bank.sysc.sysc = "CLECOD" no-lock no-error.
if avail bank.sysc then put stream mt998 unformatted "/ACCOUNT/190201125/400161370" skip.  /*+ */

find bank.sysc where bank.sysc.sysc = "CHIEF" no-lock no-error.
if avail bank.sysc then put stream mt998 unformatted "/CHIEF/" + sysc.chval skip.

find sysc where sysc.sysc = "MAINBK" no-lock no-error.
if avail sysc then put stream mt998 unformatted "/MAINBK/" + sysc.chval skip.

session:date-format = "ymd".
put stream mt998 unformatted "/PERIOD/" + string(v-dtb,"999999") + "/" + string(v-dte,"999999") skip.
session:date-format = "dmy".

put stream mt998 unformatted "/SOURCE/02" skip.

find sysc where sysc.sysc = "CLECOD" no-lock no-error.
if avail sysc then put stream mt998 unformatted "/CLIENT/190201125/400161370" skip. /*+ sysc.chval + "/".*/


define var sum as decimal.


def stream rep.
output stream rep to eknp.csv.
put stream rep unformatted 
"Дата;Г/К;1 проводка;2 проводка;Отпр-теория;Отправитель;Путь и страна;Получ-теория;Получатель;Тип;Дебет;Кредит;Сумма в тенге;код1;код2;кбе1;кбе2;КНП;Валюта;Страна-теория;Страна;Платеж;Примечание;Менеджер;Ошибки"
skip.

for each t-eknp break by t-eknp.sbanksend by t-eknp.rbanksend by t-eknp.s_locat by t-eknp.s_secek by t-eknp.r_locat by t-eknp.r_secek by t-eknp.knp by t-eknp.gl by t-eknp.crcode by t-eknp.cntsend :
  put stream rep unformatted 
        t-eknp.jdt ";" t-eknp.gl ";" t-eknp.jh1 ";" t-eknp.jh2 ";" t-eknp.sbank ";" t-eknp.sbanksend ";" 
        t-eknp.bank2 " через " t-eknp.cbank " К/Страна " t-eknp.cntcbank ";" t-eknp.rbank ";" t-eknp.rbanksend  ";" 
        t-eknp.ptype ";" XLS-NUMBER (t-eknp.dam) ";" XLS-NUMBER (t-eknp.cam) ";" XLS-NUMBER (t-eknp.sumkzt) ";"
        t-eknp.s_locat ";" t-eknp.s_secek ";" t-eknp.r_locat ";" t-eknp.r_secek ";" t-eknp.knp ";" 
        t-eknp.crcode ";" t-eknp.cnt ";" t-eknp.cntsend ";" t-eknp.rem ";" t-eknp.who ";" t-eknp.errors
        skip.

  /* сделать доп табличку для ГБ*/
  find first t-sv where t-sv.ptype = t-eknp.ptype no-error.
  if not avail t-sv then do:
     create t-sv.
     assign t-sv.ptype = t-eknp.ptype.
  end.
  if t-eknp.crc = 1 then t-sv.sumkzt1 = t-sv.sumkzt1 + t-eknp.sumkzt.
                    else t-sv.sumkzt2 = t-sv.sumkzt2 + t-eknp.sumkzt.

  /****************/   
  


end.
output stream rep close.
unix silent cptwin eknp.csv excel.

output stream rep to eknpmsg.txt.
for each t-eknp break by t-eknp.sbanksend by t-eknp.rbanksend 
                      by t-eknp.s_locat by t-eknp.s_secek 
                      by t-eknp.r_locat by t-eknp.r_secek 
                      by t-eknp.knp by t-eknp.ptype
                      by t-eknp.crcode by t-eknp.cntsend :

   put stream rep t-eknp.jdt " " t-eknp.sub " " t-eknp.gl " " t-eknp.jh1 " " t-eknp.jh2 " " t-eknp.sbank " " t-eknp.sbanksend " (" t-eknp.bank2 " через " 
         t-eknp.cbank " " t-eknp.cntcbank ") " t-eknp.rbank " " t-eknp.rbanksend  " " t-eknp.ptype " " 
         t-eknp.dam " " t-eknp.cam " " t-eknp.sumkzt " "
         t-eknp.s_locat " " t-eknp.s_secek " " t-eknp.r_locat " " 
         t-eknp.r_secek " " t-eknp.knp " " t-eknp.crcode " " t-eknp.cnt " " t-eknp.cntsend " " t-eknp.rem " " t-eknp.who " " t-eknp.errors
         skip.

   ACCUMULATE t-eknp.sumkzt (SUB-TOTAL SUB-COUNT by t-eknp.sbanksend by t-eknp.rbanksend 
                      by t-eknp.s_locat by t-eknp.s_secek 
                      by t-eknp.r_locat by t-eknp.r_secek 
                      by t-eknp.knp by t-eknp.ptype
                      by t-eknp.crcode by t-eknp.cntsend).
   if last-of (t-eknp.cntsend) then do:
      sum = ACCUM SUB-TOTAL by t-eknp.cntsend t-eknp.sumkzt.
/*      if sum > 0 then do:*/
         put stream mt998 unformatted 
           "/INFO/" t-eknp.sbanksend 
           "//" t-eknp.rbanksend 
           "//" t-eknp.ptype format "99" 
           "/" t-eknp.s_locat 
           "/" t-eknp.s_secek 
           "/" t-eknp.r_locat 
           "/" t-eknp.r_secek 
           "/" t-eknp.knp 
           "/" ACCUM SUB-COUNT by t-eknp.cntsend t-eknp.sumkzt 
           "/" trim(replace(string(sum,"->>>>>>>>>>9.99"),".",",")) 
           "/" caps(t-eknp.crcode) 
           "/" caps(t-eknp.cntsend) skip.
/*      end.*/
   end.
end.

put stream rep skip(3) "КУРСОВАЯ РАЗНИЦА" skip(2).

/* дописать курсовые разницы */
for each t-corracc break by t-corracc.sbanksend by t-corracc.rbanksend 
                      by t-corracc.s_locat by t-corracc.s_secek 
                      by t-corracc.r_locat by t-corracc.r_secek 
                      by t-corracc.knp
                      by t-corracc.crc by t-corracc.kz:

   find crc where crc.crc = t-corracc.crc no-lock no-error.
   put stream rep t-corracc.gl " " t-corracc.sbanksend " " t-corracc.rbanksend  " " t-corracc.ptype " " 
         t-corracc.balcurs " " 
         t-corracc.s_locat " " t-corracc.s_secek " " t-corracc.r_locat " " 
         t-corracc.r_secek " " t-corracc.knp " " crc.code " " 
         t-corracc.cnt " " t-corracc.cntsend 
         skip.


   ACCUMULATE t-corracc.balcurs (SUB-TOTAL SUB-COUNT by t-corracc.sbanksend by t-corracc.rbanksend 
                      by t-corracc.s_locat by t-corracc.s_secek 
                      by t-corracc.r_locat by t-corracc.r_secek 
                      by t-corracc.knp
                      by t-corracc.crc by t-corracc.kz).

   if last-of (t-corracc.kz) then do:
      sum = ACCUM SUB-TOTAL by t-corracc.kz t-corracc.balcurs.

      if t-corracc.kz then
        t-corracc.ptype = if sum < 0 then 14 else 15.
      else do:
        if sum < 0 then do:
          t-corracc.ptype =  16.
          /*t-corracc.rbanksend = v-ourbic.*/
        end.
        else do:
          t-corracc.ptype =  17.
          /*t-corracc.sbanksend = v-ourbic.*/
        end.
      end.

      put stream mt998 unformatted 
         "/INFO/" t-corracc.sbanksend 
         "//" t-corracc.rbanksend 
         "//" t-corracc.ptype format "99" 
         "/" t-corracc.s_locat 
         "/" t-corracc.s_secek 
         "/" t-corracc.r_locat 
         "/" t-corracc.r_secek 
         "/" t-corracc.knp 
         "/" ACCUM SUB-COUNT by t-corracc.kz t-corracc.balcurs
         "/" trim(replace(string(abs(sum),">>>>>>>>>>9.99"),".",",")) 
         "/" caps(crc.code) 
         "/" caps(t-corracc.cntsend) skip.

         /* сделать доп табличку для ГБ*/
         find first t-sv where t-sv.ptype = t-corracc.ptype  no-error.
         if not avail t-sv then do:
            create t-sv.
            assign t-sv.ptype = t-corracc.ptype.
         end.
         if t-corracc.crc = 1 then t-sv.sumkzt1 = t-sv.sumkzt1 + abs(sum).
                              else t-sv.sumkzt2 = t-sv.sumkzt2 + abs(sum).
       
         /****************/   

   end.
end.

output stream rep close.


put stream mt998 unformatted "-\}" skip.
output stream mt998 close.
hide message no-pause.

run menu-prt("temp.exp").

def var v-dir as char.
def var v-filename as char init "470eknp.exp".
def var v-ipaddr as char init "ntmain".
def var v-exitcod as char.

find sysc where sysc.sysc = "eknpd" no-lock no-error.
if avail sysc then v-dir = sysc.chval.

message skip " Копировать телеграмму в каталог~n " v-dir "?"
        skip(1) view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-ans as logical.
if v-ans then do:
  unix silent un-dos temp.exp value(v-filename).
  pause 0.
  input through value("scp -q " + v-filename + " Administrator@fs01.metrobank.kz:" + v-dir + ";echo $?").
  repeat :
    import v-exitcod.
  end.
  pause 0.

  if v-exitcod <> "0" then do:
    message skip " Произошла ошибка при копировании сообщения в каталог" skip(1)
            v-dir
            skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  end.

  unix silent rm -f value(v-filename).
  pause 0.

end.

 output to eknpnull.csv append.
 displ "Тип;Тенге;Валюта" skip.
 for each t-sv.
     export delimiter ";" t-sv.
 end. 
 output close.

unix silent cptwin eknpnull.csv excel.
unix silent cptwin error.csv excel.

