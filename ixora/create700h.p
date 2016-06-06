/* 700-H-kons.p
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
        03/10/2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES

*/


{mainhead.i}


def shared var v-dt as date.
def shared temp-table tgl
    field txb as char
    field des as char
    field tgl as int format ">>>>"
    field gl as int
    field tcrc as integer
    field tsum1 as dec format "->>>>>>>>>>>>>>9.99"
    field tsum2 as dec format "->>>>>>>>>>>>>>9.99"
    field totlev as int
    field totgl as int.



def var RepName as char.
def var RepPath as char init "/data/reports/700h/".

/************************************************************************************************/
/*
function FileExist returns log (input v-name as char).
 def var v-result as char init "".
 input through value ("cat " + v-name + " &>/dev/null || (NO)").
 repeat:
   import unformatted v-result.
 end.
 if v-result = "" then return true.
 else return false.
end function.
*/
/************************************************************************************************/

/*
find last bank.cls.
v-dt = bank.cls.whn.
*/

/*
update v-dt label 'Введите отчетную дату'
    validate((v-dt < g-today ),
    'Отчетная дата должна быть меньше даты текущего ОД')
    with row 8 centered  side-label frame opt.
hide frame opt.
*/
RepName = "700h_" + replace(string(v-dt,"99/99/9999"),"/","-") + ".rep".

/*
if FileExist(RepPath + RepName) then do:
 message "За"  v-dt " отчет уже запускался!".
 pause 1.
 return.
end.
*/

display '   Ждите...   '  with row 5 frame ww centered .


{r-branch.i &proc = "700h-gl"}


run ExportData.

hide frame ww no-pause.

/***************************************************************************************************************/
procedure ExportData:
  OUTPUT TO value(RepPath + RepName).
  FOR EACH  tgl :
  EXPORT
    tgl.txb
    tgl.gl
    tgl.tgl
    tgl.des
    tgl.tcrc
    tgl.tsum1
    tgl.tsum2
    tgl.totlev
    tgl.totgl.
  END.
  output close.
end procedure.
/***************************************************************************************************************/
