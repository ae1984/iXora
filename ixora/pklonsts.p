/* pklonsts.p
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
        10/06/2005 madiar - поменял today на g-today
        02/12/2005 madiar - права на акцепт даются в sysc'е
*/

/* pklonsts.p Потребкредит
   Акцепт анкеты для выдачи кредита

   08.02.2003 nadejda
*/

{global.i}

{pk.i}

{pknlvar.i}

if s-pkankln = 0 then return.

def var v-ans as logical init no.
def var v-acce as char init ''.
def var v-perm as logi init no.
def var i as integer.

if g-today = today then do:
  find first sysc where sysc.sysc = "pkacce" no-lock no-error.
  if avail sysc then v-acce = sysc.chval.

  if lookup(g-ofc,v-acce) > 0 then v-perm = yes.
  else do:
    find first ofc where ofc.ofc = g-ofc no-lock no-error.
    if avail ofc then do:
      do i = 1 to num-entries(ofc.expr[1]):
        if lookup(entry(i,ofc.expr[1]),v-acce) > 0 then do: v-perm = yes. leave. end.
      end.
    end. /* if avail ofc */
  end.
  if not v-perm then do:
    message "У вас нет прав для выполнения процедуры!" view-as alert-box buttons ok.
    return.
  end.
end.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

if pkanketa.sts < "20" then do:
  message skip " Не оформлены необходимые документы !" skip(1) " Распечатайте договора !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.


if pkanketa.cdt = ? then do:
  message skip " Утвердить кредит ?" skip(1)
    view-as alert-box buttons yes-no title ""
    update v-ans.
  if v-ans then do transaction on error undo, retry:
    find current pkanketa exclusive-lock.
    pkanketa.cdt = g-today.
    pkanketa.cwho = g-ofc.
    find current pkanketa no-lock.
    /* записать в историю
    run vc2hisct(s-ln, "Контракт акцептован").*/

    s-nodel = true.
    s-page = 1.
    run pknlmenu.
  end.
end.
else do:
  message skip " Снять отметку об утверждении кредита ?" skip(1)
    view-as alert-box button yes-no title ""
    update v-ans.
  if v-ans then do transaction on error undo, retry:
    if pkanketa.lon <> "" then do:
      message skip " Кредит уже выдан !" skip(1) " Нельзя снять акцепт !" skip(1)
        view-as alert-box buttons ok title "".
    end.
    else do:
      find current pkanketa exclusive-lock.
      pkanketa.cdt = ?.
      pkanketa.cwho = "".
      find current pkanketa no-lock.
      /* записать в историю
      run vc2hisct(s-ln, "Снят акцепт контракта").*/
/*      s-nodel = false.
      s-page = 1.
      run pknlmenu.*/
    end.
  end.
end.
