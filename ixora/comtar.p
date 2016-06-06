/* comtar.p
 * MODULE
       Коммунальные платежи
 * DESCRIPTION
        Выбор тарифов по параметрам
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
        09/02/05 kanat
 * CHANGES
        10/02/05 kanat - добавил параметр tarif.stat = 'r'
        15/02/06 u00568 evgeniy добавил выбор комиссии по умолчанию, если в v-pars2 находится '##'
                 при выборе возвращается код '##' который в программе сразуже должен быть заменен на нужный код
        24/02/06 u00568 evgeniy добавил 'ju' и 'ph'- 'Тарифы для Юр. лиц' и 'Тарифы для Физ. лиц'  по умолчанию
        03/03/06 u00568 Evgeniy теперь она риально возвращает пустую строку после F4. а то баги лезли...


*/


def input parameter v-pars1 as char.
def input parameter v-pars2 as char.

/* Вычисление комиссии по параметрам */
define temp-table cmsd
    field id as char
    field name like tarif2.pakalp
    index name is unique primary name.

   
for each tarif2 where num = v-pars1 and lookup(tarif2.kod, v-pars2) > 0 and tarif2.stat = 'r' no-lock:
    do transaction on error undo, next:
        create cmsd.
        cmsd.name = tarif2.pakalp no-error.
        if error-status:error then undo, next.
        cmsd.id = tarif2.kod.
    end.
end.

if lookup('##', v-pars2) > 0 then do:
  create cmsd.
  cmsd.name = 'По умолчанию' no-error.
  cmsd.id = '##'.
end.

if lookup('ju', v-pars2) > 0 then do:
  create cmsd.
  cmsd.name = 'Тарифы для Юр. лиц' no-error.
  cmsd.id = 'ju'.
end.

if lookup('ph', v-pars2) > 0 then do:
  create cmsd.
  cmsd.name = 'Тарифы для Физ. лиц' no-error.
  cmsd.id = 'ph'.
end.



def query q1 for cmsd.

def browse b1
    query q1 no-lock
    display
        cmsd.name no-label format 'x(30)'
        with 7 down title "Комиссия".

def frame fr1
    b1
    with no-labels centered overlay view-as dialog-box.
    
on return of b1 in frame fr1
    do:
        apply "endkey" to frame fr1.
    end.


on end-error of b1 in frame fr1
    do:
      return "".
    end.



        
open query q1 for each cmsd.

if num-results("q1")=0 then
do:
    MESSAGE "Записи не найдены."
          VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
                 TITLE "Настройте комиссию".
    return.
end.

b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.
return cmsd.id.
