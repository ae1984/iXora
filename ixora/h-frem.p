/* h-frem.p
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

/* h-frem.p
*/
{global.i}

define shared variable s-fun like fun.fun.
define variable v-tit as character.

find first que use-index fprc where que.pid = "2L" and
     que.con = "W" and can-find(remtrz where remtrz.remtrz = que.remtrz and
     remtrz.rsub = "451050") no-lock no-error.
if not available que
then do:
     bell.
     message  "Переводы отсутствуют !".
     pause.
     return.
end.
find fun where fun.fun = s-fun no-lock.
find bankl where bankl.bank = fun.bank no-lock no-error.
if available bankl
then v-tit = bankl.name.
else v-tit = "".
{itemlist.i
       &updvar = " "
       &file = "que"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &where = "que.pid = '2L' and que.con = 'W' and can-find(remtrz
        where remtrz.remtrz = que.remtrz and remtrz.rsub = '451050' and
        remtrz.sbank = fun.bank and remtrz.tcrc = fun.crc)"
       &predisp = " "
       &flddisp = "que.remtrz    label 'Номер перевода'
                   v-tit format 'x(30)'  label 'Контрагент'
                   remtrz.payment   label 'Сумма'
                   remtrz.jh1       label '1 Транз.' "
       &chkey = "remtrz"
       &chtype = "string"
       &index  = "fprc"
       &findadd = " 
       find remtrz where remtrz.remtrz = que.remtrz and 
                   remtrz.rsub = '451050' no-lock. "
       &funadd = "if frame-value = "" "" then do:
                    {imesg.i 9205}.
                    pause 1.
                    next.
                  end." }
