/* taxrepnk.p
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

/*

  05.08.2003 nadejda - убрала UDF из условия where
*/

{deparp.i}
{get-dep.i}
{global.i}

{comm-txb.i}
def var ourbank as char.
def var ourcode as integer.
ourbank = comm-txb().
ourcode = comm-cod().

def var dat as date initial today.
def var gr as integer init 0.
def var dlm as char initial "|".

def var fname as char.
def var rnnnk as char.
def var cur-dep like ppoint.depart.
def var report-type as int init 1.

define temp-table ttax like comm.tax
 field dep like ppoint.depart.
def var vofc as char.

define frame fr2
  skip(1) 
  " УКАЖИТЕ ДАТУ                                :  " dat format "99/99/99" skip(1)
  " ВСЕ платежи (1) или платежи ПО ЭТОМУ СПФ (2):  " report-type format "zzz" skip (1)
  with row 8 centered no-label.


update dat report-type with frame fr2.
hide frame fr2.

vofc = g-ofc.
cur-dep = get-dep(vofc, dat).

/* NK */
find first comm.taxnk where comm.taxnk.grp = cur-dep no-lock no-error.

if available comm.taxnk then rnnnk = comm.taxnk.rnn.
else do:
  message skip  "Ваш департамент не привязан к Налоговому Комитету." 
  skip  "Выберите Комитет из списка." view-as alert-box title " Предупреждение ".

/* choice NK */
  run taxnk.p.
  if return-value <> "" then
    rnnnk = return-value.
  else
    return.
end.

for each comm.tax where comm.tax.date = dat and comm.tax.duid = ? and comm.tax.rnn_nk = rnnnk and 
         comm.tax.txb = ourcode no-lock:
    create ttax.
    buffer-copy comm.tax to ttax.
    ttax.dep = get-dep(comm.tax.uid, dat).
end.

DEFINE STREAM s3.
OUTPUT STREAM s3 TO taxrep.log.
fname = "taxrep.log".

find first comm.taxnk where comm.taxnk.rnn = ttax.rnn_nk no-lock no-error.
FIND first ofc WHERE ofc.ofc = vofc NO-LOCK no-error.    

put stream s3 unformatted
g-comp format "x(55)"                             "информация является справочной" skip
"Исполнитель " ofc.name format "x(35)" space(9)  "и не может служить основанием" skip 
"Дата отправки  " today " " string(time,"HH:MM:SS") space (26) "для предъявления претензий" skip(3)
"       Сведения о принятых налогах и других обязательных платежах в бюджет" skip
"               по центру:    " comm.taxnk.name skip
"                              РНН " ttax.rnn_nk skip.

if report-type = 2 then do:
  find first ppoint where ppoint.depart = cur-dep no-lock no-error.
  put stream s3 unformatted
"             по департаменту:    " ppoint.name skip. 
end.

put stream s3 unformatted
"                                за " dat FORMAT "99/99/9999" skip(1).

put stream s3 unformatted
fill("-", 85) format "x(85)" skip
"Nпп|        Наименование налога                           |  Код  |Колич|     Сумма  " format "x(85)" skip
"   |                                                      |платежа|плат.|" format "x(85)" skip
fill("-", 85) format "x(85)" skip.


FOR EACH ttax where ((report-type = 2) and (ttax.dep = cur-dep)) or (report-type = 1) 
   no-lock break by ttax.kb by ttax.sum:

  accumulate ttax.sum
      (total count).

  accumulate ttax.sum
      (sub-total by ttax.kb).

  accumulate ttax.sum
      (sub-count by ttax.kb).
      
  if first-of(ttax.kb) then do:
      find first budcodes where budcodes.code = ttax.kb use-index code no-lock no-error.
      gr = gr + 1.
      put stream s3 unformatted
      gr format "zz9" dlm
      space(1) budcodes.name1 format "x(52)" space(1) dlm 
      space(1) ttax.kb format "999999" dlm.
  end.    

  if last-of(ttax.kb) then do:
  put stream s3 unformatted 
        (accum sub-count by ttax.kb ttax.sum)
        format "zzzz9" dlm
        space(1) (accum sub-total by ttax.kb ttax.sum)
        format ">>>>>>9.99" skip.
  end.
end.

put stream s3 unformatted
    fill("-", 85) format "x(85)" skip
    "Всего " space(60) dlm
    (accum count ttax.sum)
    format "zzzz9" dlm
    space(1) (accum total ttax.sum)
    format ">>>>>>9.99" skip.

OUTPUT STREAM s3 CLOSE.

run menu-prt.p(fname).  

