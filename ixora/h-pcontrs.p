/* h-pcontrs.p
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

/* h-pcontrs.p Валютный контроль
   Поиск контракта по его данным

   18.10.2002 nadejda создан
*/

{vc.i}
{global.i}
{get-dep.i}

def shared var s-contract like vccontrs.contract.
def shared var s-vcourbank as char.

def var vnom as char.  
def var vcnt as int format '9999'.
def var v-dep like ppoint.depart.

def input parameter v-sel as char.

case v-sel :
  when "N" or when "T" then do: 
    vnom = ''. {imesg.i 2808} update vnom. 
  end.
  when "Y" then do:
    vcnt = year(g-today). {imesg.i 2808} update vcnt.
  end.
end case.

v-dep = get-dep(g-ofc, g-today).

{jabro.i 
  &head      =  "vccontrs"
  &headkey   =  "contract"
  &formname  =  "h-pcontract"
  &framename =  "pcontract"
  &where     =  " ((s-vcourbank = 'TXB00' and v-dep = 1) or 
                  (vccontrs.bank = s-vcourbank and vccontrs.depart = v-dep)) and 
                  if v-sel = 'N' then (vccontrs.ctnum begins vnom) else 
                  if v-sel = 'T' then (vccontrs.cttype = vnom) else 
                  if v-sel = 'Y' then (year(vccontrs.ctdate) = vcnt) else 
                  if v-sel = 'I' then (vccontrs.expimp = 'i') else 
                  if v-sel = 'E' then (vccontrs.expimp = 'e') else true "
  &index     =  "mainall"
  &addcon    =  "false"
  &deletecon =  "false"
  &predisplay = " find vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error. 
                  find ncrc where ncrc.crc = vccontrs.ncrc no-lock no-error. 
                  find cif where cif.cif = vccontrs.cif no-lock no-error. 
                  v-cifname = trim(trim(cif.sname) + ' ' + trim(cif.prefix))."
  &display   =  " vccontrs.ctnum vccontrs.ctdate v-cifname vcpartners.name when avail vcpartners 
                  vccontrs.expimp vccontrs.cttype vccontrs.ctsum ncrc.code vccontrs.sts "
  &highlight =  " vccontrs.ctnum vccontrs.ctdate v-cifname vcpartners.name
                  vccontrs.expimp vccontrs.cttype vccontrs.ctsum ncrc.code vccontrs.sts "
  &postkey   =  " else if keyfunction(lastkey) = 'return' then do:
                    s-contract = vccontrs.contract.
                    leave upper.
                  end."
  &end =        " hide frame pcontract."
  }


