/* garanobesp.p
 * MODULE
        Операции
 * DESCRIPTION
        залог по гарантиям
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        10/09/2010 galina
 * BASES
        BANK
 * CHANGES
        14/12/2010 madiyar - разрешаем сохранять обеспечение с суммой 0 (для ввода общего обеспечения по КЛ)
        17/10/2011 madiyar - разрешаем сохранять обеспечение без залогодателя (бланковая гарантия)
        12/04/2013 Sayat(id01143) - ТЗ 1762 от 13/03/2013 добавлены поля "N доп.согл.к договору" и "Дата доп.соглашения"
        18/04/2013 Sayat(id01143) - ТЗ 1813 от 18/04/2013 исправлена проверка при заполнении даты договора залога
        18/07/2013 Sayat(id01143) - ТЗ 1637 от 28/12/2012 "Доработка модуля по залогам"
        02/09/2013 galina - ТЗ1918 перекомпиляция
*/

{global.i}

def input parameter p-garan as char.
def temp-table t-obesp
    field acc as char
    field num as integer
    field code as integer
    field name as char
    field crc as integer
    field sum as deci
    field obesp as char
    field addr as char
    field osen as char
    field numdog as char
    field dtdog as date
    field sectp as char
    field fdt as date
    field tdt as date
    index ind1 acc num.


def buffer bb-obesp for t-obesp.
def buffer bbb-obesp for t-obesp.
def var v-rid as rowid.

def var v-save as logi init yes no-undo.
def var i as integer no-undo.
def var v-num as integer no-undo.
define query q-obesp for t-obesp.
def var v-pos as integer no-undo.
define button bsave label "Сохранить". /*для реквизитов просрочника*/

find first garan where garan.garan = p-garan no-lock no-error.

define browse b-obesp query q-obesp
displ t-obesp.num label "№" format ">>9"
      t-obesp.code label "Код" format ">>9"
      t-obesp.name label "Залогодатель                  " format "x(30)"
      t-obesp.numdog label "Номер договора " format "x(15)"
      t-obesp.dtdog label "Дата дог. " format "99/99/9999"
      t-obesp.sectp label "ТипЗал" format "x(6)"
      t-obesp.crc label "Валюта" format ">9"
      t-obesp.sum label "Сумма" format ">>>,>>>,>>>,>>9.99"
      with 10 down overlay no-label no-box.

define frame ft b-obesp  help "<Enter>-Изменить, <Ins>-Ввод, <F4>-Выход" skip bsave
 with width 110 row 3 overlay no-label title "ВВОД ОБЕСПЕЧЕНИЯ".


on "end-error" of b-obesp in frame ft do:
    message 'Сохранить изменения?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE " ВНИМАНИЕ !"
    update v-save.
    if v-save then apply 'choose' to bsave in frame ft.
    hide frame ft.
end.

for each lonsec1 where lonsec1.lon = p-garan no-lock:
    create t-obesp.
    assign t-obesp.acc = p-garan
           t-obesp.num = lonsec1.ln
           t-obesp.code = lonsec1.lonsec
           t-obesp.name = lonsec1.pielikums[1]
           t-obesp.crc = lonsec1.crc
           t-obesp.sum = lonsec1.secamt
           t-obesp.obesp = lonsec1.prm
           t-obesp.addr = lonsec1.vieta
           t-obesp.osen = lonsec1.pielikums[3].
           t-obesp.numdog = lonsec1.numdog.
           t-obesp.dtdog = lonsec1.dtdog.
           t-obesp.sectp = lonsec1.sectp.
           t-obesp.fdt = lonsec1.fdt.
           t-obesp.tdt = lonsec1.tdt.
end.

