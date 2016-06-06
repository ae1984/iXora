/* h-pcontrps.p
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
 * BASES
        BANK COMM
 * CHANGES
        06.01.2011 aigul - исправила поиск по ПС
        09.08.2011 damir - объявил переменные v-valogov1,v-valogov2
        05.08.2011 aigul - новые переменные для банка бен и корр
        12.09.2011 damir - объявил переменную v-check.
        26.12.2012 damir - Внедрено Т.З. № 1306. Добавил vcmainshared.i.
*/
{vc.i}
{global.i}
{get-dep.i}
{vcmainshared.i "new"}
{comm-txb.i}

def new shared var s-cif like cif.cif.
def new shared var s-newrec as logi.
define new shared frame vccontrs.
define new shared frame menu.
def shared var s-contract like vccontrs.contract.

def buffer bvccontrs for vccontrs.

def var v-valogov1 as char.
def var v-valogov2 as char.
def var v-bb as char.
def var v-bb1 as char.
def var v-bb2 as char.
def var v-bb3 as char.
def var v-bc as char.
def var v-bc1 as char.
def var v-bc2 as char.
def var v-bc3 as char .
def var v-check as logi init no.
def var vnom as char format "x(35)".

s-vcourbank = comm-txb().
s-newcontract = false.
{vccontrs.f}

{jabro.i
&start     =  " vnom = ''.
                message ' Любая часть номера паспорта сделки ' update vnom. "
&head      =  "vcps"
&headkey   =  "ps"
&formname  =  "h-pcontrps"
&framename =  "pcontract"
&where     =  " (vcps.dntype = '01') and vcps.dnnum + string(vcps.num) matches '*' + vnom + '*' "
&index     =  "dnnum"
&addcon    =  "false"
&deletecon =  "false"
&predisplay = " find vccontrs where vccontrs.contract = vcps.contract no-lock no-error.
              find cif where cif.cif = vccontrs.cif no-lock no-error.
              if avail cif then v-cifname1 = trim(trim(cif.sname) + ' ' + trim(cif.prefix)).
              else v-cifname1 = ''.
              ps = vcps.dnnum + string(vcps.num).
              "
&display   =  " ps vccontrs.cif v-cifname1 vccontrs.ctnum vccontrs.ctdate
              vccontrs.expimp vccontrs.sts "
&highlight =  " ps vccontrs.cif v-cifname1 vccontrs.ctnum vccontrs.ctdate
              vccontrs.expimp vccontrs.sts "
&postkey   =  " else if keyfunction(lastkey) = 'return' then do:
                s-contract = vcps.contract.
                if s-contract <> 0 then do:
                  find vccontrs where vccontrs.contract = s-contract no-lock no-error.
                  find cif where cif.cif = vccontrs.cif no-lock no-error.
                  if avail cif and
                     (s-vcourbank = 'txb00' and get-dep(g-ofc, g-today) = 1) or
                     (s-vcourbank = vccontrs.bank /*and get-dep(g-ofc, g-today) = (integer(cif.jame) mod 1000)*/) then do:
                    s-cif = vccontrs.cif.
                    v-cifname = s-cif + ' ' + trim(trim(substring(cif.name, 1, 40)) + '' + trim(cif.prefix)).
                    run vccontrs.
                  end.
                end.
              end."
&end =        " hide frame pcontract."
}



