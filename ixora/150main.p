/* 150main.p
 * MODULE
        Название Программного Модуля
        
 * DESCRIPTION
        Назначение программы, описание процедур и функций
        Ведомость прогнозных платежей с кривым наименованием
        Постановление Правления Национального Банка Республики Казахстан от 25 апреля 2000 года N 179 
        Об утверждении Правил использования платежных документов и осуществления безналичных платежей 
        и переводов денег на территории Республики Казахстан (с изменениями, внесенными постановлениями 
        Правления Нацбанка РК от 29.12.2000 г. N 488; от 18.01.02 г. N 20)

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
 	24.05.2003 nadejda - убраны параметры -H -S из коннекта 
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/
*/



{d-2-u.i} /* Транслятор DOS - Unix */
{comm-txb.i}
{comm-bik.i}
{filesize.i}

def var sel  as integer.
def var selp as integer.
def var ourcode  as integer.
def var ourbik   as char.
def frame  a-show with row 4 centered overlay no-labels title '[ Ждите ]'.
def var v-file as char no-undo init ''.
def var v-refs as char.
def var ds     as dec  decimals 2 no-undo format '>>>,>>>,>>>,>>9.99'.
def var dss    as dec  decimals 2 no-undo format '>>>,>>>,>>>,>>9.99'.
def var accnt  as integer no-undo format '999999999'.
def var faccnt as integer no-undo format '999999999'.
def var i       as integer no-undo.
def var ourbank as char no-undo format 'x(09)'.
def var errors as char extent 5 format "x(50)".
def var log    as logical init false.
def var err    as logical init false.
def var msg    as char.
def var tmp    as char.
def var stmp   as char.
def var tmpout as char.

ourcode = comm-cod().
ourbik  = comm-bik().


v-refs = trim(OS-GETENV("HOME")) + "/150ref.txt".

find first bank.sysc where bank.sysc.sysc = "150fle" no-lock no-error.
if avail bank.sysc then v-file = trim(bank.sysc.chval). 
                   else v-file = "/data/import/150.txt".

if filesize(v-file) < 1 then do:
       message "Прогнозных платежей, на сегодня, пока нет." view-as alert-box.
       undo,leave.
end.

if ourcode = 0 then do:
                    run sel('Сформировать','Сводный реестр|По текущему офису').
                    sel = integer(return-value).
               end. 
               else sel = 2. /* Для филиалов */

run sel('Обработать','Новые платежи|Все платежи').
selp = integer(return-value).

/*
sel(работает только в TXB00):
1 - показать по всем филиалам, 2 - показать по текущему офису

selp:
1 - показать только новые, 2 - показать все за сегодня
*/

display "Идет обработка данных..." skip with frame a-show.

def new shared temp-table tmp150
field nr        as integer
field dt        as date
field ref       as char format "x(16)"
field sbank     as char format "x(9)"
field saccnt    as char format "x(9)"
field dbank     as char format "x(9)"
field daccnt    as char format "x(9)"
field amt       as decimal
field sys       as char format "x(8)"
field vdat      as char format "x(6)"
field srnn      as char format "x(12)"
field drnn      as char format "x(12)"
field sender    as char format "x(75)"
field dest      as char format "x(75)"
field final     as char format "x(8)"
field details   as char format "x(75)"
field err       as logical
field msg       as char format "x(75)"
index nr is primary nr ref DESCENDING.

def new shared temp-table clients
field ourcode as integer format "9"
field cif       like bank.cif.cif
field ownform   as char format "x(10)"
field name      like bank.cif.name
field sname     like bank.cif.sname
field point     like bank.cif.point
field depart    like bank.cif.depart
index ourcode is primary ourcode
index cif cif.

def new shared temp-table accounts
field t         as char format "x(3)"
field cif       like bank.cif.cif
field aaa       like bank.aaa.aaa
field ourbik    as char format "x(9)"
index cif cif
index aaa aaa
index ourbik ourbik.

def new shared temp-table ref150
field ref       as char format "x(16)"
field l         as logical init false
index ref ref.

def buffer t150 for tmp150.

    message "Импорт данных...".
    i = 0.
    input from value( v-file ) no-echo.
    repeat:
      i = i + 1.
      IMPORT unformatted stmp NO-ERROR.
      if trim(entry(1,stmp))<>"" then do:
           create tmp150.
           assign tmp150.nr=i
           tmp150.dt    = date(entry(1,stmp,"|"))
           tmp150.ref   = entry(2,stmp,"|")
           tmp150.sbank = entry(3,stmp,"|")
           tmp150.saccnt        = entry(4,stmp,"|")     
           tmp150.dbank = entry(5,stmp,"|")
           tmp150.daccnt        = entry(6,stmp,"|")
           tmp150.amt   = decimal(entry(7,stmp,"|"))
           tmp150.sys   = entry(8,stmp,"|")
           tmp150.vdat  = entry(9,stmp,"|")
           tmp150.srnn  = entry(10,stmp,"|")
           tmp150.drnn  = entry(11,stmp,"|")
           tmp150.sender = trim(entry(12,stmp,"|"))
           tmp150.dest  = trim(entry(13,stmp,"|"))
           tmp150.final = trim(entry(14,stmp,"|"))
           tmp150.details = trim(entry(15,stmp,"|")).
      end.
    end.
    input close. pause 0.
