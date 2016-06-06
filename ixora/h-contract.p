/* h-contract.p
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
        17/06/04 saltanat включено изменение для выборки контрактов по статусу (откр.,закр.) 
                          для отражения в разных меню (КонДок , Архив)
        24.04.2008 galina - перекомпеляция в связи с изменениями в форме h-contract.f                  
*/

/* h-contract.p Валютный контроль
   Поиск контрактов

   18.10.2002 nadejda создан
*/

{vc.i}
{global.i}

define var v-sel as cha format "x".

def shared var s-cif like cif.cif.
def shared var s-contract like vccontrs.contract.
def shared var s-contrstat as char.

def var vnom as char.  
def var vcnt as int format '9999'.
def var v-day as int init 30.
def var v-month as int.
def var v-god as int.

v-month = month(today).
v-god = year(today).

case v-month:
  when 1 or when 3 or when 5 or when 7 or when 8 or when 10 or when 12 then v-day = 31.
  when 4 or when 6 or when 9 or when 11 then v-day = 30.
  when 2 then do:
    if v-god mod 4 = 0 then v-day = 29.
    else v-day = 28.
  end.
end case.

message "N)Номер  Y)Год  E)Экспорт  I)Импорт  T)Тип  " update v-sel.

case v-sel :
  when "N" or when "T" then do: 
    vnom = ''. {imesg.i 2808} update vnom. 
  end.
  when "Y" then do:
    vcnt = year(g-today). {imesg.i 2808} update vcnt.
  end.
end case.

{jabro.i 
  &head      =  "vccontrs"
  &headkey   =  "contract"
  &formname  =  "h-contract"
  &framename =  "contract"
  &where     =  " (vccontrs.cif = s-cif) 
                  and ( if s-contrstat = 'rab' then  
                                         (
                                         (((today - vccontrs.stsdt) <= v-day) and (vccontrs.sts begins 'C')) 
                                         or (not (vccontrs.sts begins 'C'))
                                         ) 
                       else if s-contrstat = 'arh' then  
                                         (
                                         ((today - vccontrs.stsdt) > v-day) 
                                         and (vccontrs.sts begins 'C')
                                         ) else true
                      )
                  and if v-sel = 'N' then (vccontrs.ctnum begins vnom) else 
                  if v-sel = 'T' then (vccontrs.cttype = vnom) else 
                  if v-sel = 'Y' then (year(vccontrs.ctdate) = vcnt) else 
                  if v-sel = 'I' then (vccontrs.expimp = 'i') else 
                  if v-sel = 'E' then (vccontrs.expimp = 'e') else true "
  &index     =  "main"
  &addcon    =  "false"
  &deletecon =  "false"
  &predisplay = " find vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error. 
                  find ncrc where ncrc.crc = vccontrs.ncrc no-lock no-error. "
  &display   =  " vccontrs.ctnum vccontrs.ctdate vcpartners.name when avail vcpartners 
                  vccontrs.expimp vccontrs.cttype vccontrs.ctsum ncrc.code vccontrs.sts "
  &highlight =  " vccontrs.ctdate vccontrs.ctnum vcpartners.name 
                  vccontrs.expimp vccontrs.cttype vccontrs.ctsum ncrc.code vccontrs.sts "
  &postkey   =  " else if keyfunction(lastkey) = 'return' then do:
                    s-contract = vccontrs.contract.
                    leave upper.
                  end."
  &end =        " hide frame contract."
  }
