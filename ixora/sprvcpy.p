/* sprvcpy.p
 * MODULE
       Коммунальные и налоговые платежи
 * DESCRIPTION
       Процедура фориирования и копирования справочников системы для Offline PragmaTX
 * RUN

 * CALLER
        
 * SCRIPT

 * INHERIT

 * MENU
       
 * AUTHOR
        04/02/04 kanat
 * CHANGES
        25/05/04 kanat - Добавил удаление файлов перед их копирование на сервер
        01/06/04 kanat - Добавил для филиала в г. Уральск другое условие по офицерам
        26/08/04 kanat - Вследствие единой смены логинов установил единые правила формирования дампа по офицерам
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
  05.12.2005 u00121 - поправил выборку юзеров для Уральск (Tellers), а Уральские юзеры не выгружались
  08.12.2005 u00121 - отключил т.к. у кассиров есть возможность самостоятельно изменять курсы валют, а загрузка с flash вносит путаницу с последними
  16.08.2006 u00568 Evgeniy - добавил инспекторов НК
*/

/* не смейтесь - но так надо ... */

{comm-txb.i}
def var v-choice as char.
def var v-filename as char.
def var seltxb as integer.
def var v-txb-choice as char.

seltxb = comm-cod().

   run sel ("Выберите справочник: ", "1.  Пенсионные фонды  |" +
                                     "2.  Налоговые комитеты|" +
                                     "3.  Тарифы            |" +
                                     "4.  Комм. получатели  |" +
                                     "5.  Коды бюджета      |" +
                                     "6.  Банки             |" +
                                     "7.  Валюта            |" +
                                     "8.  Структ. подразд.  |" +
                                     "9.  Пользователи      |" +
                                     "10. Филиал            |" +
                                     "11. Настройки (sysc)  |" +
                                     "12. Инспектора НК    ").


       case return-value:
          when "1"  then v-choice = "PENSIONS".
          when "2"  then v-choice = "TAXES".
          when "3"  then v-choice = "TARIFS".
          when "4"  then v-choice = "COMMONLS".
          when "5"  then v-choice = "BUDGETS".
          when "6"  then v-choice = "BANKS".
          when "7"  then v-choice = "CURRENS".
          when "8"  then v-choice = "RKOS".
          when "9"  then v-choice = "TELLERS".
          when "10" then v-choice = "BRANCHES".
          when "11" then v-choice = "WHOLES".
          when "12" then v-choice = "INSPECTORS_NK".
       end.


if v-choice = "PENSIONS" then do:
/* p_f_list table export */
def stream str_out.
output stream str_out to p_f_list.d.

for each p_f_list no-lock.
export stream str_out p_f_list.
end.

output stream str_out close.
v-filename = "p_f_list.d".


/* само копирование ... */
unix silent value("rm -f " + trim(OS-GETENV("DBDIR")) + "/export/offpl/" + v-filename).
unix silent value("rcp" + " `askhost`: " + v-filename + " "  + trim(OS-GETENV("DBDIR")) + "/export/offpl/").

end.


if v-choice = "TAXES" then do:
/* taxnk table export */
output stream str_out to taxnk.d.

for each taxnk no-lock.
export stream str_out taxnk.
end.

output stream str_out close.
v-filename = "taxnk.d".

/* само копирование ... */
unix silent value("rm -f " + trim(OS-GETENV("DBDIR")) + "/export/offpl/" + v-filename).
unix silent value("rcp" + " `askhost`: " + v-filename + " " + trim(OS-GETENV("DBDIR")) + "/export/offpl/").

end.


if v-choice = "TARIFS" then do:
/* tarif table export */
output stream str_out to tarif.d.

for each tarif where tarif.stat = "r" no-lock.
export stream str_out tarif.
end.

output stream str_out close.
v-filename = "tarif.d".

/* само копирование ... */
unix silent value("rm -f " + trim(OS-GETENV("DBDIR")) + "/export/offpl/" + v-filename).
unix silent value("rcp" + " `askhost`: " + v-filename + " "  + trim(OS-GETENV("DBDIR")) + "/export/offpl/").


/* tafif2 table export */
output stream str_out to tarif2.d.

for each tarif2 where tarif2.stat = 'r' no-lock.
export stream str_out tarif2.
end.

output stream str_out close.
v-filename = "tarif2.d".

/* само копирование ... */
unix silent value("rm -f " + trim(OS-GETENV("DBDIR")) + "/export/offpl/" + v-filename).
unix silent value("rcp" + " `askhost`: " + v-filename + " "  + trim(OS-GETENV("DBDIR")) + "/export/offpl/").

end.



if v-choice = "COMMONLS" then do:
/* commonls table export */
output stream str_out to commonls.d.

for each commonls no-lock.
export stream str_out commonls.
end.

output stream str_out close.
v-filename = "commonls.d".

/* само копирование ... */
unix silent value("rm -f " + trim(OS-GETENV("DBDIR")) + "/export/offpl/" + v-filename).
unix silent value("rcp" + " `askhost`: " + v-filename + " "  + trim(OS-GETENV("DBDIR")) + "/export/offpl/").

end.


if v-choice = "BUDGETS" then do:
/* budcodes table export */
output stream str_out to budcodes.d.

for each budcodes no-lock.
export stream str_out budcodes.
end.

output stream str_out close.

v-filename = "budcodes.d".

/* само копирование ... */
unix silent value("rm -f " + trim(OS-GETENV("DBDIR")) + "/export/offpl/" + v-filename).
unix silent value("rcp" + " `askhost`: " + v-filename + " "  + trim(OS-GETENV("DBDIR")) + "/export/offpl/").

