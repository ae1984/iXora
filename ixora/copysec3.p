/* copysec3.p
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

/* удаление прав пользователя  */

{mainhead.i CPSEC3}
{yes-no.i}

def var ofrom as char init "".
def var v-str as char.
def var i as integer.

update  ofrom label "Введите логин пользователя"
              validate (can-find(ofc where ofc.ofc = ofrom), "Нет такого юзера!")
        with row 5 centered side-labels color messages
        title "ЛИШЕНИЕ ПРАВ ЮЗЕРА" frame getfr.

if yes-no ( "ВЫ УВЕРЕНЫ?", "Удаление прав для " + trim(ofrom)) then do:

  message "Удаление прав доступа к пунктам меню...". pause 1.
  for each sec where sec.ofc = ofrom:
    delete sec.
  end.
  hide message no-pause.

  message "Удаление прав доступа к шаблонам...". pause 1.
  for each ujosec where lookup(ofrom, ujosec.officers) > 0 exclusive-lock:
    v-str = "".
    do i = 1 to num-entries(ujosec.officers):
      if entry(i, ujosec.officers) <> "" and entry(i, ujosec.officers) <> ofrom then do:
        v-str = v-str + entry(i, ujosec.officers) + ",".
      end.
    end.
    ujosec.officers = v-str.
  end.
  release ujosec.
  hide message no-pause.

  message "Удаление прав доступа к платежной системе...". pause 1.
  for each pssec where lookup(ofrom, pssec.ofcs) > 0 exclusive-lock:
    v-str = "".
    do i = 1 to num-entries(pssec.ofcs):
      if entry(i, pssec.ofcs) <> "" and entry(i, pssec.ofcs) <> ofrom then do:
        v-str = v-str + entry(i, pssec.ofcs) + ",".
      end.
    end.
    pssec.ofcs = v-str.
  end.
  release pssec.
  hide message no-pause.

  message "Удаление прав доступа к пунктам верхнего меню...". pause 1.
  for each optitsec where lookup(ofrom, optitsec.ofcs) > 0 exclusive-lock:
    v-str = "".
    do i = 1 to num-entries(optitsec.ofcs):
      if entry(i, optitsec.ofcs) <> "" and entry(i, optitsec.ofcs) <> ofrom then do:
        v-str = v-str + entry(i, optitsec.ofcs) + ",".
      end.
    end.
    optitsec.ofcs = v-str.
  end.
  release optitsec.
  hide message no-pause.
end.


