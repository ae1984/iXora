/* h-rmz15.p
 * MODULE
        Клиентские операции
 * DESCRIPTION
        Поиск платежа
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
        06/08/12 id00810
 * CHANGES
*/

{global.i}
def temp-table t-rmz
 field remtrz  like remtrz.remtrz
 field fcrc    like remtrz.fcrc
 field amt     like remtrz.amt
 field rdt     like remtrz.rdt
 field rbank   like remtrz.rbank
 index ind remtrz.

for each que where que.pid = 'O' and que.con = "W" no-lock,
 each  remtrz of que where remtrz.rwho = g-ofc no-lock .
     create t-rmz.
     assign t-rmz.remtrz = remtrz.remtrz
            t-rmz.fcrc   = remtrz.fcr
            t-rmz.amt    = remtrz.amt
            t-rmz.rdt    = remtrz.rdt
            t-rmz.rbank  = remtrz.rbank.
end.
for each que where que.pid = 'P' and que.con = "W" no-lock,
 each  remtrz of que where remtrz.rwho = g-ofc no-lock .
     create t-rmz.
     assign t-rmz.remtrz = remtrz.remtrz
            t-rmz.fcrc   = remtrz.fcr
            t-rmz.amt    = remtrz.amt
            t-rmz.rdt    = remtrz.rdt
            t-rmz.rbank  = remtrz.rbank.
end.
{itemlist.i
       &file    = "t-rmz"
       &where   = " true "
       &frame   = "row 4 centered scroll 1 25 down width 60 overlay "
       &flddisp = " t-rmz.remtrz label 'Платеж'
                    t-rmz.fcrc   label 'Вал'
                    t-rmz.amt    label 'Сумма'
                    t-rmz.rdt    label 'Дата'
                    t-rmz.rbank  label 'БанкП'  "
       &chkey   = "remtrz"
       &chtype  = "string"
       &index   = "ind"
       &funadd  = "if frame-value = "" "" then do:
		           {imesg.i 9205}.
		           pause 1.
		           next.
		           end."
       &set     = "P"
}