end.


if v-choice = "BANKS" then do:
/* bankl table export */
output stream str_out to bankl.d.

for each bankl no-lock.
export stream str_out bankl.
end.

output stream str_out close.
v-filename = "bankl.d".

/* само копирование ... */
unix silent value("rm -f " + trim(OS-GETENV("DBDIR")) + "/export/offpl/" + v-filename).
unix silent value("rcp" + " `askhost`: " + v-filename + " "  + trim(OS-GETENV("DBDIR")) + "/export/offpl/").

end.


if v-choice = "CURRENS" then do:
  message "Функция отключена администратором АБПК!" view-as alert-box. /*u00121 08.12.2005 отключил т.к. у кассиров есть возможность самостоятельно изменять курсы валют, а загрузка с flash вносит путаницу с последними*/
/*
  /* crc table export */
  output stream str_out to crc.d.

    for each crc no-lock.
      export stream str_out crc.
    end.

  output stream str_out close.
  v-filename = "crc.d".

  /* само копирование ... */
  unix silent value("rm -f " + trim(OS-GETENV("DBDIR")) + "/export/offpl/" + v-filename).
  unix silent value("rcp" + " `askhost`: " + v-filename + " "  + trim(OS-GETENV("DBDIR")) + "/export/offpl/").
*/
end.


if v-choice = "RKOS" then do:
/* ppoint table export */
output stream str_out to ppoint.d.

for each ppoint no-lock.
export stream str_out ppoint.
end.

output stream str_out close.
v-filename = "ppoint.d".

/* само копирование ... */
unix silent value("rm -f " + trim(OS-GETENV("DBDIR")) + "/export/offpl/" + v-filename).
unix silent value("rcp" + " `askhost`: " + v-filename + " "  + trim(OS-GETENV("DBDIR")) + "/export/offpl/").


/* depaccnt table export */
output stream str_out to depaccnt.d.

for each depaccnt no-lock.
export stream str_out depaccnt.
end.

output stream str_out close.
v-filename = "depaccnt.d".

/* само копирование ... */
unix silent value("rm -f " + trim(OS-GETENV("DBDIR")) + "/export/offpl/" + v-filename).
unix silent value("rcp" + " `askhost`: " + v-filename + " "  + trim(OS-GETENV("DBDIR")) + "/export/offpl/").

end.

if v-choice = "TELLERS" then do:
/* _user table report */

if seltxb = 0 then /*Алматы*/
v-txb-choice = "A".

if seltxb = 1 then /*Астана*/
v-txb-choice = "B".

if seltxb = 2 then /*Уральск*/
v-txb-choice = "C".

if seltxb = 3 then /*Атырау*/
v-txb-choice = "D".

output stream str_out to _user.d.

for each _user no-lock.
find first ofc where ofc.ofc = _user._userid and ofc.titcd begins v-txb-choice no-lock no-error.
     if avail ofc then do:
     export stream str_out _user.
     end.
end.

output stream str_out close.
v-filename = "_user.d".

/* само копирование ... */
unix silent value("rm -f " + trim(OS-GETENV("DBDIR")) + "/export/offpl/" + v-filename).
unix silent value("rcp" + " `askhost`: " + v-filename + " "  + trim(OS-GETENV("DBDIR")) + "/export/offpl/").


/* cif table export */
output stream str_out to ofc.d.

for each ofc where ofc.titcd begins v-txb-choice no-lock.
export stream str_out ofc.
end.

output stream str_out close.
v-filename = "ofc.d".

/* само копирование ... */
unix silent value("rm -f " + trim(OS-GETENV("DBDIR")) + "/export/offpl/" + v-filename).
unix silent value("rcp" + " `askhost`: " + v-filename + " "  + trim(OS-GETENV("DBDIR")) + "/export/offpl/").
end.


if v-choice = "BRANCHES" then do:
/* cmp table export */
output stream str_out to cmp.d.

for each cmp no-lock.
export stream str_out cmp.
end.

output stream str_out close.
v-filename = "cmp.d".

/* само копирование ... */
unix silent value("rm -f " + trim(OS-GETENV("DBDIR")) + "/export/offpl/" + v-filename).
unix silent value("rcp" + " `askhost`: " + v-filename + " "  + trim(OS-GETENV("DBDIR")) + "/export/offpl/").

end.


if v-choice = "WHOLES" then do:
/* cmp table export */
output stream str_out to sysc.d.

for each sysc no-lock.
export stream str_out sysc.
end.

output stream str_out close.
v-filename = "sysc.d".

/* само копирование ... */
unix silent value("rm -f " + trim(OS-GETENV("DBDIR")) + "/export/offpl/" + v-filename).
unix silent value("rcp" + " `askhost`: " + v-filename + " "  + trim(OS-GETENV("DBDIR")) + "/export/offpl/").

end.


if v-choice = "INSPECTORS_NK" then do:
  /* insp.d table export */
  def stream str_out.
  output stream str_out to insp.d.
  for each inspectors_nk no-lock.
    export stream str_out inspectors_nk.
  end.
  output stream str_out close.
  v-filename = "insp.d".
  /* само копирование ... */
  unix silent value("rm -f " + trim(OS-GETENV("DBDIR")) + "/export/offpl/" + v-filename).
  unix silent value("rcp" + " `askhost`: " + v-filename + " "  + trim(OS-GETENV("DBDIR")) + "/export/offpl/").

end.
