/* pkankall.p
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

/* pkankall.p ПотребКредит
   Просмотр заголовков всех анкет клиента по РНН из меню "Операции с кредитом"

   17.02.2003 nadejda
*/


{global.i}
{pk.i}

/**
{pk.i "new"}
s-pkankln = 3.
**/

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and 
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

def new shared temp-table t-anks like pkanketa.
def var v-rnn as char.

v-rnn = pkanketa.rnn.

for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.rnn = v-rnn no-lock:
  create t-anks.
  buffer-copy pkanketa to t-anks.
end.

run pkankvwlst ("ВСЕ АНКЕТЫ КЛИЕНТА").

message skip " Документ открыт в новом окне !"
  skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".

