/*array-create.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
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
        09.04.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
        09.04.2012 aigul - в соответсвиис прогой  create700pril.p
        24/04/2013 Luiza - ТЗ № 1587 добавление счетов 6 класса
*/


{mainhead.i}

def shared var v-gldate as date.
def shared var v-gl1 as int no-undo.
def shared var v-gl2 as int no-undo.
def shared var v-gl-cl as int no-undo.

define shared temp-table tgl
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field sum-val as decimal     format "->>>>>>>>>>>>>>9.99"
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
    field odt as date
    field cdt as date
    field perc as decimal
    field prod as char
    index tgl-id1 is primary gl7 .

def temp-table wrk
    field gl1 as int
    field des1 as char
    field gl2 as int
    field des2 as char.

/*create wrk.
wrk.gl1 = 6000.
wrk.des1 = "Счета по аккредитивам".
wrk.gl2 = 6500.
wrk.des2 = "Счета по аккредитивам".*/

create wrk.
wrk.gl1 = 6005.
wrk.des1 = "Возможные требования по выпущенным непокрытым аккредитивам".
wrk.gl2 = 6505.
wrk.des2 = "Возможные требования по выпущенным непокрытым аккредитивам".

create wrk.
wrk.gl1 = 6020.
wrk.des1 = "Возможные требования по выпущенным покрытым аккредитивам".
wrk.gl2 = 6520.
wrk.des2 = "Возможные обязательства по выпущенным покрытым аккредитивам".

create wrk.
wrk.gl1 = 6055.
wrk.des1 = "Возможные требования по выданным или подтвержденным гарантиям".
wrk.gl2 = 6555.
wrk.des2 = "Возможные обязательства по выданным или подтвержденным гарантиям".

create wrk.
wrk.gl1 = 6575.
wrk.des1 = "Возможные требования по принятым гарантиям".
wrk.gl2 = 6075.
wrk.des2 = "Возможное уменьшение требований по принятым гарантиям".

create wrk.
wrk.gl1 = 662500.
wrk.des1 = "".
wrk.gl2 = 612500.
wrk.des2 = "Условные требования по возобновляемым займам".
create wrk.
wrk.gl1 = 662510.
wrk.des1 = "".
wrk.gl2 = 612510.
wrk.des2 = "Условные требования по невозобновляемым займам ".
create wrk.
wrk.gl1 = 662511.
wrk.des1 = "".
wrk.gl2 = 612511.
wrk.des2 = "Условные требования по кредитным лимитам ДПК".
create wrk.
wrk.gl1 = 662520.
wrk.des1 = "".
wrk.gl2 = 612520.
wrk.des2 = "Условные требования по гарантиям(возобновл)".
create wrk.
wrk.gl1 = 662521.
wrk.des1 = "".
wrk.gl2 = 612521.
wrk.des2 = "Условные требования по гарантиям (невобовновл)".
create wrk.
wrk.gl1 = 662530.
wrk.des1 = "".
wrk.gl2 = 612530.
wrk.des2 = "Условные требования по возобновл.займам в рамках торгов.финанс ".
create wrk.
wrk.gl1 = 662540.
wrk.des1 = "".
wrk.gl2 = 612540.
wrk.des2 = " Условные треб. по невозобновл.займам в рамках торгов.финансир. ".
create wrk.
wrk.gl1 = 662599.
wrk.des1 = "".
wrk.gl2 = 612599.
wrk.des2 = "Условные обяз-ства по безотзывным займам,предоставл.в будущем".

create wrk.
wrk.gl1 = 6405.
wrk.des1 = "Условные требования по купле-продаже иностранной валюты".
wrk.gl2 = 6905.
wrk.des2 = "Условные обязательства по купле-продаже иностранной валюты".

def var r-type as char.
def var vs-sum as deci.
def var list-pos as int.
def var list-summ as deci extent 17.
def var all-list-summ as deci.

def var RepName as char.
def var RepPath as char init "/data/reports/array/".


RepName = "array" + string(v-gl1) + string(v-gl2) + string(v-gl-cl) + replace(string(v-gldate,"99/99/9999"),"/","-") + ".rep".

