/* cptmpl1.p
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

/* export templates for one template */

{mainhead.i CPTMPL1}
{yes-no.i}

def var v-exp as char init 'uni0001'.
def var v-imp as char init 'uni9999'.
define var i as integer.
define var s as char.
def var v-ans as logi init yes.

update "Введите коды шаблонов" skip
        v-exp label "С какого шаблона копировать пользователей"
              validate (can-find(ujosec where ujosec.template = v-exp), 
                 "Нет прав доступа к такому шаблону!")
        v-imp label " на какой "
              validate (can-find(trxhead where trim(trxhead.system) + 
              trim(string(trxhead.code, '9999')) = v-imp), "Нет такого шаблона!")
        with row 5 centered side-labels color messages
        title "КОПИРОВАНИЕ ДОСТУПА К ШАБЛОНУ" frame getfr.
hide frame getfr.

if yes-no ( "ВЫ УВЕРЕНЫ?", "Копирование " + trim(v-exp) + " -> " + trim(v-imp)) then do:

  find first ujosec where ujosec.template = v-exp no-lock no-error.
  s = ujosec.officers.
  find first ujosec where ujosec.template = v-imp no-error.
  if not avail ujosec then do:
    create ujosec.
    assign ujosec.template = v-imp.
  end.
  /* import templates for another template */
  update ujosec.officers = s.


  v-ans = yes.
  message "Показать протокол?".
  update v-ans with column 20 row 22 no-label no-box frame vv.
  hide frame vv.

  if v-ans then do:
    output to prot.txt.
    find trxhead where 
       trim(trxhead.system) + trim(string(trxhead.code, '9999')) = v-imp no-lock no-error.
    put "Пользователи шаблона " skip
        "на " g-today format "99/99/9999" skip(1)    
        "Шаблон : " v-imp + " " + trxhead.des format "x(70)" skip(1) 
        " Логин     Пользователь" skip
        "-----------------------------------------------------" skip.

    find first ujosec where ujosec.template = v-imp no-lock no-error.
    repeat i = 1 to NUM-ENTRIES (ujosec.officers):
      s = ENTRY (i, ujosec.officers).
      put " " s format "x(8)".
      find ofc where ofc.ofc = s no-lock no-error.
      if avail ofc then 
        put ofc.name at 12 format "x(60)".
      put skip.
    end.
    put skip "-----------------------------------------------------" skip(2).
    output close.

    run menu-prt("prot.txt").
  end.
end.