on "return" of b-obesp in frame ft do:
    b-obesp:set-repositioned-row(b-obesp:focused-row, "always").
    find first bb-obesp where rowid(bb-obesp) = rowid(t-obesp) no-lock no-error.
    if not avail bb-obesp then do:
        message "Record not found!" view-as alert-box error.
        return.
    end.
    else do:
        v-rid = rowid(bb-obesp).
        find next bb-obesp no-lock no-error.
        if avail bb-obesp then v-rid = rowid(bb-obesp).
        else do:
            find first bb-obesp where rowid(bb-obesp) = rowid(t-obesp) no-lock no-error.
            find prev bb-obesp no-lock no-error.
            if avail bb-obesp then v-rid = rowid(bb-obesp).
        end.
    end.

    find first bb-obesp where rowid(bb-obesp) = rowid(t-obesp) exclusive-lock.

    displ  bb-obesp.num format ">>9"
           bb-obesp.code format ">>9" validate(can-find(lonsec where lonsec.lonsec = bb-obesp.code no-lock), 'Неверное значение!')
           bb-obesp.name format "x(30)"
           bb-obesp.numdog format "x(15)" validate(bb-obesp.numdog <> '' ,"Номер договора залога должен быть заполнен!")
           bb-obesp.dtdog format "99/99/9999" validate(bb-obesp.dtdog <> ? and bb-obesp.dtdog <= g-today ,"Дата договора залога не может быть позже текущей или пустой!")
           bb-obesp.sectp format "x(6)" validate(can-find(codfr where codfr.codfr = 'sectp' and codfr.code = bb-obesp.sectp no-lock),'Неверное значение!')
           bb-obesp.crc format ">>>>>9" validate(can-find(crc where crc.crc = bb-obesp.crc no-lock),'Неверное значение!')
           bb-obesp.sum format ">>>,>>>,>>>,>>9.99"
           /*bb-obesp.num bb-obesp.code bb-obesp.name bb-obesp.crc bb-obesp.sum with frame fr2 row b-obesp:focused-row + 5.*/
           with width 110 no-label overlay row b-obesp:focused-row + 5 column 4 no-box frame fr2.

    on help of bb-obesp.code in frame fr2 do:
        {itemlist.i
         &file = "lonsec"
         &frame = "row 6 centered scroll 1 10 down width 70 overlay "
         &where = " lonsec.lonsec > 0 "
         &flddisp = " lonsec.lonsec label 'Код' format '>>9' lonsec.des label 'Значение' format 'x(60)' "
         &chkey = "lonsec"
         &chtype = "integer"
         &index  = "lonsec"
         &end = "if keyfunction(lastkey) = 'end-error' then return."
         }
         bb-obesp.code = lonsec.lonsec.
         displ bb-obesp.code with frame fr2.
    end.

    on help of bb-obesp.sectp in frame fr2 do:
        {itemlist.i
        &file = "codfr"
        &form = " codfr.code label ""Код"" format ""x(5)"" codfr.name[1] label ""Наименование"" format ""x(60)"" "
        &frame = " 28 down row 6 width 70 overlay "
        &where = " codfr.codfr = ""sectp"" "
        &flddisp = " codfr.code codfr.name[1] "
        &chkey = "code"
        &chtype = "string"
        &index = "cdco_idx"
        &end = "if keyfunction(lastkey) = 'end-error' then return."
        }
        bb-obesp.sectp = codfr.code.
        display bb-obesp.sectp with frame fr2.
    end.

    on help of bb-obesp.crc in frame fr2 do:
        {itemlist.i
         &file = "crc"
         &frame = "row 6 centered scroll 1 10 down width 30 overlay "
         &where = " crc.crc > 0 "
         &flddisp = " crc.crc label 'Код' format '>9' crc.des label 'Значение' format 'x(20)' "
         &chkey = "crc"
         &chtype = "integer"
         &index  = "crc"
         &set = "crc"
         &end = "if keyfunction(lastkey) = 'end-error' then return."
         }
         bb-obesp.crc = crc.crc.
         displ bb-obesp.crc with frame fr2.
    end.
    on "end-error" of frame fr2 do:
        hide frame fr2.
        pause 0.
    end.

    update bb-obesp.code with frame fr2.
    if bb-obesp.code = 5 then do:
        bb-obesp.sectp = '47'.
        bb-obesp.dtdog = ?.
        bb-obesp.fdt = garan.dtfrom.
        hide frame fr2.
        pause 0.
    end.
    else do:
        update bb-obesp.numdog with frame fr2.
        update bb-obesp.dtdog with frame fr2.
        update bb-obesp.sectp with frame fr2.
        update bb-obesp.crc with frame fr2.
        update bb-obesp.sum with frame fr2.
        bb-obesp.fdt = bb-obesp.dtdog.
        hide frame fr2.
        pause 0.
        run obespdes.
    end.
    open query q-obesp for each t-obesp where (t-obesp.fdt = ? or t-obesp.fdt <= g-today) and (t-obesp.tdt = ? or t-obesp.tdt > g-today) no-lock.
    reposition q-obesp to rowid v-rid no-error.
    find first bb-obesp where (bb-obesp.fdt = ? or bb-obesp.fdt <= g-today) and (bb-obesp.tdt = ? or bb-obesp.tdt > g-today) no-lock no-error.
    if avail bb-obesp then b-obesp:refresh().
end.

on "insert-mode" of b-obesp in frame ft do:
    v-num = 0.
    find last bbb-obesp where bbb-obesp.acc = p-garan no-lock no-error.
    if avail bbb-obesp then v-num = bbb-obesp.num.
    create t-obesp.
           t-obesp.acc = p-garan.
           t-obesp.num = v-num + 1.

    b-obesp:set-repositioned-row(b-obesp:focused-row, "always").
    v-rid = rowid(t-obesp).
    open query q-obesp for each t-obesp  where (t-obesp.fdt = ? or t-obesp.fdt <= g-today) and (t-obesp.tdt = ? or t-obesp.tdt > g-today) no-lock.
    reposition q-obesp to rowid v-rid no-error.
    find first bb-obesp where (bb-obesp.fdt = ? or bb-obesp.fdt <= g-today) and (bb-obesp.tdt = ? or bb-obesp.tdt > g-today) no-lock no-error.
    if avail bb-obesp then b-obesp:refresh().

    apply "return" to b-obesp in frame ft.