/** for test
    output to 15000.txt.
    for each tmp150.
    put unformatted 
      tmp150.dt     "|"
      tmp150.ref    "|"
      tmp150.sbank  "|"
      tmp150.saccnt "|"
      tmp150.dbank  "|"
      tmp150.daccnt "|"
      tmp150.amt    "|"
      tmp150.sys    "|"
      tmp150.vdat   "|"  
      tmp150.srnn   "|"  
      tmp150.drnn   "|"  
      tmp150.sender "|"    
      tmp150.dest   "|"  
      tmp150.final  "|"   
      tmp150.details skip.
     end.           
    output close. pause 0.
**/
    file-info:file-name = v-refs.
    if file-info:file-type <> ? then do:
/*          message "Импорт 150ref.txt...".*/
            input from value( v-refs ) no-echo.
            repeat:
              create ref150.
              IMPORT ref150 except l NO-ERROR.
              ref150.l = false.
            end.
            input close.
    end. /* if */

   output to ref.txt.
   for each ref150.
   disp ref150.
   end.
   output close. pause 0.

   /* Подчистим мусор */
   for each ref150.
      find first tmp150 where tmp150.ref = ref150.ref no-error.
      if not avail tmp150 then delete ref150.
   end.
   for each ref150 where ref150.ref="". delete ref150. end.

   for each tmp150.
      find first ref150 where ref150.ref = tmp150.ref no-error.
      if not avail ref150 then do:
        create ref150.
        ref150.ref = tmp150.ref.
        ref150.l = true.
      end.
   end.

/*   message "Сбор по филиалу/ам...".*/
   if sel = 1 then do:
            {r-brancha.i &proc="150cifs.p(comm.txb.txb)"}
   end. 
   else do:
            if not connected ("comm") then run conncom.

            find first comm.txb where comm.txb.txb = ourcode no-lock no-error.

            if connected ("ast") then disconnect "ast".

            connect value("-db " + comm.txb.path + " -H "  + comm.txb.host + " -S " + comm.txb.service + " -ld ast -U " + comm.txb.login + " -P " + comm.txb.password). 

            run 150cifs (ourcode).
                
            if connected ("ast")  then disconnect "ast".
            if connected ("comm") then disconnect "comm".

            /* Уберем не наши филиалы */
            for each tmp150 where tmp150.dbank <> ourbik:
             delete tmp150.
            end.
   end.

/*   message "Вывод в файл...". */
   output to rpt.img.
   put unformatted space(15) "Ведомость прогнозных платежей для зачисления на 902 счет " skip
   "Сформирована " string(today,"99.99.99") "г. в " string(time,"HH:MM:SS")  skip (1)
   fill("-", 80) format "x(80)" skip.

   i = 0.

   for each tmp150 use-index nr break by tmp150.ref.

        if first-of(tmp150.ref) then do:
                log = true. /* новые платежи или все */
                if selp = 1 then do:
                        find first ref150 no-lock where ref150.ref = tmp150.ref and ref150.l = true no-error .
                        if not avail ref150 then log = false.
                end.
                if log = true then do:
                           {150-name.i}
        
                end.
        end.

   end.

   put unformatted fill("-", 80) format "x(80)" skip
   " Всего: " trim(string(i))  "  Сумма: " trim(string(dss,'>>>,>>>,>>>,>>9.99')) skip.

/*   for each clients:
     for each accounts where accounts.cif = clients.cif.
       put unformatted clients.cif " " accounts.aaa " " clients.name skip.
     end.
   end. */

   output close. pause 0.

   /* Запишем текущие референсы провереных платежей */
   output to value(trim(OS-GETENV("HOME")) + "/150ref.txt").
   for each ref150:
     put unformatted ref150.ref skip.
   end.
   output close. pause 0.

   /* Запишем текущие референсы провереных платежей 
   output to value(trim(OS-GETENV("HOME")) + "/150tmp.txt").
   for each tmp150:
     disp tmp150.ref tmp150.dbank tmp150.daccnt tmp150.dest skip.
   end.
   output close. */

   if i > 0 then run menu-prt("rpt.img").
            else if selp=2 then MESSAGE "Ошибочных платежей не найдено." VIEW-AS ALERT-BOX QUESTION BUTTONS OK TITLE "Внимание".
                           else MESSAGE "Новых ошибочных платежей не найдено." VIEW-AS ALERT-BOX QUESTION BUTTONS OK TITLE "Внимание".

