/* Lchelp2.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        поиск аккредитива с определенным статусом по части номера
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        24/11/2010 galina
 * BASES
        BANK COMM
 * CHANGES
   23/12/2010 Vera   - изменился frame frlc (добавлено 3 новых поля)
   25/02/2011 id00810 - для всех видов аккредитивов
   21/06/2011 id00810 - изменила условие поиска по статусу
   20/07/2011 id00810 - убрала определение формы и связанных с ней переменных
   18/01/2012 id00810 - изменила индекс
*/

{mainhead.i}
def input parameter p-sts as char.
/*def shared var v-cif as char.
def shared var v-cifname as char.
def shared var v-lcsts as char.
def shared var v-lcerrdes as char.*/
def shared var s-lc like LC.LC.
def shared var s-ourbank as char no-undo.
/*def shared var v-find as logi.
def shared var v-lcsumcur as deci.
def shared var v-lcsumorg as deci.
def shared var v-lccrc1 as char.
def shared var v-lccrc2 as char.
def shared var v-lcdtexp as date.*/
def shared var s-lcprod  as char.

/*{LC.f}*/

{itemlist.i
 &file    = "LC"
 &frame   = "row 6 centered scroll 1 10 down width 70 overlay "
 &where   = " lc.lc begins s-lcprod and LC.bank = s-ourbank and lookup(lc.lcsts,p-sts) > 0 "
 &flddisp = " LC.LC label 'Reference Number' format 'x(15)' LC.LCsts label 'Credit status' format 'x(5)' LC.cif label 'Applicant Code' format 'x(6)'"
 &chkey   = "LC"
 &index   = "lcrwhn"
 &end     = "if keyfunction(lastkey) = 'end-error' then return."
 }
  s-lc = LC.LC.