end.

on "delete-character" of b-obesp in frame ft do:
    if avail t-obesp then do:
        b-obesp:set-repositioned-row(b-obesp:focused-row, "always").
        /*delete t-obesp.*/
        t-obesp.tdt = g-today.
        open query q-obesp for each t-obesp where (t-obesp.fdt = ? or t-obesp.fdt <= g-today) and (t-obesp.tdt = ? or t-obesp.tdt > g-today) no-lock.
        find first bb-obesp where (bb-obesp.fdt = ? or bb-obesp.fdt <= g-today) and (bb-obesp.tdt = ? or bb-obesp.tdt > g-today) no-lock no-error.
        if avail bb-obesp then b-obesp:refresh().
    end.
end.

on choose of bsave in frame ft do:
   i = 0.
   /*
   for each t-obesp where t-obesp.num = 0 or t-obesp.code = 0  or t-obesp.name = '' or t-obesp.crc = 0 or t-obesp.sum = 0 exclusive-lock:
       delete t-obesp.
   end.
   */

    find first t-obesp no-lock no-error.
    if avail t-obesp then do:
        for each t-obesp no-lock:
            find first lonsec1 where lonsec1.lon = t-obesp.acc and lonsec1.ln = t-obesp.num  exclusive-lock no-error.
            if not avail lonsec1 then do:
                create lonsec1.
                    lonsec1.lon = t-obesp.acc.
                    lonsec1.ln = t-obesp.num.
            end.
            assign lonsec1.lonsec = t-obesp.code
                lonsec1.pielikums[1] = t-obesp.name
                lonsec1.crc = t-obesp.crc
                lonsec1.secamt = t-obesp.sum
                lonsec1.prm = t-obesp.obesp
                lonsec1.vieta = t-obesp.addr
                lonsec1.pielikums[3] = t-obesp.osen
                lonsec1.who = userid("bank")
                lonsec1.whn = g-today.
                lonsec1.numdog = t-obesp.numdog.
                lonsec1.dtdog = t-obesp.dtdog.
                lonsec1.sectp = t-obesp.sectp.
                lonsec1.fdt = t-obesp.fdt.
                lonsec1.tdt = t-obesp.tdt.
       end.
       i = i + 1.
   end.

   /*if i > 0 then  message " Данные сохранены " view-as alert-box information.
   else message " Данные для сохранения отсутствуют " view-as alert-box information.*/
end.

open query q-obesp for each t-obesp where (t-obesp.fdt = ? or t-obesp.fdt <= g-today) and (t-obesp.tdt = ? or t-obesp.tdt > g-today) no-lock.
enable all with frame ft.

wait-for choose of bsave or window-close of current-window.

procedure obespdes:
def var v-obesp as char no-undo.
def var v-addr as char no-undo.
def var v-osen as char no-undo.
def var v-name as char no-undo.

define frame colla skip(1)
    v-obesp label "Обеспечение   " VIEW-AS EDITOR SIZE 60 by 6 help "Наименование; F1,F4-далее" skip(1)
    v-addr  label "Адрес         " VIEW-AS EDITOR SIZE 60 by 2 help "Место нахождения; F1,F4-далее" skip(1)
    v-osen  label "Оценка        " VIEW-AS EDITOR SIZE 60 by 2 skip(1)
    v-name  label "Залогодатель  " format "x(60)" help "Наименование; F1,F4-выход" skip(1)
    with overlay width 80 side-labels column 2 row 2 title "Ввод описания обеспечения" .

on "end-error" of frame colla do:
    hide frame colla.
    pause 0.
end.
   assign v-obesp = t-obesp.obesp
          v-addr = t-obesp.addr
          v-osen = t-obesp.osen
          v-name = t-obesp.name.

   display v-obesp v-addr v-osen v-name with frame colla.
   update v-obesp v-addr v-osen v-name with frame colla.
   do transaction:
       find current t-obesp exclusive-lock no-error.
       if avail t-obesp then assign t-obesp.obesp = v-obesp
                                    t-obesp.addr = v-addr
                                    t-obesp.osen = v-osen
                                    t-obesp.name = v-name.
   end.

   hide frame colla.

   open query q-obesp for each t-obesp  where (t-obesp.fdt = ? or t-obesp.fdt <= g-today) and (t-obesp.tdt = ? or t-obesp.tdt > g-today) no-lock.
   find first bb-obesp where (bb-obesp.fdt = ? or bb-obesp.fdt <= g-today) and (bb-obesp.tdt = ? or bb-obesp.tdt > g-today) no-lock no-error.
   if avail bb-obesp then browse b-obesp:refresh().

end procedure.