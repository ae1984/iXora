/* i-go.p
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
        09.09.2004 tsoy добавил сверку с выпиской

*/

/*08/02/02 был дан доступ для проведения платежей в тенге */
{global.i}
{lgps.i }
def shared var s-remtrz like remtrz.remtrz .
def var yn as log initial false format "Да/Нет".
def var ok as log .

{ps-prmt.i}

def var is_in_stmt as log .

find first remtrz where remtrz.remtrz = s-remtrz no-lock  .

if remtrz.fcrc <> 1 then do:
     run checkGW (s-remtrz, output is_in_stmt).

     if not is_in_stmt then do:
         Message " Платеж не найден в выписках SWIFT ! Продолжить ? " update yn.
         if not yn then return.  
     end.
end.

Message "Вы уверены?" update yn .

if remtrz.ptype eq ""  then do:
 Message "Ошибка! Тип платежа не определен!" . pause .
 return .
end.

if yn then do transaction :

find first que where que.remtrz = s-remtrz exclusive-lock no-error .
/*ja for branch texaka*/
if remtrz.source ne "UI"  and remtrz.ptype <> "5" then do:
if avail que and ( que.pid ne m_pid or que.con eq "F" ) then  do:
 Message "Ошибка! Вы не являетесь владельцем!" . pause .
 undo.
 release que .
 return .
end.
 
/* 08.02.02
if remtrz.fcrc = 1 
then do :
 Message "Ошибка! Тип =" + remtrz.ptype + "вал = " + string(remtrz.fcrc). 
 pause .
 undo.
 release que .
 return .
end.      08.02.02*/
end.

if avail que then do :
find  first  remtrz  where remtrz.remtrz = s-remtrz exclusive-lock .

  {canbal.i}
  {nbal+r.i}
  que.pid = m_pid.

if remtrz.valdt1 <= g-today then
  que.rcod = "0" .
  else que.rcod = "1" .

  if remtrz.ptype = "8" and remtrz.source = "I" then
     que.rcod = "3".
  if not remtrz.ptyp = "5" then do:
    if ( remtrz.source = "I" or remtrz.source = "SW" )  
        and remtrz.ptyp ne "8" 
       /* and remtrz.fcrc ne 1 08/02/02*/
    then 
       que.rcod = "8".
  end.
  v-text = " Отсылка " + remtrz.remtrz + " по маршруту , код возврата = " 
    + que.rcod  .
  run lgps.
  que.con = "F".
  que.dp = today.
  que.tp = time.
  release que .
end.
end .