display '   Ждите...   '  with row 5 frame ww centered .

{r-branch.i &proc = "array_txb"}

def buffer b-tgl for tgl.
/* добавление внебалансовых счетов 6 класса */
for each wrk no-lock.
    if length(wrk.gl1) > 4 then do:
        find first tgl where tgl.gl = wrk.gl2 no-lock no-error.
        if available tgl then next.
        for each tgl where tgl.gl = wrk.gl1 no-lock.
            create b-tgl.
            b-tgl.txb      = tgl.txb .
            b-tgl.gl       = wrk.gl2 .
            b-tgl.gl4      = int(substring(string(wrk.gl2),1,4)) .
            b-tgl.gl7      = int(substring(string(wrk.gl2),1,4) + substring(string(tgl.gl7),5,3)) .
            b-tgl.gl-des   = wrk.des2 .
            b-tgl.crc      = tgl.crc .
            b-tgl.sum      = tgl.sum .
            b-tgl.sum-val  = tgl.sum-val .
            b-tgl.type     = tgl.type .
            b-tgl.sub-type = "add"  /*tgl.sub-type*/ .
            b-tgl.totlev   = tgl.totlev .
            b-tgl.totgl    = tgl.totgl .
            b-tgl.level    = tgl.level .
            b-tgl.code     = tgl.code .
            b-tgl.grp      = tgl.grp .
            b-tgl.acc      = tgl.acc .
            b-tgl.acc-des  = tgl.acc-des .
            b-tgl.geo      = tgl.geo .
            b-tgl.odt      = tgl.odt .
            b-tgl.cdt      = tgl.cdt .
            b-tgl.perc     = tgl.perc .
            b-tgl.prod     = tgl.prod .
        end.
    end.
    else do:
        find first tgl where tgl.gl4 = wrk.gl2 no-lock no-error.
        if available tgl then next.
        for each tgl where tgl.gl4 = wrk.gl1 no-lock.
            create b-tgl.
            b-tgl.txb      = tgl.txb .
            b-tgl.gl       = int(string(wrk.gl2) + substring(string(tgl.gl),5,2)) .
            b-tgl.gl4      = wrk.gl2 .
            b-tgl.gl7      = int(string(wrk.gl2) + substring(string(tgl.gl7),5,3)) .
            b-tgl.gl-des   = wrk.des2 .
            b-tgl.crc      = tgl.crc .
            b-tgl.sum      = tgl.sum .
            b-tgl.sum-val  = tgl.sum-val .
            b-tgl.type     = tgl.type .
            b-tgl.sub-type = "add"  /*tgl.sub-type*/ .
            b-tgl.totlev   = tgl.totlev .
            b-tgl.totgl    = tgl.totgl .
            b-tgl.level    = tgl.level .
            b-tgl.code     = tgl.code .
            b-tgl.grp      = tgl.grp .
            b-tgl.acc      = tgl.acc .
            b-tgl.acc-des  = tgl.acc-des .
            b-tgl.geo      = tgl.geo .
            b-tgl.odt      = tgl.odt .
            b-tgl.cdt      = tgl.cdt .
            b-tgl.perc     = tgl.perc .
            b-tgl.prod     = tgl.prod .
        end.
    end.
end.
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
    tgl.sum-val
    tgl.type
    tgl.sub-type
    tgl.totlev
    tgl.totgl
    tgl.level
    tgl.code
    tgl.grp
    tgl.acc
    tgl.acc-des
    tgl.geo
    tgl.odt
    tgl.cdt
    tgl.perc
    tgl.prod.
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
     tgl.sum-val
     tgl.type
     tgl.sub-type
     tgl.totlev
     tgl.totgl
     tgl.level
     tgl.code
     tgl.grp
     tgl.acc
     tgl.acc-des
     tgl.geo
     tgl.odt
     tgl.cdt
     tgl.perc
     tgl.prod.
   END. /*REPEAT*/
  END. /*TRANSACTION*/
  input close.
end procedure.
/***************************************************************************************************************/




