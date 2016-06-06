/*vcremact .p
 * MODULE
        Вал.кон.
 * DESCRIPTION
        Акцепт платежей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        9.11
 * AUTHOR
        24.10.2008 galina
 * BASES
        BANK
 * CHANGES
*/
{global.i}
{get-fio.i}
def var v-act as logi.
def shared var s-remtrz like remtrz.remtrz.

find remtrz where remtrz.remtrz = s-remtrz no-lock.

if remtrz.source <> "O" then do:
  if remtrz.vcact <> "" then 
    message skip "Палетеж уже акцептован!"
    view-as alert-box title " ВНИМАНИЕ ! ".
  else do:
    v-act = false.
    message skip "Акцептовать платеж?"
    view-as alert-box error buttons yes-no title " ВНИМАНИЕ ! " update v-act.
    if v-act then do: 
      find current remtrz exclusive-lock.
       assign
        remtrz.vcact = g-ofc + "," + string(g-today,'99/99/9999')
        remtrz.info[7] = get-fio(g-ofc).
      find current remtrz no-lock.
      message "Платеж акцептован!" view-as alert-box.
    end.
  end.
end.

if remtrz.source = "O" then do:
 {lgps.i "new"}
 m_pid = "O" .
 run spremtrz.
end.

