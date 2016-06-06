/* create700pril.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Формирование данных для отчетов 700h_pril и 700h_disc
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
        03/10/2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
*/


{mainhead.i}

def shared var v-gldate as date.

define shared temp-table tgl
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field type as character
    field sub-type as character
    field totlev as integer
    field totgl  as integer
    field level as integer
    field code as character
    field grp as integer
    field acc as character
    field acc-des as character
    field geo as character
    index tgl-id1 is primary gl7 .

def temp-table wrk
    field gl as int
    field des as char
    field crc as int.


def var r-type as char.
def var vs-sum as deci.
def var list-pos as int.
def var list-summ as deci extent 17.
def var all-list-summ as deci.

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
v-gldate = bank.cls.whn.
*/
/*
update v-gldate label 'Введите отчетную дату'
    validate((v-gldate < g-today ),
    'Отчетная дата должна быть меньше даты текущего ОД')
    with row 8 centered  side-label frame opt.
hide frame opt.
*/

RepName = "pril700_" + replace(string(v-gldate,"99/99/9999"),"/","-") + ".rep".

/*
if FileExist(RepPath + RepName) then do:
 message "За"  v-gldate " отчет уже запускался!".
 pause 1.
 return.
end.
*/

display '   Ждите...   '  with row 5 frame ww centered .

{r-branch.i &proc = "dis700h_txb"}

run ExportData.

hide frame ww no-pause.

/***************************************************************************************************************/
procedure ExportData:
  OUTPUT TO value(RepPath + RepName).
  FOR EACH  tgl where tgl.sum <> 0:
  EXPORT
    tgl.txb
    tgl.gl
    tgl.gl4
    tgl.gl7
    tgl.gl-des
    tgl.crc
    tgl.sum
    tgl.type
    tgl.sub-type
    tgl.totlev
    tgl.totgl
    tgl.level
    tgl.code
    tgl.grp
    tgl.acc
    tgl.acc-des
    tgl.geo.
  END.
  output close.
end procedure.
/***************************************************************************************************************/
procedure ImportData:
  INPUT FROM value(RepPath + RepName) NO-ECHO.
  LOOP:
  REPEAT TRANSACTION:
   REPEAT ON ENDKEY UNDO, LEAVE LOOP:
   CREATE tgl.
   IMPORT
     tgl.txb
     tgl.gl
     tgl.gl4
     tgl.gl7
     tgl.gl-des
     tgl.crc
     tgl.sum
     tgl.type
     tgl.sub-type
     tgl.totlev
     tgl.totgl
     tgl.level
     tgl.code
     tgl.grp
     tgl.acc
     tgl.acc-des
     tgl.geo.
   END. /*REPEAT*/
  END. /*TRANSACTION*/
  input close.
end procedure.
/***************************************************************************************************************/




