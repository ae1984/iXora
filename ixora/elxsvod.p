/* elxvod.p
 * MODULE
        Elecsnet
 * DESCRIPTION
        Сводный отчет по всем видам платежей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
         5-4-16-16-4
 * AUTHOR
        05/05/2006 dpuchkov
 * CHANGES
        18.10.2006 u00124 добавил в отчет платежи Казахтелеком
        12.02.2007 id00004 добавил alias
*/


{global.i}
{get-dep.i}

{comm-txb.i}
def var seltxb as int no-undo.
seltxb = comm-cod().

def var v-date-begin as date no-undo.
def var v-date-fin as date   no-undo.

define temp-table ttax no-undo like tax 
    field dep like ppoint.depart
    field name like commonls.bn.

define temp-table tcommpl no-undo like commonpl 
    field dep like ppoint.depart
    field name as char.

define temp-table tcommpl1 no-undo like commonpl 
    field dep like ppoint.depart
    field name as char.

define temp-table payment1 no-undo like p_f_payment 
    field dep like ppoint.depart.

define temp-table payment2 no-undo like p_f_payment 
    field dep like ppoint.depart.

define temp-table almpay no-undo like comm.almatv 
    field dep like ppoint.depart.

def var dlm as char init "|"  no-undo.

def var v-report-name as char no-undo.
def var usrnm as char         no-undo.
def var v-grp as char         no-undo. 
def var v-sum as decimal      no-undo.

def var v-param-list as char init "4,5,6,7,8,9,10" no-undo.

def temp-table ttmps
    field type as integer
    field kol as decimal
    field sum as decimal
    field comsum as decimal
    field name as char
    field dep as integer
INDEX type_idx  type 
INDEX dep_idx  dep .



v-date-begin = g-today.
v-date-fin = v-date-begin.

update v-date-begin format '99/99/9999' label " Начальная дата " 
       v-date-fin format '99/99/9999' label " Конечная дата " 
with centered frame df.

def var v-operation as char no-undo.

   run sel ("Выберите тип операции", "1. -- СВОДНЫЙ ОТЧЕТ -- |" +
                                     "2. -- ВЫХОД -- ").

       case return-value:
          when "1" then v-operation = "1".
          when "2" then v-operation = "2".
          when "3" then v-operation = "3".
          when "4" then v-operation = "4".
          when "5" then v-operation = "5".
          when "6" then v-operation = "6".
          when "7" then v-operation = "7".
          when "8" then v-operation = "8".
          when "9" then v-operation = "9".
          when "10" then v-operation = "10".
          when "11" then v-operation = "11".
          when "12" then v-operation = "12".
          when "13" then v-operation = "13".
          when "14" then v-operation = "14".
          when "15" then v-operation = "15".
       end.

  v-grp = "ALL".

  if v-operation = "2" then return. 

  if v-operation = "1" then v-grp = "ALL".










  if v-operation = "1" then do:
      for each mobi-almatv no-lock :
          accumulate mobi-almatv.summ (TOTAL COUNT).
      end.

      create ttmps.
             ttmps.type = 5.
             ttmps.kol = (accum total mobi-almatv.summ).
             ttmps.sum = (accum count mobi-almatv.summ). 
             ttmps.name = "Алма-тв".
             ttmps.dep = 1.

      for each mobi-telecom no-lock :
          accumulate mobi-telecom.amt (TOTAL COUNT).
      end.

      create ttmps.
             ttmps.type = 6.
             ttmps.kol = (accum total mobi-telecom.amt).
             ttmps.sum = (accum count mobi-telecom.amt).
             ttmps.name = "Казахтелеком".
             ttmps.dep = 1.


  end. /* if v-operation = "1" then ... */










find first ttmps no-lock no-error.
if available ttmps then do:

  if v-operation = "1" then v-report-name  = " Сводный отчет по всем видам платежей ".
  else 
  if v-operation = "2" then v-report-name  = " Сведения по платежам АЛМАТВ ".

  output to reprko.txt.

  find first ofc where ofc.ofc = g-ofc no-lock no-error.
  if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

  put unformatted
    g-comp format "x(55)" skip
    "Исполнитель " usrnm format "x(35)" skip 
    "Дата  " today " " string(time,"HH:MM:SS") skip(3)
    v-report-name  skip(1)
    "    за период с " v-date-begin FORMAT "99/99/9999" " по " v-date-fin FORMAT "99/99/9999" skip(2)
            fill("-", 80) format "x(80)" skip
    " Назначение платежа            " dlm "       Сумма" dlm "      Кол.платежей" dlm /*"      Комиссия " dlm*/ skip
            fill("-", 80) format "x(80)" skip.

  for each ttmps no-lock break by ttmps.dep by ttmps.type.

    accumulate ttmps.kol (sub-total by ttmps.dep).
      
    accumulate ttmps.sum (sub-total by ttmps.dep).


    accumulate ttmps.kol (total).
      
    accumulate ttmps.sum (total).



    if first-of(ttmps.dep) then do:
      find first ppoint where ppoint.point = 1 and ppoint.depart = ttmps.dep no-lock no-error.
      put unformatted
         skip(1) "     " ppoint.name skip 
         fill("-", 80) format "x(80)" skip.
    end.

    put unformatted  
        " " ttmps.name format "x(29)" " " dlm
        " " ttmps.kol format ">>>>>>>>>9" " " dlm 
        " " ttmps.sum format ">>>>>>>>>>>>9.99" " " dlm skip.


    if last-of(ttmps.dep) then do:
      put unformatted  
        fill("-", 80) format "x(80)" skip
          "     Итого" space(21) dlm
        " " (accum sub-total by ttmps.dep ttmps.kol) format ">>>>>>>>>9" " " dlm
        " " (accum sub-total by ttmps.dep ttmps.sum) format ">>>>>>>>>>>>9.99" " " dlm skip
        fill("-", 80) format "x(80)" skip.
    end.
  end.


  put unformatted
      fill("-", 80) format "x(80)" skip
      "     Всего"  space(21) dlm
      " " (accum total ttmps.kol) format ">>>>>>>>>9" " " dlm
      " " (accum total ttmps.sum) format ">>>>>>>>>>>>9.99" " " dlm skip
      fill("-", 80) format "x(80)" skip.

  output close.
  run menu-prt ("reprko.txt").

end. /* if avail ttmps then ... */
else do:
message "Платежей не найдено" view-as alert-box title "Внимание".
return.
end.


