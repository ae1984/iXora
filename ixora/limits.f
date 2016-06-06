/* limits.f
 * MODULE
        Ввод лимитов        
 * DESCRIPTION
        Для limits.p
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
        12.12.2005 nataly добавлен признак месяца и года  по лимитам
        17/02/2006 nataly добавлено удаление и копирование лимитов из месяца в месяц
*/


define new shared var v-des as char init "".
define new shared var v-cost like skladc.cost.

define variable subamt as integer.
define variable subcost as decimal.

define var can-exit as logical.
define var v-param as char.
define var v-del as char init "^".
define var v-doc as char.
define var v-dpr like skladh.dpr.
define var v-amt like skladh.amt.
define new shared var s-jh like jh.jh.
define var rcode as integer.
define var rdes as char.
define var yesno as logical.
define var totamt as decimal init 0.
define var totcost as decimal init 0.0.

def var v-mon as integer.
def var v-god as integer.
def var v-dep as char.

def new  shared temp-table  wskitem
     field sid  like limits.sid
     field pid like limits.pid
     field amt like limits.amt.


/*------------------------------------------------------------------------*/

define var cost like skladh.cost.
define var gra1 as integer.
define var gra2 as integer.
define var grc1 as decimal.
define var grc2 as decimal.
define var grdx as decimal.
define var grd1 as decimal.
define var grd2 as decimal.
define var grstr as char.
define var v-deps as char.
define var v-desc as char.

def temp-table blimits like limits.
define frame getsid
            blimits.sid label "Выберите группу (F2 - помощь)" 
            with row 2 centered side-labels.

define frame getpid
            blimits.pid label "Выберите товар (F2 - помощь) "
            with row 2 centered side-labels.   

define frame ff
            v-monnew label "Введите месяц, для к-го необходимо ввести лимиты "  format 'z9'
            v-godnew label "Введите год, для к-го необходимо ввести лимиты   "  format '9999'
            v-monold label "Введите месяц для копирования лимитов            "  format 'z9'
            v-godold label "Введите год для копирования лимитов              "  format '9999'
            with row 2 centered side-labels.   

define frame ff2
            v-mon label "Введите месяц, для к-го надо удалить лимиты "  format 'z9'
            v-god label "Введите год, для к-го надо удалить лимиты   "  format '9999'
            v-dep label "Введите департамент, для к-го надо удалить лимиты,F2-помощь   "  format 'x(3)'
            with row 2 centered side-labels.   

define frame income
           limits.sid  label  "Группа"
           limits.pid  label  "Товар"
           limits.des  format 'x(20)'  label   "Наим-ие ТМЦ" 
           limits.amt  label  "Утв. лимит"
           limits.ost  label  "Остаток ТМЦ"
           limits.dep  label  "Деп"
       with no-labels title "РЕДАКТИРОВАНИЕ ДАННЫХ" row 4  .


define frame income2
           blimits.sid validate(can-find(grp where grp.grp = blimits.sid no-lock ),"Группа не найдена!")  label  "Группа"
           blimits.pid validate(can-find(item where item.grp = blimits.sid and item.item = blimits.pid no-lock ),"Товар не найден!") label  "Товар"
           blimits.des format 'x(30)'  label   "Наим-ие ТМЦ"
           blimits.amt  label  "Утвержденный лимит"
           blimits.dep  label  "Деп"
       with no-labels title "ВВОД ЛИМИТОВ " row 4  .

define frame income3
           v-deps  format 'x(3)' validate(can-find(codfr where codfr = 'sdep' and codfr.code = v-deps no-lock ),"Департамент не найден!") label  "Код департамента "
           v-desc  format 'x(40)' label  "Наименование"
           v-mon   format 'z9'   label 'Месяц' help 'Введите номер месяца'
           v-god   format '9999' label 'Год' help 'Введите номер года'
           with  no-labels title "ВВОД ДАННЫХ" row 4  .

define query qp for limits.

define buffer st_buf for limits.
define var st_amt as decimal format "z,zzz,zzz,zz9".
define var st_sum as decimal format "z,zzz,zzz,zz9.99".


define frame getlistp
            temptrx.dep label "Выберите Департамент (F2 - помощь)" skip
            temptrx.des label "Выберите товар (F2 - помощь) " 
            temptrx.sum label "Сумма для зачисления"
            temptrx.gl label "Счет ГК"  validate(temptrx.gl = 0 or can-find(first gl where gl.gl = 
                     temptrx.gl no-lock), "Счет главной книги не найден")
            with row 2 centered side-labels.

define browse bp query qp
       display
               limits.sid  label "Гр" format "zz9"
               limits.pid  label "Тов" format "zz9"
               limits.des     label "Наименование" format "x(30)"
               limits.amt  format 'zz,zz9.99' label "Утв лимит" 
               limits.ost  format 'zz,zz9.99-' label "Остаток ТМЦ" 
               limits.dep  label  "Деп"
       with 9 down /* size 80 by 9 */ no-label title "Ввод данных".

define frame st
               st_amt label "Итого"
               st_sum label "на сумму"
               with row 15 centered side-labels.

define frame ftp bp
help " [ENTER]-редакт,[INS]-добав,F8-удаление,F2-Отчет,F4-выход"
       skip (1) "ИТОГО"   totamt  format "zzzzzzzzzzzzzz.99" view-as text
       with row 2 centered /*no-box*/. 


define var dfrom as date init today.
define var dto as date init today.

form 
             "Период: с" dfrom 
             validate (dfrom <= today, 
                       "Начало периода не может быть больше, чем сегодня!")
             " по" dto
             validate (dfrom <= dto, 
                      "Конец периода не может быть раньше его начала!")
             with no-label centered row 7 frame fdat.

