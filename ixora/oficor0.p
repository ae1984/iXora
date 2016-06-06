/* oficor0.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Отчет о правах пользователя по логину, логин передается как параметр
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        oficor.p        
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        9-1-5-9-2 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        30.10.2002 nadejda - добавлен список прав на функции платежной системы и ограниченные пункты верхнего меню
        23.08.04 sasco добавил обработку пакетов
        23.11.04 u00121 изменил способ поиска прав на шаблоны, ПС, меню. Теперь все работает быстрее
                было так:
                         repeat i = 1 to NUM-ENTRIES (optitsec.ofcs):
                            s = ENTRY (i, optitsec.ofcs).
                            if can-find (first tmp where tmp.tmpl = optitsec.proc and tmp.ofc = s) then next.
                            create tmp.
                            update tmp.ofc = s
                                   tmp.tmpl = trim(optitsec.proc).
                         end.
                теперь так:
                        if lookup(v-ofc,optitsec.ofcs) > 0 then
                        do:
                                create tmp.
                                update tmp.ofc = v-ofc tmp.tmpl = trim(optitsec.proc).
                        end.
        23.03.05 u00121 теперь отчет показывает название существующих у пользователя пакетов
*/


def input parameter v-ofc like ofc.ofc.

define variable pakets as character.
define variable pi as integer.

def shared var g-today as date.
DEF var por LIKE nmenu.fname.
DEF var num AS char.
DEF var ks AS inte init 0.
DEF WORKFILE ret
  FIELD des AS char FORMAT "x(45)"
  FIELD fname LIKE nmdes.fname
  FIELD num AS char FORMAT "x(28)".

define var i as integer.
define var s as char.
define temp-table tmp
       field ofc as char
       field tmpl as char.

procedure get_pakets.
   define variable ggi as integer.
   define input parameter wofc as char.
   define variable wpar as character.

   find ofc where ofc.ofc = wofc no-lock no-error.
   if not avail ofc then return.

   if lookup (wofc, pakets) > 0 then return.
   wpar = trim(ofc.expr[1]).

   pakets = pakets + "," + wofc.
   do ggi = 1 to num-entries (wpar):
      find ofc where ofc.ofc = entry(ggi, wpar) no-lock no-error.
      run get_pakets (entry(ggi, wpar)).
   end.      
end procedure.

/* */


def stream sta.
def var van as log FORMAT "да/нет" LABEL "да/нет" init "нет".
def buffer b-ofc for ofc. /*u00121 23/03/2005 - буффер для таблицы ofc, для определения названия пакета*/
def var bv-ofcname as char. /*u00121 23/03/2005 - сюда пишем найденное название пакета*/


OUTPUT stream sta TO rpt.img.

find ofc where ofc.ofc = v-ofc no-lock no-error.

PUT stream sta SKIP(3).
PUT stream sta "ПРАВА ДОСТУПА В СИСТЕМЕ 'PRAGMA'. "  g-today  "  "  
string(time,"HH:MM:SS") SKIP(0).
PUT  stream sta ofc.name skip      "login:   " ofc   SKIP.

/****************************************************************************************************************************/
put stream sta skip(2) "*** ДОСТУПНЫЕ ПАКЕТЫ ДОСТУПА ***" skip(1).

pakets = ''.
run get_pakets (v-ofc).
pakets = substr (pakets, 2).
find ofc where ofc.ofc = v-ofc no-lock no-error.

do pi = 1 to num-entries (pakets):
   if entry (pi, pakets) = v-ofc then next.
   if lookup (entry (pi, pakets), ofc.expr[1]) > 0 then 
   do:
        /*найдем название пакета**u00121 23/03/2005*****************************/
        find last b-ofc where b-ofc.ofc = entry (pi, pakets) no-lock no-error.
        if avail b-ofc then 
                bv-ofcname = b-ofc.name.
        else
                bv-ofcname = " Пакет не зарегистрирован!!! ".
        /***********************************************************************/
        PUT stream sta unformatted entry (pi, pakets) AT 5 " " bv-ofcname SKIP.
   end.
end.

do pi = 1 to num-entries (pakets):
   if entry (pi, pakets) = v-ofc then next.
   if lookup (entry (pi, pakets), ofc.expr[1]) = 0 then 
   do:
        /*найдем название пакета**u00121 23/03/2005*****************************/
        find last b-ofc where b-ofc.ofc = entry (pi, pakets) no-lock no-error.
        if avail b-ofc then 
                bv-ofcname = b-ofc.name.
        else
                bv-ofcname = " Пакет не зарегистрирован!!! ".
        /***********************************************************************/
        PUT stream sta entry (pi, pakets) AT 5 " " bv-ofcname " (унаследован)" SKIP.
   end.
end.
/****************************************************************************************************************************/

