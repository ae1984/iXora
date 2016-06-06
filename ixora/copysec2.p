/* copysec2.p
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

{mainhead.i CPSEC2}
{yes-no.i}

def var ofrom as char init "".
def var oto as char init "".

update "Введите логины пользователей" skip
        ofrom label "От кого копировать"
              validate (can-find(ofc where ofc.ofc = ofrom), "Нет такого юзера!")
        oto label "Кому"
              validate (can-find(ofc where ofc.ofc = oto), "Нет такого юзера!")
        with row 5 centered side-labels color messages
        title "КОПИРОВАНИЕ ДОСТУПА ЮЗЕРОВ" frame getfr.

hide frame getfr.

if yes-no ( "ВЫ УВЕРЕНЫ?", "Копирование " + trim(ofrom) + " -> " + trim(oto)) then do:
  run copysec2-0 (ofrom, oto).
end.

