/* pkaftertrx-5.p
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
        04.07.2003 marinav
 * CHANGES
        11.04.05 saltanat - Добавила сохранение истории при закрытии анкеты.
        22/01/07  marinav - Провизий не будет
        13/03/2007 madiyar - убрал сохранение старого статуса в таблицу pkankhis
        24/04/2007 madiyar - веб-анкеты
*/

{global.i}
{pk.i}
{pk-sysc.i}

def var pk-sts as char.

/*
s-credtype = '6'.
s-pkankln = 10.
*/
if s-pkankln = 0 then return.

procedure fmsg-w.
    def input parameter p-bank as char no-undo.
    def input parameter p-credtype as char no-undo.
    def input parameter p-ln as integer no-undo.
    def input parameter p-msg as char no-undo.
    find first pkanketh where pkanketh.bank = p-bank and pkanketh.credtype = p-credtype and pkanketh.ln = p-ln and pkanketh.kritcod = "fmsg" exclusive-lock no-error.
    pkanketh.value1 = p-msg.
    find current pkanketh no-lock.
end procedure.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and 
     pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then do:
    message skip " Анкета N" s-pkankln "не найдена !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

def var v-inet as logi init no.
if pkanketa.id_org = "inet" then v-inet = yes.

if pkanketa.sts < "30" then do:
    if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"Ссудный счет не открыт!").
    else message skip " Ссудный счет не открыт !~n " skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

if pkanketa.sts < "60" then do:
    if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"Не построен график!").
    else message skip " Не построен график !~n " skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

/* Проставить статус кредита "1"  -  0% провизии */
 find last lonhar  where lonhar.lon = pkanketa.lon and lonhar.cif = pkanketa.cif no-error.
 if not available lonhar
 then do:
      create lonhar.
      lonhar.ln = 1.
      lonhar.lon = pkanketa.lon.
      lonhar.fdt = g-today.
      lonhar.cif = pkanketa.cif.
      lonhar.who = userid("bank").
      lonhar.whn = today.
      lonhar.lonstat = get-pksysc-int ("statpr").
 end.
 else do:
      lonhar.lonstat = get-pksysc-int ("statpr").
      lonhar.fdt = g-today.
 end.
 release lonhar.

if pkanketa.sts >= "60" and pkanketa.sts < "70" then do:
  pk-sts = pkanketa.sts.
  find current pkanketa exclusive-lock.
  pkanketa.sts = "99".
  find current pkanketa no-lock.
end.