/****************************************************************************************************************************/
put stream sta skip(2) "*** ДОСТУПНЫЕ ПУНКТЫ МЕНЮ ***" skip(1).
FOR EACH sec WHERE sec.ofc = v-ofc NO-LOCK.
  FOR EACH nmdes WHERE nmdes.fname = sec.fname
      AND nmdes.lang = "RR" NO-LOCK.
    num = "".
    por = sec.fname.
    REPEAT:
      FIND nmenu WHERE nmenu.fname = por   NO-LOCK NO-ERROR.
      IF AVAILABLE nmenu THEN
      DO:
        num = trim(string(nmenu.ln,"z9")) + "." + num.
        IF nmenu.father  =  "menu" THEN
        LEAVE.
        por = nmenu.father.
      END.
      ELSE
      DO:
        num = "".
        LEAVE.
      END.
    END.
    IF num ne "" THEN
    DO:
    CREATE ret.
    ret.des = nmdes.des.
    ret.fname = nmdes.fname.
    ret.num = num.
    END.
  END.
END.


  FOR EACH ret BREAK BY ret.num:
    PUT stream sta ret.num AT 2 ret.des AT 31 ret.fname AT 77 SKIP.
  END.
/****************************************************************************************************************************/


/****************************************************************************************************************************/
put stream sta skip(2) "*** ДОСТУПНЫЕ ШАБЛОНЫ ***" skip(1).

for each tmp. delete tmp. end.

/* u00121 23/11/2004 */
for each ujosec no-lock:
    if lookup(v-ofc,ujosec.officers) > 0 then
    do:
       create tmp.
       update tmp.ofc = v-ofc tmp.tmpl = ujosec.template.
    end.
end.
/* u00121 23/11/2004 */

for each tmp where tmp.ofc = v-ofc break by tmp.tmpl:
  find trxhead where caps(trxhead.system + string(trxhead.code, "9999")) = caps(tmp.tmpl) no-lock no-error.
  put stream sta tmp.tmpl format "x(8)" "  " trxhead.des format "x(70)" skip.
end.    
/****************************************************************************************************************************/

/****************************************************************************************************************************/
put stream sta skip(2) "*** ДОСТУПНЫЕ ФУНКЦИИ ПЛАТЕЖНОЙ СИСТЕМЫ ***" skip(1).

for each tmp. delete tmp. end.

/* u00121 23/11/2004 */
for each pssec no-lock:
        if lookup(v-ofc,pssec.ofcs) > 0 then
        do:
                create tmp.
                update tmp.ofc = v-ofc tmp.tmpl = trim(pssec.proc).
        end.
end.
/* u00121 23/11/2004 */

for each tmp where tmp.ofc = v-ofc break by tmp.tmpl:
  s = "".
  find last optitem where trim(optitem.proc) = tmp.tmpl no-lock no-error.
  if avail optitem then do:
    find optlang where optlang.optmenu = optitem.optmenu and optlang.ln = optitem.ln and 
       optlang.lang = "rr" no-lock no-error.

    for each optitem where trim(optitem.proc) = tmp.tmpl no-lock:
      find optmenu where optmenu.optmenu = optitem.optmenu no-lock no-error.
      if avail optmenu then do:
        if s <> "" and optmenu.des <> "" then s = s + "; ".
        s = s + optmenu.des.
      end.
    end.
    find last optitem where trim(optitem.proc) = tmp.tmpl no-lock no-error.
  end.
  put stream sta tmp.tmpl format "x(15)" "  " 
     if avail optitem and avail optlang then optlang.menu else "" format "x(20)" "  "
     s format "x(70)"
     skip.
end.    
/****************************************************************************************************************************/

/****************************************************************************************************************************/
/* доступные верхнего меню, к которым есть ограничение доступа (кроме платежной системы) */
put stream sta skip(2) "*** ПУНКТЫ ВЕРХНЕГО МЕНЮ С ОГРАНИЧЕНИЕМ ДОСТУПА ***" skip(1).
for each tmp. delete tmp. end.

/* u00121 23/11/2004 */
for each optitsec no-lock:
        if lookup(v-ofc,optitsec.ofcs) > 0 then
        do:
                create tmp.
                update tmp.ofc = v-ofc tmp.tmpl = trim(optitsec.proc).
        end.
end.
/* u00121 23/11/2004 */

for each tmp where tmp.ofc = v-ofc break by tmp.tmpl:
  s = "".
  find last optitem where trim(optitem.proc) = tmp.tmpl no-lock no-error.
  if avail optitem then do:
    find optlang where optlang.optmenu = optitem.optmenu and optlang.ln = optitem.ln and 
       optlang.lang = "rr" no-lock no-error.

    for each optitem where trim(optitem.proc) = tmp.tmpl no-lock:
      find optmenu where optmenu.optmenu = optitem.optmenu no-lock no-error.
      if avail optmenu then do:
        if s <> "" and optmenu.des <> "" then s = s + "; ".
        s = s + optmenu.des.
      end.
    end.
    find last optitem where trim(optitem.proc) = tmp.tmpl no-lock no-error.
  end.
  put stream sta tmp.tmpl format "x(15)" "  " 
     if avail optitem and avail optlang then optlang.menu else "" format "x(20)" "  "
     s format "x(70)"
     skip.
end.    
/****************************************************************************************************************************/

PUT stream sta skip(2) 
  "          Руководитель                            /                          /" skip
  "         подразделения " skip(1)
  "                  Дата                       "" _____ "" _______________ 20___ г." skip.

OUTPUT stream sta close.

hide frame fff.
