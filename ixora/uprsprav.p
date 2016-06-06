/* uprsprav.p
 * MODULE
        Управленческая отчетность
 * DESCRIPTION
        Управленческая отчетность - ввод справочных данных
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
        24/12/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}

def temp-table t-fil no-undo
  field bank as char
  field bankn as char
  index idx is primary bank.

def temp-table t-fil2 no-undo
  field bank as char
  field bankn as char
  index idx is primary bank.

def var v-sel as char no-undo.
def var v-fil as char no-undo.
def var v-fil_des as char no-undo.
def var v-dt as date no-undo.
def var v-spr_id as char no-undo.
def var v-spr_des as char no-undo.

def var v-vali as integer no-undo.
def var v-valr as deci no-undo.
def var v-vald as date no-undo.
def var v-valc as char no-undo.

def var v-ja as logi no-undo.

def var v-nofil as char no-undo.
v-nofil = "payCostKZT,payCostRUB,payCostVal,param_x1,param_x2,param_x3,param_x4,param_x5,param_y1,param_y2,param_y3,param_y4,param_y5".

function getSprDes returns char (input p-spr_id as char).
    def var res as char no-undo.
    find first uprspr where uprspr.spr_id = p-spr_id no-lock no-error.
    if avail uprspr then res = uprspr.des.
    return res.
end function.

function getFilDes returns char (input p-fil as char).
    def var res as char no-undo.
    find first t-fil where t-fil.bank = p-fil no-lock no-error.
    if avail t-fil then res = t-fil.bankn.
    return res.
end function.

function getVal returns char (input p-bank as char, input p-spr_id as char, input p-dt as date).
    def var res as char no-undo.
    find first uprsprav where uprsprav.bank = p-bank and uprsprav.id = p-spr_id and uprsprav.date = p-dt no-lock no-error.
    if avail uprsprav then do:
        find first uprspr where uprspr.spr_id = p-spr_id no-lock no-error.
        if avail uprspr then do:
            case uprspr.spr_type:
                when 'i' then res = string(uprsprav.inval).
                when 'r' then res = string(uprsprav.deval).
                when 'c' then res = uprsprav.chval.
                when 'd' then res = string(uprsprav.daval).
            end case.
        end.
    end.
    return res.
end function.

define frame fr_main
       v-spr_id label " Справочник " format "x(10)" validate(can-find(uprspr where uprspr.spr_id = v-spr_id),"Нет такого справочника!") help "F2 - Справочник"
       "-" v-spr_des no-label format "x(60)" skip
       v-fil    label " Филиал     " format "x(5)" validate(can-find(t-fil where t-fil.bank = v-fil) or (lookup(v-spr_id,v-nofil) > 0 and v-fil = ''),"Нет такого филиала!") help "F2 - Справочник"
       "-" v-fil_des no-label format "x(60)" skip
       v-dt     label " Дата       " format "99/99/9999" validate(v-dt <= g-today,"Некорректная дата!") skip
       with row 10 width 90 side-labels centered.

define frame fr_int
       v-vali  label " Значение   " format "->>>,>>>,>>>,>>9" skip
       with row 15 width 90 side-labels centered.

define frame fr_deci
       v-valr  label " Значение   " format "->>>,>>>,>>>,>>9.9999" skip
       with row 15 width 90 side-labels centered.

define frame fr_char
       v-valc  label " Значение   " format "x(70)" skip
       with row 15 width 90 side-labels centered.

define frame fr_date
       v-vald  label " Значение   " format "99/99/9999" skip
       with row 15 width 90 side-labels centered.

on help of v-fil in frame fr_main do:
    {itemlist.i
        &file = "t-fil"
        &frame = "row 6 centered scroll 1 20 down overlay "
        &where = " true "
        &flddisp = " t-fil.bankn label 'Филиал' format 'x(40)'
                   "
        &chkey = "bankn"
        &chtype = "string"
        &index  = "idx"
        &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
    v-fil = t-fil.bank.
    displ v-fil with frame fr_main.
end.

on help of v-spr_id in frame fr_main do:
    {itemlist.i
        &file = "uprspr"
        &frame = "row 6 centered scroll 1 20 down overlay "
        &where = " true "
        &flddisp = " uprspr.spr_id label 'Код' format 'x(10)'
                     uprspr.des label 'Наименование' format 'x(60)'
                   "
        &chkey = "spr_id"
        &chtype = "string"
        &index  = "idx"
        &set  = "1"
        &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
    v-spr_id = uprspr.spr_id.
    v-spr_des = uprspr.des.
    displ v-spr_id v-spr_des with frame fr_main.
end.

empty temp-table t-fil.
for each comm.txb where comm.txb.consolid no-lock:
    create t-fil.
    assign t-fil.bank = comm.txb.bank
           t-fil.bankn = comm.txb.info.
    create t-fil2.
    assign t-fil2.bank = comm.txb.bank
           t-fil2.bankn = comm.txb.info.
end.

create t-fil2.
assign t-fil2.bank = ''
       t-fil2.bankn = 'Все филиалы'.


run sel2 (" Выбор: ", " 1. Просмотр справочника | 2. Редактирование справочника | 3. Выход ", output v-sel).

find first t-fil no-lock no-error.
if avail t-fil then v-fil = t-fil.bank.

find first uprspr no-lock no-error.
if avail uprspr then v-spr_id = uprspr.spr_id.

v-dt = g-today.

do transaction on endkey undo,retry:

repeat:
case v-sel:
    when '1' then do:
        v-spr_des = getSprDes(v-spr_id).
        v-fil_des = getFilDes(v-fil).
        displ v-spr_id v-spr_des v-fil v-fil_des v-dt with frame fr_main.
        update v-spr_id with frame fr_main.
        v-spr_des = getSprDes(v-spr_id).
        displ v-spr_des with frame fr_main.
        find first uprspr where uprspr.spr_id = v-spr_id no-lock no-error.
        if avail uprspr then do:
            if lookup(v-spr_id,v-nofil) = 0 then do:
                update v-fil with frame fr_main.
                v-fil_des = getFilDes(v-fil).
                displ v-fil_des with frame fr_main.
            end.
            else do:
                v-fil = ''. v-fil_des = ''.
                displ v-fil v-fil_des with frame fr_main.
            end.
        end.
        update v-dt with frame fr_main.
        find first t-fil2 where t-fil2.bank = v-fil no-lock no-error.
        if avail t-fil2 and avail uprspr then do:
            find first uprsprav where uprsprav.bank = t-fil2.bank and uprsprav.id = uprspr.spr_id and uprsprav.date = v-dt no-lock no-error.
            if avail uprsprav then do:
                case uprspr.spr_type:
                    when 'i' then do:
                        v-vali = uprsprav.inval.
                        displ v-vali with frame fr_int.
                    end.
                    when 'r' then do:
                        v-valr = uprsprav.deval.
                        displ v-valr with frame fr_deci.
                    end.
                    when 'c' then do:
                        v-valc = uprsprav.chval.
                        displ v-valc with frame fr_char.
                    end.
                    when 'd' then do:
                        v-vald = uprsprav.daval.
                        displ v-vald with frame fr_date.
                    end.
                end case.
            end.
            else do:
                message "Справочное значение не найдено!" view-as alert-box error.
                undo,retry.
            end.
        end.
        else do:
            message "Не найден код филиала или справочника!" view-as alert-box error.
            undo,retry.
        end.
    end.
    when '2' then do:
        v-spr_des = getSprDes(v-spr_id).
        v-fil_des = getFilDes(v-fil).
        displ v-spr_id v-spr_des v-fil v-fil_des v-dt with frame fr_main.
        update v-spr_id with frame fr_main.
        v-spr_des = getSprDes(v-spr_id).
        displ v-spr_des with frame fr_main.
        find first uprspr where uprspr.spr_id = v-spr_id no-lock no-error.
        if avail uprspr then do:
            if lookup(v-spr_id,v-nofil) = 0 then do:
                update v-fil with frame fr_main.
                v-fil_des = getFilDes(v-fil).
                displ v-fil_des with frame fr_main.
            end.
            else do:
                v-fil = ''. v-fil_des = ''.
                displ v-fil v-fil_des with frame fr_main.
            end.
        end.
        update v-dt with frame fr_main.
        find first t-fil2 where t-fil2.bank = v-fil no-lock no-error.
        if avail t-fil2 and avail uprspr then do:
            v-ja = no.
            find first uprsprav where uprsprav.bank = t-fil2.bank and uprsprav.id = uprspr.spr_id and uprsprav.date = v-dt no-lock no-error.
            if avail uprsprav then do:
                message "Данный справочник для указанной даты уже был введен.~nЗначение = " + getVal(t-fil2.bank, uprspr.spr_id, v-dt) + "~n Заменить значение?" view-as alert-box question buttons yes-no title "" update v-ja.
                if v-ja then do:
                    case uprspr.spr_type:
                        when 'i' then v-vali = uprsprav.inval.
                        when 'r' then v-valr = uprsprav.deval.
                        when 'c' then v-valc = uprsprav.chval.
                        when 'd' then v-vald = uprsprav.daval.
                    end case.
                end.
            end.
            else do:
                v-ja = yes.
                v-vali = 0.
                v-valr = 0.
                v-valc = ''.
                v-vald = ?.
            end.

            if v-ja then do:
                case uprspr.spr_type:
                    when 'i' then do:
                        update v-vali with frame fr_int.
                        if avail uprsprav then find current uprsprav exclusive-lock.
                        else do:
                            create uprsprav.
                            assign uprsprav.bank = t-fil2.bank
                                   uprsprav.id = uprspr.spr_id
                                   uprsprav.date = v-dt
                                   uprsprav.des = uprspr.des.
                        end.
                        uprsprav.who = g-ofc.
                        uprsprav.inval = v-vali.
                    end.
                    when 'r' then do:
                        update v-valr with frame fr_deci.
                        if avail uprsprav then find current uprsprav exclusive-lock.
                        else do:
                            create uprsprav.
                            assign uprsprav.bank = t-fil2.bank
                                   uprsprav.id = uprspr.spr_id
                                   uprsprav.date = v-dt
                                   uprsprav.des = uprspr.des.
                        end.
                        uprsprav.who = g-ofc.
                        uprsprav.deval = v-valr.
                    end.
                    when 'c' then do:
                        update v-valc with frame fr_char.
                        if avail uprsprav then find current uprsprav exclusive-lock.
                        else do:
                            create uprsprav.
                            assign uprsprav.bank = t-fil2.bank
                                   uprsprav.id = uprspr.spr_id
                                   uprsprav.date = v-dt
                                   uprsprav.des = uprspr.des.
                        end.
                        uprsprav.who = g-ofc.
                        uprsprav.chval = v-valc.
                    end.
                    when 'd' then do:
                        update v-vald with frame fr_date.
                        if avail uprsprav then find current uprsprav exclusive-lock.
                        else do:
                            create uprsprav.
                            assign uprsprav.bank = t-fil2.bank
                                   uprsprav.id = uprspr.spr_id
                                   uprsprav.date = v-dt
                                   uprsprav.des = uprspr.des.
                        end.
                        uprsprav.who = g-ofc.
                        uprsprav.daval = v-vald.
                    end.
                end case.
            end.
        end.
        else do:
            message "Не найден код филиала или справочника!" view-as alert-box error.
            undo,retry.
        end.
    end.
    when '3' then return.
    otherwise return.
end case.

end. /* repeat */

end. /*transaction */
