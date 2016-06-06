/* s-lonnd1.p
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
        07/10/2005 marinav - изменена форма, добавлена возможность выбора данных из досье
        11/10/2005 madiyar - при вызове проги s-secamt в зашаренную переменную m-ln записываем номер записи
        01/03/2011 madiyar - доп. информация по залогодателям
        18/07/2011 kapar - ТЗ 948
        07/03/2013 sayat(id01143) - ТЗ 1655 добавлены поля "№ договора"(lonsec1.numdog), "Дата дог."(lonsec1.dtdog) и "ТипЗал"(lonsec1.sectp) с выбором значения из справочника
        16/07/2013 Sayat(id01143) - ТЗ 1198
        16/07/2013 Sayat(id01143) - ТЗ 1637
*/

/*-------------------------------
  #3.NodroЅin–juma ievade
-------------------------------*/
{global.i}
{kd.i new}
define shared variable s-lon    as character.
def var ii as inte init 1 no-undo.

def var savehis as logi format 'yes/no' initial 'yes'.

find lon where lon.lon = s-lon no-lock.
find last crchis where crchis.crc = lon.crc and crchis.rdt <= lon.rdt no-lock no-error.
if not available crchis then find first crchis where crchis.crc = lon.crc and crchis.rdt > lon.rdt no-lock no-error.

find first lonsec1 where lonsec1.lon = s-lon no-error.
if not available lonsec1 then do:
    find first kdlon where kdlon.kdcif = lon.cif no-lock no-error.
    if avail kdlon then do:

       {itemlist.i
            &file = "kdlon "
            &frame = "row 6 centered scroll 1 12 down overlay "
            &where = " kdlon.kdcif = lon.cif "
            &flddisp = " kdlon.kdlon label 'КОД' format 'x(6)'
                         kdlon.regdt label 'ДАТА РЕГ'
                         kdlon.amountz label 'СУММА' format '>>>,>>>,>>9.99'
                         kdlon.goalz label 'ЦЕЛЬ КРЕДИТА' format 'x(30)'
                       "
            &chkey = "kdlon"
            &chtype = "string"
            &index  = "bankkod"
        }

        s-kdlon = kdlon.kdlon.

        do transaction:
            for each kdaffil where kdaffil.bank = s-ourbank and kdaffil.code = '20' and kdaffil.kdcif = lon.cif and kdaffil.kdlon = s-kdlon no-lock.
                create lonsec1.

                assign lonsec1.ln = kdaffil.ln
                       lonsec1.lon = s-lon
                       lonsec1.lonsec = kdaffil.lonsec
                       lonsec1.crc  = kdaffil.crc
                       lonsec1.secamt  = kdaffil.amount_bank
                       lonsec1.prm  = kdaffil.info[1]
                       lonsec1.vieta  = kdaffil.info[5]
                       lonsec1.pielikums[1]  = kdaffil.name
                       lonsec1.pielikums[2]  = kdaffil.info[9].
                if num-entries (kdaffil.info[7]) > 2 then lonsec1.pielikums[3]  = entry(3,kdaffil.info[7],'^').
                ii = ii + 1.
            end.
        end. /* transaction */
    end.
end.


def var s_rowid as rowid.
def var v-txt as char no-undo.
def var v-log as logi no-undo.
def buffer b-lonsec1 for lonsec1.
def var v-select as integer.
v-select = 0.

run sel2 ("ВЫБЕРИТЕ ДЕЙСТВИЕ :"," 1. ВВОД(только актуальные) | 2. КОРРЕКТИРОВКА(все) ", output v-select).

if v-select =  1 then do:
{jabrw.i
&start     = "  "
&head      = "lonsec1"
&headkey   = "ln"
&index     = "lonln"

&formname  = "s-lonnd1"
&framename = "sec1"
&where     = " lonsec1.lon = s-lon and (g-today >= lonsec1.fdt or lonsec1.fdt = ?) and (g-today < lonsec1.tdt or lonsec1.tdt = ?) "

&addcon    = " true "
&deletecon = " true "
&precreate = " "
&postadd   = "  find last b-lonsec1 where b-lonsec1.lon = s-lon no-lock no-error.
                if avail b-lonsec1 then m-ln = b-lonsec1.ln + 1.
                find current lonsec1 exclusive-lock.
                lonsec1.ln = m-ln.
                lonsec1.lon = s-lon.
                lonsec1.who = userid('bank').
                lonsec1.whn = g-today.
                lonsec1.fdt = g-today.
                lonsec1.tdt = date(12,31,2999).
                displ lonsec1.ln with frame sec1."

&prevdelete = " message ""Сохранить историю по залогу?"" view-as alert-box question buttons YES-NO TITLE ""Внимание !!!"" update savehis.
                if savehis then do:
                    lonsec1.fdt = lonsec1.dtdog.
                    lonsec1.tdt = g-today.
                    find current lonsec1 no-lock.
                    create lonsec1.
                 end.
              "

&prechoose = " message 'F6 - Мониторинг, Ctrl+D - Удалить, F4 - Выход'. "

&postdisplay = " "

&display   = " lonsec1.ln lonsec1.lonsec lonsec1.pielikums[1] lonsec1.numdog lonsec1.dtdog lonsec1.sectp lonsec1.crc lonsec1.secamt  "

&highlight = " lonsec1.ln lonsec1.lonsec lonsec1.pielikums[1] lonsec1.numdog lonsec1.dtdog lonsec1.sectp lonsec1.crc lonsec1.secamt "

&postkey   = "else
              if lastkey = keycode('F6') then do:
                  m-ln = lonsec1.ln.
                  run zlgmonclnd('zalog',' Проверка залогового обеспечения ').
                  next upper.
              end. "


&postupdate = "m-ln = lonsec1.ln.

               update lonsec1.lonsec with frame sec1.
               v-log = no.
               run s-seczal(lon.lon,m-ln,output v-log, output v-txt).
               if v-log then do:
                 lonsec1.pielikums[1] = v-txt.
                 displ lonsec1.pielikums[1] with frame sec1.
               end.
               update lonsec1.numdog lonsec1.dtdog with frame sec1.
               update lonsec1.sectp with frame sec1.
               update lonsec1.crc lonsec1.secamt with frame sec1.
               run s-secamt.
               find current lonsec1 exclusive-lock.
               lonsec1.fdt = lonsec1.dtdog.
               next upper.
              "

&end = "hide frame sec1."
}
hide message.
end.
else do:
run s-lonnd1s.
hide message.
end.
